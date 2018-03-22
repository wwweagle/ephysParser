function plotDynIdxVsIm
addpath('..')
lf=listF();
decodingByOdor=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-2,0.5,7,[30,1;30,1],500,1);
[ImPerUnit,~,selPerUnit,~, avgFR]=plotIm('delay',8);
suv=SUVarTCurve();
mvDec=suv.plotDecoding(decodingByOdor);
avgDec=suv.plotAvgedDecoding(decodingByOdor,'delay');
mAvgDec=mean(avgDec,2);
mMvDec=mean(mvDec,2);
dynIdx=(mMvDec-mAvgDec)./(mMvDec+mAvgDec);





figure('Color','w','Position',[100,100,330,250]);
hold on;
% plot([0,1],[0,0],'-','Color',[0.9,0.9,0.9]);
fh=plot(ImPerUnit,dynIdx,'k.');
ylabel('Dynamic index');
xlabel('Mutual information (bit)');
[R,P]=corrcoef(ImPerUnit,dynIdx);
text(0.5,0,sprintf('r = %0.3f',R(1,2)));
text(0.75,0,sprintf('p = %0.3f',P(1,2)));


figure('Color','w','Position',[100,100,330,250]);
hold on;
% plot([0,1],[0,0],'-','Color',[0.9,0.9,0.9]);
plot(abs(selPerUnit),dynIdx,'k.')
plot(abs(selPerUnit(dynP.*len<0.05 & dynIdx>0)),dynIdx(dynP.*len<0.05 & dynIdx>0),'r.')
plot(abs(selPerUnit(dynP.*len<0.05 & dynIdx<0)),dynIdx(dynP.*len<0.05 & dynIdx<0),'g.')
ylabel('Dynamic index');
xlabel('abs(Selectivity)');
[R,P]=corrcoef(abs(selPerUnit),dynIdx);
text(0.5,0,sprintf('r = %0.3f',R(1,2)));
text(0.75,0,sprintf('p = %0.3f',P(1,2)));



figure('Color','w','Position',[100,100,330,250]);
hold on;
% plot([0,1],[0,0],'--r');
plot(avgFR,ImPerUnit,'k.')
ylabel('Mutual information (bit)');
xlabel('Average firing rate (Hz)');
[R,P]=corrcoef(avgFR,dynIdx);
text(20,0.75,sprintf('r = %0.3f',R(1,2)));
text(20,0.5,sprintf('p = %0.3f',P(1,2)));



figure('Color','w','Position',[100,100,330,250]);
hold on;
% plot([0,1],[0,0],'--r');
plot(avgFR,abs(selPerUnit),'k.')
ylabel('abs(Selectivity)');
xlabel('Average firing rate (Hz)');
[R,P]=corrcoef(avgFR,abs(selPerUnit));
text(20,0.75,sprintf('r = %0.3f',R(1,2)));
text(20,0.5,sprintf('p = %0.3f',P(1,2)));


figure('Color','w','Position',[100,100,330,250]);
hold on;
% plot([0,1],[0,0],'--r');
plot(abs(selPerUnit),ImPerUnit,'k.')
xlabel('abs(Selectivity)');
ylabel('Mutual information (bit)');
[R,P]=corrcoef(abs(selPerUnit),ImPerUnit);
text(0.5,0.75,sprintf('r = %0.3f',R(1,2)));
text(0.5,0.5,sprintf('p = %0.3f',P(1,2)));


figure('Color','w','Position',[100,100,330,250]);
hold on;
% plot([0,1],[0,0],'--r');
plot(avgFR,dynIdx,'k.')
xlabel('Average firing rate (Hz)');
ylabel('Dynamic coding index');
[R,P]=corrcoef(avgFR,dynIdx);
text(20,0,sprintf('r = %0.3f',R(1,2)));
text(25,0,sprintf('p = %0.3f',P(1,2)));

end