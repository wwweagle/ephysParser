binW=0.01;
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

exfiles=ls('R:\ZX\APC\RecordingAug16\OpSuppCases\EX*.eps');
ids=arrayfun(@(x) str2double(regexp(exfiles(x,:),'(?<=F)\d{3}','match','once')),1:size(exfiles,1));
suIdces=arrayfun(@(x) str2double(regexp(exfiles(x,:),'(?<=SU)\d{2}','match','once')),1:size(exfiles,1));


fjitter=figure('Color','w','Position',[200,200,310,200]);
hold on;
fevk=figure('Color','w','Position',[200,200,310,200]);
hold on;
for fIdx=1:length(ids)
    suIdx=suIdces(fIdx);
    if ids(fIdx)==37 && suIdx==1
        continue;
    end
    load(fileList{ids(fIdx)});
    ts=s2f.getTS(EVT,SPK,'opsuppress',false,true);
    trialCount=length(ts{suIdx}{1});
    evoked=cellfun(@(x) min(x(x>1))-1,ts{suIdx}{1});
    lastBin=cellfun(@(x) any(x>(1-binW) & x<1),ts{suIdx}{1});
    firstBin=cellfun(@(x) any(x>1 & x<(1+binW)),ts{suIdx}{1});
    evoked(evoked>2)=nan;
    evoked=evoked.*1000;
    mDelay=nanmean(evoked);
    mCi=bootci(100,@(x) nanmean(x), evoked);
    sdDelay=nanstd(evoked);
    sdCi=bootci(100,@(x) nanstd(x),evoked);
    fprintf('%d_%d_%.4f_%.4f_%.4f\n',ids(fIdx),suIdx,mDelay,mCi(1),mCi(2));
    figure(fjitter);
    errorbar(sdDelay,mDelay,mCi(1)-mDelay,mCi(2)-mDelay,'k.');
    
%     
%     mEvk1stBin=mean(firstBin).*100;
%     ciEvk1stBin=bootci(100,@(x) mean(x).*100,firstBin);
%     
%     mEvkLastBin=mean(lastBin).*100;
%     ciEvkLastBin=bootci(100,@(x) mean(x).*100,lastBin);
%     
%     [~,~,p,~]=crosstab([zeros(length(firstBin),1);ones(length(firstBin),1)],[firstBin;lastBin]);
%     
%     figure(fevk);
%     errorbar(mEvk1stBin,mEvkLastBin,ciEvkLastBin(1)-mEvkLastBin,ciEvkLastBin(2)-mEvkLastBin,ciEvk1stBin(1)-mEvk1stBin,ciEvk1stBin(2)-mEvk1stBin,'.');
%     if p<0.05
%         plot(mEvk1stBin,mEvkLastBin,'k*');
%     end
    
end
% set(gca,'XScale','log');
figure(fjitter);
xlabel('Jitter (ms)');
ylabel('Latency (ms)');
% 
% figure(fevk);
% xlabel(sprintf('%d ms after laser-on',binW*1000));
% ylabel(sprintf('%d ms before laser-on',binW*1000));
% xlim([0,60]);
% ylim([0,30]);
% plot([0,100],[0,100],':k');

print(fjitter,'-depsc','-painters','OpSuppJitter.eps');
% print(fevk,'-depsc','-painters','Repeatability.eps');


