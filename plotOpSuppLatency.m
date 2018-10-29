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
out=cell(0,4);

for fIdx=2:length(fileList)
    load(fileList{fIdx});
    ts=s2f.getTS(EVT,SPK,'opsuppress',false,true);
    for suIdx=1:length(ts)
        hists=cell2mat(cellfun(@(x) histcounts(x,-1.05:0.05:5.05),ts{suIdx}{1},'UniformOutput',false));
        hc=sum(hists(:,2:end-1));
        p=permTest(hc(1:40),hc(41:80),1000);
        
        if p<0.05
            if sum(hc(41:80))>sum(hc(1:40))
                suffix='EX';
            else
                suffix='SU';
            end
            
            binW=0.05;
            base=cellfun(@(x) sum(x>(1-binW) & (x<=1)), ts{suIdx}{1})';
            for win=1.001:0.001:1.5
                toTest=cellfun(@(x) sum(x>(win-binW) & (x<=win)), ts{suIdx}{1})';
                p=permTest(base,toTest,2000);
                if p<0.001
                    fprintf('%s_F%03d_SU%02d_L%.1f\n',suffix,fIdx,suIdx,(win-1)*1000);
                    out(end+1,:)={suffix,fIdx,suIdx,(win-1)*1000};
                    save('OpSuppLatency.mat','out');
                    break;
                end
            end
        else
            suffix='';
        end

        %         print('-dpng','-painters',sprintf('R:/ZX/APC/RecordingAug16/OpSuppCases/%s_F%03d_SU%02d_30t.png',suffix,fIdx,suIdx));
        %         print('-depsc','-painters',sprintf('R:/ZX/APC/RecordingAug16/OpSuppCases/%s_F%03d_SU%02d_30t.eps',suffix,fIdx,suIdx));
        
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