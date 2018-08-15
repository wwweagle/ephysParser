byLick=false;
delayLen=8;
javaaddpath('R:\ZX\java\spk2fr\build\classes');
javaaddpath('R:\ZX\java\spk2fr\lib\jmatio.jar');
javaaddpath('R:\ZX\java\spk2fr\lib\commons-math3-3.5.jar');
javaaddpath('R:\ZX\java\DualEvtParser\build\classes');
s2f=spk2fr.Spk2fr;
s2f.setRefracRatio(0.0015);
s2f.setLeastFR('Average2Hz');
fl=listF();
fileList=fl.listOpSupp(false);


for fIdx=2:length(fileList)
    load(fileList{fIdx});
    ts=s2f.getTS(EVT,SPK,'opsuppress',false,true);
    for suIdx=1:length(ts)
        trialCount=length(ts{suIdx}{1});
        hists=cell2mat(cellfun(@(x) histcounts(x,-1.05:0.05:5.05),ts{suIdx}{1},'UniformOutput',false));
        hc=sum(hists(:,2:end-1));
        p=permTest(hc(1:40),hc(41:80),1000);
        ci=bootci(100,@(x) mean(x(:,2:end-1)),hists).*20;
%         ci(1,:)=smooth(ci(1,:)')';
%         ci(2,:)=smooth(ci(2,:)')';
        fh=figure('Color','w','Position',[100,100,200,210]);
        %%%%AVG%%%%
        subplot('Position',[0.2,0.68,0.75,0.25]);
        hold on;
        fill([0,2,2,0],[0,0,trialCount,trialCount],[0.9,0.9,1],'EdgeColor','none');
        fill([-2:0.05:4-0.05,4-0.05:-0.05:-2],[ci(1,:),fliplr(ci(2,:))],[1,0.8,0.8],'EdgeColor','none');
        plot(-2:0.05:4-0.05,hc./size(ts{suIdx}{1},1).*20,'-r','LineWidth',1);
        set(gca,'XTick',[]);
        ylim([0,max(ci(:))]);
        ylabel('Avg. FR (Hz)');
        %%%%Raster%%%%%%%
%         subplot('Position',[0.2,0.1,0.75,0.5]);
        subplot('Position',[0.2,0.35,0.75,0.25]);
        hold on;
        fill([1,3,3,1],[0,0,trialCount,trialCount],[0.9,0.9,1],'EdgeColor','none');
        rasterWindow=ceil(trialCount./2)-15:ceil(trialCount./2)+14;
        
        try
        arrayfun(@(x) plot([ts{suIdx}{1}{x},ts{suIdx}{1}{x}]',[x-min(rasterWindow)+0.6;x-min(rasterWindow)+1.4]*ones(1,length(length(ts{suIdx}{1}{x}))),'-k'),rasterWindow);
        catch ME
            disp('one error');
        end
        xlim([-1,5]);
        set(gca,'XTick',-1:2:5,'XTickLabel',-2:2:4);
        ylim([0.5,length(rasterWindow)+0.5]);
        xlabel('Time (s)');
        ylabel('Trial #');
        text(1,trialCount-10,sprintf('p = %.4f',p));
        if p<0.05
            if sum(hc(41:80))>sum(hc(1:40))
                suffix='EX';
            else
                suffix='SU';
            end
        else
            suffix='';
        end
        print('-dpng','-painters',sprintf('R:/ZX/APC/RecordingAug16/OpSuppCases/%s_F%03d_SU%02d_30t.png',suffix,fIdx,suIdx));
        print('-depsc','-painters',sprintf('R:/ZX/APC/RecordingAug16/OpSuppCases/%s_F%03d_SU%02d_30t.eps',suffix,fIdx,suIdx));
        close(fh)
    end
end


function p=permTest(a,b,rpt)
currDiff=abs(mean(a)-mean(b));
permDiff=nan(rpt,1);
pool=[a,b];
for rptIdx=1:rpt
pool=pool(randperm(length(pool)));
poolA=pool(1:length(a));
poolB=pool(length(a)+1:end);
permDiff(rptIdx)=abs(mean(poolA)-mean(poolB));
end

meanDiff=mean(permDiff);
p=sum(abs(permDiff-meanDiff)>=abs(currDiff-meanDiff))./rpt;

end