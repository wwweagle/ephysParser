byLick=false;
binSize=0.25;
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


for fIdx=1%:length(fileList)
    load(fileList{fIdx});
    ts=s2f.getTS(EVT,SPK,'opsuppress',false,true);
    for suIdx=1:length(ts)
        trialCount=length(ts{suIdx}{1});
        hists=cell2mat(cellfun(@(x) histcounts(x,-1.2:0.2:5.2),ts{suIdx}{1},'UniformOutput',false));
        hc=sum(hists(:,2:end-1));
        p=permTest(hc(1:10),hc(11:20),1000);
        ci=bootci(100,@(x) mean(x(:,2:end-1)),hists);
        fh=figure('Color','w');
        subplot(2,1,1);
        hold on;
        fill([0,2,2,0],[0,0,trialCount,trialCount],[0.9,0.9,1],'EdgeColor','none');
        fill([-2:0.2:4-0.2,4-0.2:-0.2:-2],[ci(1,:),fliplr(ci(2,:))],[1,0.8,0.8],'EdgeColor','none');
        plot(-2:0.2:4-0.2,hc./size(ts{suIdx}{1},1),'-r','LineWidth',1);
        set(gca,'XTick',[]);
        ylim([0,max(ci(:))]);
        ylabel('Average FR (Hz)');
        
        subplot(2,1,2);
        hold on;
        fill([1,3,3,1],[0,0,trialCount,trialCount],[0.9,0.9,1],'EdgeColor','none');

        arrayfun(@(x) plot([ts{suIdx}{1}{x},ts{suIdx}{1}{x}]',[x-0.4;x+0.4]*ones(1,length(length(ts{suIdx}{1}{x}))),'-k'),1:trialCount);
        
        xlim([-1,5]);
        set(gca,'XTick',-1:2:5,'XTickLabel',-2:2:4);
        ylim([-0.5,trialCount+0.5]);
        xlabel('Time (s)');
        ylabel('Trial #');
        text(1,trialCount-10,sprintf('p = %.4f',p));
        if p<0.05
            if sum(hc(11:end))>sum(hc(1:10))
                suffix='EX';
            else
                suffix='SU';
            end
        else
            suffix='';
        end
        print('-dpng','-painters',sprintf('R:/ZX/APC/RecordingAug16/OpSuppCases/F%03d_SU%02d_%s.png',fIdx,suIdx,suffix));
%         close(fh)
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