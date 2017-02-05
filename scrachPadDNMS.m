pause();

lf=listF();
trajectoryByOdor4s=sampleByType(lf.listDNMS4s,'odor','Average2Hz',-2,0.2,7,[20,20;20,20],100,1);
trajectoryByOdor8s=sampleByType(lf.listDNMS8s,'odor','Average2Hz',-2,0.2,11,[20,20;20,20],100,1);
pc=plotCurve;
pc.binSize=0.5;
pc.plotTrajectory(trajectoryByOdor8s,'trajectoryByOdor8s',1:20);
pc.plotTrajectory(trajectoryByOdor4s,'trajectoryByOdor4s',1:20);
convertFigs('trajectoryByOdor?s');


trajectoryByOdor4s=sampleByType(lf.listDNMS4s,'odor','Average2Hz',-2,0.5,7+9,[20,20;20,20],100,1);
trajectoryByOdor8s=sampleByType(lf.listDNMS8s,'odor','Average2Hz',-2,0.5,11+9,[20,20;20,20],100,1);

decodingByOdor4s=sampleByType(lf.listDNMS4s,'odor','Average2Hz',-2,0.5,7,[30,1;30,1],500,1);
decodingByOdor8s=sampleByType(lf.listDNMS8s,'odor','Average2Hz',-2,0.5,11,[30,1;30,1],500,1);
pc.plotDecoding(decodingByOdor4s,'decodingByOdor4s')
pc.plotDecoding(decodingByOdor8s,'decodingByOdor8s')

lf=listF();
heatByOdor4s=sampleByType(lf.listDNMS4s,'odorZ','Average2Hz',-2,0.2,7,[200,0;200,0],1,1);
heatByOdor8s=sampleByType(lf.listDNMS8s,'odorZ','Average2Hz',-2,0.2,11,[200,0;200,0],1,1);
ph=plotHeat();
ph.binSize=2;
ph.delayCorrection=0;
ph.plot(heatByOdor8s,false,'HeatDNMS8s');
savefig('HeatDNMS8s.fig');
close all;
ph.plot(heatByOdor4s,false,'HeatDNMS4s');
savefig('HeatDNMS4s.fig');
close all;
convertFigs('HeatDNMS?s',true);


binSize=0.5;
selA=allByTypeDNMS('sample','Average2Hz',-2,0.5,12,true,false);
selB=allByTypeDNMS('sample','Average2Hz',-2,0.5,12,false,false);
selMatchA=allByTypeDNMS('match','Average2Hz',-2,0.5,12,true,false);
selMatchB=allByTypeDNMS('match','Average2Hz',-2,0.5,12,false,false);
selTestA=allByTypeDNMS('test','Average2Hz',-2,0.5,12,true,false);
selTestB=allByTypeDNMS('test','Average2Hz',-2,0.5,12,false,false);

[selMatchAError,seqA]=allByTypeDNMS('matchError','Average2Hz',-2,0.5,12,true,false);
[selMatchBError,seqB]=allByTypeDNMS('matchError','Average2Hz',-2,0.5,12,false,false);
inA=ismember(cell2mat(seqB(:,1)),cell2mat(seqA(:,1)),'rows');
selMatchBError=selMatchBError(inA,:);
save('sel2wayDNMS4s.mat','binSize','selA','selB','selTestA','selTestB','selMatchA','selMatchB','selMatchAError','selMatchBError');
sel2wayDNMS(4);
savefig('SelectivityDNMS4sSample.fig')
convertFigs('SelectivityDNMS4sSample')

selMatchAError=allByTypeDNMS('matchError','Average2Hz',3,0.5,12,true,false);
selMatchBError=allByTypeDNMS('matchError','Average2Hz',3,0.5,12,false,false);





binSize=0.5;
selA=allByTypeDNMS('sample','Average2Hz',2,0.5,16,true,true);
selB=allByTypeDNMS('sample','Average2Hz',2,0.5,16,false,true);
selTestA=allByTypeDNMS('test','Average2Hz',2,0.5,16,true,true);
selTestB=allByTypeDNMS('test','Average2Hz',2,0.5,16,false,true);
selMatchA=allByTypeDNMS('match','Average2Hz',2,0.5,16,true,true);
selMatchB=allByTypeDNMS('match','Average2Hz',2,0.5,16,false,true);
[selMatchAError,seqA]=allByTypeDNMS('matchError','Average2Hz',2,0.5,16,true,true);
[selMatchBError,seqB]=allByTypeDNMS('matchError','Average2Hz',2,0.5,16,false,true);
inA=ismember(cell2mat(seqB(:,1)),cell2mat(seqA(:,1)),'rows');
selMatchBError=selMatchBError(inA,:);
inB=ismember(cell2mat(seqA(:,1)),cell2mat(seqB(:,1)),'rows');
selMatchAError=selMatchAError(inB,:);

save('sel2wayDNMS8s.mat','binSize','selA','selB','selTestA','selTestB','selMatchA','selMatchB','selMatchAError','selMatchBError');
sel2wayDNMS(8);
savefig('SelectivityDNMS8sSample.fig')
convertFigs('SelectivityDNMS8sSample')






heatByOdor4s=sampleByType(lf.listDNMS4s,'odorZ','Average2Hz',-2,0.2,7,[200,0;200,0],1,1);
heatByOdor8s=sampleByType(lf.listDNMS8s,'odorZ','Average2Hz',-2,0.2,11,[200,0;200,0],1,1);




% clear java;
lf=listF();
heatByMatch4s=sampleByType(lf.listDNMS4s,'MatchZ','Average2Hz',3,0.2,12,[200,0;200,0],1,1);
heatByMatch8s=sampleByType(lf.listDNMS8s,'MatchZ','Average2Hz',7,0.2,16,[200,0;200,0],1,1);
mod=[heatByMatch4s;heatByMatch8s];
mod=permute(mod,[3 1 2]);
for i=1:size(mod,2)
    mod(:,i)=smooth(mod(:,i));
end
modB=shiftdim(mod,-1);
modB=permute(modB,[3,1,2]);
mod=modB;
ph=plotHeat;
ph.importIdx=false;
ph.sortBy='match';
ph.plot(mod,false,'heatByMatch')
xlim([0.5,34.5])
ph.importIdx=true;

lf=listF();
heatByMatch8sError=sampleByType(lf.listDNMS8s,'MatchErrorZ','Average2Hz',7,0.2,16,[200,0;200,0],1,1);
heatByMatch4sError=sampleByType(lf.listDNMS4s,'MatchErrorZ','Average2Hz',3,0.2,12,[200,0;200,0],1,1);
% ph=plotHeat;
% ph.sortBy='decision';
ph.plot([heatByMatch4sError;heatByMatch8sError],false,'heatByMatchError')



mod=[heatByMatch4sError;heatByMatch8sError];
mod=permute(mod,[3 1 2]);
for i=1:size(mod,2)
    mod(:,i)=smooth(mod(:,i));
end
modB=shiftdim(mod,-1);
modB=permute(modB,[3,1,2]);
mod=modB;
mod(mod>2.9 & mod<100)=2.9;
ph.plot(mod,false,'heatByMatchError')
xlim([0.5,34.5])
colormap(cmap);

[p,fr,frz]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],0);
% [pL3,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],-0.75);
[pL2,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],-0.5);
[pL1,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],-0.25);
[pR1,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],0.25);
[pR2,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],0.5);
% [pR3,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],0.75);
[pRS,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],'r');
bar([sum(pL2(:,1)<0.05)./size(p,1),sum(pL1(:,1)<0.05)./size(p,1),sum(p(:,1)<0.05)./size(p,1),sum(pR1(:,1)<0.05)./size(p,1),sum(pR2(:,1)<0.05)./size(p,1),sum(pRS(:,1)<0.05)./size(p,1)],'FaceColor','k');

set(gcf,'Color','w','Position',[100,100,330,80]);
set(gca,'XTickLabel',-0.5:0.25:0.75);
[tab,chi2,chisqP]=crosstab([ones(size(p,1),1);ones(size(p,1),1)*2;ones(size(p,1),1)*3;ones(size(p,1),1)*4;ones(size(p,1),1)*5;ones(size(p,1),1)*6],...
    [p(:,1)<0.05;pL2(:,1)<0.05;pL1(:,1)<0.05;pR1(:,1)<0.05;pR2(:,1)<0.05;pRS(:,1)<0.05]);
xlim([0,7]);
set(gca,'box','off');

lf=listF();
decodingByMatch4sCorrect=sampleByType(lf.listDNMS4s,'Match','Average2Hz',4,0.5,12,[30,1;30,1],500,1);
decodingByMatch8sCorrect=sampleByType(lf.listDNMS8s,'Match','Average2Hz',8,0.5,16,[30,1;30,1],500,1);
decodingCorrect=[decodingByMatch4sCorrect;decodingByMatch8sCorrect];
decodingByMatch4sError=sampleByType(lf.listDNMS4s,'MatchError','Average2Hz',4,0.5,12,[30,1;30,1],500,1);
decodingByMatch8sError=sampleByType(lf.listDNMS8s,'MatchError','Average2Hz',8,0.5,16,[30,1;30,1],500,1);
decodingError=[decodingByMatch4sError;decodingByMatch8sError];
pcd=plotCrossDecoding;
noTrialIdx=(decodingError(:,1,1)<10000);
pcd.plotDecoding(decodingCorrect(noTrialIdx,:,:),decodingError(noTrialIdx,:,:),'crossDecode')






decodingByOdor4s=sampleByType(lf.listDNMS4s,'sample','Average2Hz',-1,0.5,7,[30,1;30,1],500,1);
decodingByOdor8s=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-1,0.5,7,[30,1;30,1],500,1);
decodingByOdor4sError=sampleByType(lf.listDNMS4s,'sampleError','Average2Hz',-1,0.5,7,[30,1;30,1],500,1);
decodingByOdor8sError=sampleByType(lf.listDNMS8s,'sampleError','Average2Hz',-1,0.5,7,[30,1;30,1],500,1);
error=[decodingByOdor4sError;decodingByOdor8sError];
correct=[decodingByOdor4s;decodingByOdor8s];
pcd=plotCrossDecoding;
noTrialIdx=(error(:,1,1)<10000);
pcd.plotDecoding(correct(noTrialIdx,:,:),error(noTrialIdx,:,:),'crossDecode')






decodingByOdor4s=sampleByType(lf.listDNMS4s,'test','Average2Hz',4,0.5,12,[30,1;30,1],500,1);
decodingByOdor8s=sampleByType(lf.listDNMS8s,'test','Average2Hz',8,0.5,16,[30,1;30,1],500,1);
decodingByOdor4sError=sampleByType(lf.listDNMS4s,'testError','Average2Hz',4,0.5,12,[30,1;30,1],500,1);
decodingByOdor8sError=sampleByType(lf.listDNMS8s,'testError','Average2Hz',8,0.5,16,[30,1;30,1],500,1);
error=[decodingByOdor4sError;decodingByOdor8sError];
correct=[decodingByOdor4s;decodingByOdor8s];
pcd=plotCrossDecoding;
noTrialIdx=(error(:,1,1)<10000);
pcd.plotDecoding(correct(noTrialIdx,:,:),error(noTrialIdx,:,:),'crossDecode')
pcd.plotDecoding(correct(noTrialIdx,:,:),correct(noTrialIdx,:,:),'crossDecode')



lf=listF();
decodingByOdor4sMatch=sampleByType(lf.listDNMS4s,'matchTest','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
decodingByOdor4sNonm=sampleByType(lf.listDNMS4s,'nonmatchTest','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
decodingByOdor4sMatchError=sampleByType(lf.listDNMS4s,'matchTestError','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
decodingByOdor4sNonmError=sampleByType(lf.listDNMS4s,'nonmatchTest','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);

noTrialIdx=(decodingByOdor4sMatchError(:,1,1)<10000 & decodingByOdor4sNonmError(:,1,1)<10000);

pcd=plotCrossDecoding;

pcd.plotDecoding(decodingByOdor4sMatch,decodingByOdor4sMatch,4,'crossDecode')
pcd.plotDecoding(decodingByOdor4sMatch,decodingByOdor4sNonm,4,'crossDecode')
pcd.plotDecoding(decodingByOdor4sMatch(noTrialIdx,:,:),decodingByOdor4sMatchError(noTrialIdx,:,:),4,'crossDecode')
pcd.plotDecoding(decodingByOdor4sMatch(noTrialIdx,:,:),decodingByOdor4sNonmError(noTrialIdx,:,:),4,'crossDecode')




lf=listF();
decodingByOdor8sMatch=sampleByType(lf.listDNMS8s,'matchTest','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
decodingByOdor8sNonm=sampleByType(lf.listDNMS8s,'nonmatchTest','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
decodingByOdor8sMatchError=sampleByType(lf.listDNMS8s,'matchTestError','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
decodingByOdor8sNonmError=sampleByType(lf.listDNMS8s,'nonmatchTest','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);

noTrialIdx=(decodingByOdor8sMatchError(:,1,1)<10000 & decodingByOdor8sNonmError(:,1,1)<10000);

pcd=plotCrossDecoding;

pcd.plotDecoding(decodingByOdor8sMatch,decodingByOdor8sMatch,8,'crossDecode')
pcd.plotDecoding(decodingByOdor8sMatch,decodingByOdor8sNonm,8,'crossDecode')
pcd.plotMerged(decodingByOdor8sMatch(noTrialIdx,:,:),decodingByOdor8sMatchError(noTrialIdx,:,:),8,'crossDecode')
pcd.plotDecoding(decodingByOdor8sMatch(noTrialIdx,:,:),decodingByOdor8sNonmError(noTrialIdx,:,:),8,'crossDecode')



lf=listF();
decodingByOdor4sMatch=sampleByType(lf.listDNMS4s,'matchSample','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
decodingByOdor4sNonm=sampleByType(lf.listDNMS4s,'nonmatchSample','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
decodingByOdor4sMatchError=sampleByType(lf.listDNMS4s,'matchSampleError','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
decodingByOdor4sNonmError=sampleByType(lf.listDNMS4s,'nonmatchSample','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);

noTrialIdx=(decodingByOdor4sMatchError(:,1,1)<10000 & decodingByOdor4sNonmError(:,1,1)<10000);

pcd=plotCrossDecoding;

pcd.plotDecoding(decodingByOdor4sMatch,decodingByOdor4sMatch,4,'crossDecode')
pcd.plotMerged(decodingByOdor4sMatch,decodingByOdor4sNonm,4,'crossDecode')
pcd.plotDecoding(decodingByOdor4sMatch(noTrialIdx,:,:),decodingByOdor4sMatchError(noTrialIdx,:,:),4,'crossDecode')
pcd.plotMerged(decodingByOdor4sMatch(noTrialIdx,:,:),decodingByOdor4sNonmError(noTrialIdx,:,:),4,'crossDecode')




lf=listF();
decodingByOdor8sMatch=sampleByType(lf.listDNMS8s,'matchSample','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
decodingByOdor8sNonm=sampleByType(lf.listDNMS8s,'nonmatchSample','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
decodingByOdor8sMatchError=sampleByType(lf.listDNMS8s,'matchSampleError','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
decodingByOdor8sNonmError=sampleByType(lf.listDNMS8s,'nonmatchSample','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);

noTrialIdx=(decodingByOdor8sMatchError(:,1,1)<10000 & decodingByOdor8sNonmError(:,1,1)<10000);

pcd=plotCrossDecoding;

pcd.plotDecoding(decodingByOdor8sMatch,decodingByOdor8sMatch,8,'crossDecode')
pcd.plotDecoding(decodingByOdor8sMatch,decodingByOdor8sNonm,8,'crossDecode')
pcd.plotDecoding(decodingByOdor8sMatch(noTrialIdx,:,:),decodingByOdor8sMatchError(noTrialIdx,:,:),8,'crossDecode')
pcd.plotDecoding(decodingByOdor8sMatch(noTrialIdx,:,:),decodingByOdor8sNonmError(noTrialIdx,:,:),8,'crossDecode')




lf=listF();
heatByOdor4sMatch=sampleByType(lf.listDNMS4s,'matchSampleZ','Average2Hz',-2,0.2,12,[200,0;200,0],1,1);
heatByOdor4sNonm=sampleByType(lf.listDNMS4s,'nonmatchSampleZ','Average2Hz',-2,0.2,12,[200,0;200,0],1,1);
heatByOdor4sMatchError=sampleByType(lf.listDNMS4s,'matchSampleErrorZ','Average2Hz',-2,0.2,12,[200,0;200,0],1,1);
heatByOdor4sNonmError=sampleByType(lf.listDNMS4s,'nonmatchSampleErrorZ','Average2Hz',-2,0.2,12,[200,0;200,0],1,1);

ph=plotHeat();
ph.delayCorrection=5;

ph.plot(heatByOdor4sMatch,false,'heatByOdor4sMatch')
ph.importIdx=true;
ph.plot(heatByOdor4sNonm,false,'heatByOdor4sMatch')
ph.smooth=true;
heatByOdor4sMatchError(heatByOdor4sMatchError>2.9 & heatByOdor4sMatchError<10000)=2.9;
heatByOdor4sNonmError(heatByOdor4sNonmError>2.9 & heatByOdor4sNonmError<10000)=2.9;
cmap=colormap('jet');
cmap(end,:)=[1,1,1];
ph.plot(heatByOdor4sMatchError,false,'heatByOdor4sMatch')
colormap(cmap);
ph.plot(heatByOdor4sNonmError,false,'heatByOdor4sMatch')
colormap(cmap);



lf=listF();
heatByOdor8sMatch=sampleByType(lf.listDNMS8s,'matchSampleZ','Average2Hz',-2,0.2,16,[200,0;200,0],1,1);
heatByOdor8sNonm=sampleByType(lf.listDNMS8s,'nonmatchSampleZ','Average2Hz',-2,0.2,16,[200,0;200,0],1,1);
heatByOdor8sMatchError=sampleByType(lf.listDNMS8s,'matchSampleErrorZ','Average2Hz',-2,0.2,16,[200,0;200,0],1,1);
heatByOdor8sNonmError=sampleByType(lf.listDNMS8s,'nonmatchSampleErrorZ','Average2Hz',-2,0.2,16,[200,0;200,0],1,1);

ph=plotHeat();
ph.delayCorrection=5;
ph.plot(heatByOdor8sMatch,false,'heatByOdor8sMatch')
ph.importIdx=true;
ph.plot(heatByOdor8sNonm,false,'heatByOdor8sMatch')
ph.smooth=true;
heatByOdor8sMatchError(heatByOdor8sMatchError>2.9 & heatByOdor8sMatchError<10000)=2.9;
heatByOdor8sNonmError(heatByOdor8sNonmError>2.9 & heatByOdor8sNonmError<10000)=2.9;
cmap=colormap('jet');
cmap(end,:)=[1,1,1];
ph.plot(heatByOdor8sMatchError,false,'heatByOdor8sMatch')
colormap(cmap);
ph.plot(heatByOdor8sNonmError,false,'heatByOdor8sMatch')
colormap(cmap);


[~,~,selId]=sel2wayDNMS(4);
ph=plotHeat();
ph.delayCorrection=5;
ph.sortBy='match';
matchId=selId(:,15)==4 & selId(:,16)==4;
ph.plot(heatByOdor4sNonm(matchId,:,:),false,'heatByOdor8sMatch')
ph.importIdx=true;
ph.plot(heatByOdor4sMatch(matchId,:,:),false,'heatByOdor8sMatch')
ph.smooth=true;
heatByOdor4sMatchError(heatByOdor4sMatchError>2.9 & heatByOdor4sMatchError<10000)=2.9;
heatByOdor4sNonmError(heatByOdor4sNonmError>2.9 & heatByOdor4sNonmError<10000)=2.9;
cmap=colormap('jet');
cmap(end,:)=[1,1,1];
ph.plot(heatByOdor4sNonmError(matchId,:,:),false,'heatByOdor4sMatch')
colormap(cmap);
ph.plot(heatByOdor4sMatchError(matchId,:,:),false,'heatByOdor4sMatch')
colormap(cmap);

%%%%%%%%%%%%%%%%%%%
%%% curve 4s %%%%%%
%%%%%%%%%%%%%%%%%%%

[~,~,selId]=sel2wayDNMS(4);
ph=plotHeat();
ph.delayCorrection=5;
ph.sortBy='matchCurve';
matchId=selId(:,15)>=4 & selId(:,16)>=4;
nc=ph.genCurve(heatByOdor4sNonm(matchId,:,:));
ph.importIdx=true;
mc=ph.genCurve(heatByOdor4sMatch(matchId,:,:));
heatByOdor4sMatchError(heatByOdor4sMatchError>10000)=nan;
heatByOdor4sNonmError(heatByOdor4sNonmError>10000)=nan;
ne=ph.genCurve(heatByOdor4sNonmError(matchId,:,:));
me=ph.genCurve(heatByOdor4sMatchError(matchId,:,:));

figure('Color','w','Position',[100,100,350,240]);
hold on;
plot(nc,'ro','LineWidth',1,'MarkerFaceColor','r');
plot(mc,'ko','LineWidth',1,'MarkerFaceColor','k');
plot(ne,'ro','LineWidth',2,'MarkerFaceColor','none');
plot(me,'ko','LineWidth',2,'MarkerFaceColor','none');
xlim([0,length(nc)+1]);
xlabel('Neuron No.');
ylabel('Normalized firing rate (Z-score)');



%%%%%%%%%%%%%%%%%%%
%%% curve 8s %%%%%%
%%%%%%%%%%%%%%%%%%%

[~,~,selId]=sel2wayDNMS(8);
ph=plotHeat();
ph.delayCorrection=5;
ph.sortBy='matchCurve';
matchId=selId(:,23)==4 & selId(:,24)==4;
nc=ph.genCurve(heatByOdor8sNonm(matchId,:,:));
ph.importIdx=true;
mc=ph.genCurve(heatByOdor8sMatch(matchId,:,:));
heatByOdor8sMatchError(heatByOdor8sMatchError>10000)=nan;
heatByOdor8sNonmError(heatByOdor8sNonmError>10000)=nan;
ne=ph.genCurve(heatByOdor8sNonmError(matchId,:,:));
me=ph.genCurve(heatByOdor8sMatchError(matchId,:,:));

figure('Color','w','Position',[100,100,350,240]);
hold on;
hnc=plot(nc,'ro','LineWidth',1,'MarkerFaceColor','r');
hmc=plot(mc,'ko','LineWidth',1,'MarkerFaceColor','k');
hne=plot(ne,'ro','LineWidth',2,'MarkerFaceColor','none');
hme=plot(me,'ko','LineWidth',2,'MarkerFaceColor','none');
xlim([0,length(nc)+1]);
xlabel('Neuron No.');
ylabel('Normalized firing rate (Z-score)');
legend([hnc,hmc,hne,hme],{'Non-match correct','Match correct','Non-match error','Match error'});




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% n way selectivity  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

binSize=0.5;
selA=allByTypeDNMS('sample','Average2Hz',-2,binSize,12,true,false);
selB=allByTypeDNMS('sample','Average2Hz',-2,binSize,12,false,false);
selMatchA=allByTypeDNMS('match','Average2Hz',-2,binSize,12,true,false);
selMatchB=allByTypeDNMS('match','Average2Hz',-2,binSize,12,false,false);
selTestA=allByTypeDNMS('test','Average2Hz',-2,binSize,12,true,false);
selTestB=allByTypeDNMS('test','Average2Hz',-2,binSize,12,false,false);

[selMatchAError,seqA]=allByTypeDNMS('matchError','Average2Hz',-2,binSize,12,true,false);
[selMatchBError,seqB]=allByTypeDNMS('matchError','Average2Hz',-2,binSize,12,false,false);
inA=ismember(cell2mat(seqB(:,1)),cell2mat(seqA(:,1)),'rows');
selMatchBError=selMatchBError(inA,:);
save('sel2wayDNMS4s.mat','binSize','selA','selB','selTestA','selTestB','selMatchA','selMatchB','selMatchAError','selMatchBError');

% binSize=1;
selA=allByTypeDNMS('sample','Average2Hz',-2,binSize,16,true,true);
selB=allByTypeDNMS('sample','Average2Hz',-2,binSize,16,false,true);
selTestA=allByTypeDNMS('test','Average2Hz',-2,binSize,16,true,true);
selTestB=allByTypeDNMS('test','Average2Hz',-2,binSize,16,false,true);
selMatchA=allByTypeDNMS('match','Average2Hz',-2,binSize,16,true,true);
selMatchB=allByTypeDNMS('match','Average2Hz',-2,binSize,16,false,true);
[selMatchAError,seqA]=allByTypeDNMS('matchError','Average2Hz',-2,binSize,16,true,true);
[selMatchBError,seqB]=allByTypeDNMS('matchError','Average2Hz',-2,binSize,16,false,true);
inA=ismember(cell2mat(seqB(:,1)),cell2mat(seqA(:,1)),'rows');
selMatchBError=selMatchBError(inA,:);
inB=ismember(cell2mat(seqA(:,1)),cell2mat(seqB(:,1)),'rows');
selMatchAError=selMatchAError(inB,:);

save('sel2wayDNMS8s.mat','binSize','selA','selB','selTestA','selTestB','selMatchA','selMatchB','selMatchAError','selMatchBError');


[~,~,selId]=sel2wayDNMS(8);
ph=plotHeat();
ph.delayCorrection=5;
ph.sortBy='match';
matchId=selId(:,23)>=4 & selId(:,24)>=4;
ph.plot(heatByOdor8sNonm(matchId,:,:),false,'heatByOdor8sMatch')
ph.importIdx=true;
ph.plot(heatByOdor8sMatch(matchId,:,:),false,'heatByOdor8sMatch')
ph.smooth=true;
heatByOdor8sMatchError(heatByOdor8sMatchError>2.9 & heatByOdor8sMatchError<10000)=2.9;
heatByOdor8sNonmError(heatByOdor8sNonmError>2.9 & heatByOdor8sNonmError<10000)=2.9;
cmap=colormap('jet');
cmap(end,:)=[1,1,1];
ph.plot(heatByOdor8sNonmError(matchId,:,:),false,'heatByOdor8sMatch')
colormap(cmap);
ph.plot(heatByOdor8sMatchError(matchId,:,:),false,'heatByOdor8sMatch')
colormap(cmap);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Sep By Match Index  %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lf=listF();

[~,~,selId4]=sel2wayDNMS(4,[],true);
[~,~,selId8]=sel2wayDNMS(8,[],true);

heatByOdor4sMatch=sampleByType(lf.listDNMS4s,'matchSample','Average2Hz',-2,1,12,[200,0;200,0],1,1);
heatByOdor4sNonm=sampleByType(lf.listDNMS4s,'nonmatchSample','Average2Hz',-2,1,12,[200,0;200,0],1,1);
heatByOdor4sMatchError=sampleByType(lf.listDNMS4s,'matchSampleError','Average2Hz',-2,1,12,[200,0;200,0],1,1);
heatByOdor4sNonmError=sampleByType(lf.listDNMS4s,'nonmatchSampleError','Average2Hz',-2,1,12,[200,0;200,0],1,1);

heatByOdor8sMatch=sampleByType(lf.listDNMS8s,'matchSample','Average2Hz',-2,1,16,[200,0;200,0],1,1);
heatByOdor8sNonm=sampleByType(lf.listDNMS8s,'nonmatchSample','Average2Hz',-2,1,16,[200,0;200,0],1,1);
heatByOdor8sMatchError=sampleByType(lf.listDNMS8s,'matchSampleError','Average2Hz',-2,1,16,[200,0;200,0],1,1);
heatByOdor8sNonmError=sampleByType(lf.listDNMS8s,'nonmatchSampleError','Average2Hz',-2,1,16,[200,0;200,0],1,1);



mNmIndex([heatByOdor4sMatch;trans8s(heatByOdor8sMatch)],[heatByOdor4sNonm;trans8s(heatByOdor8sNonm)],...
    [heatByOdor4sMatchError;trans8s(heatByOdor8sMatchError)],[heatByOdor4sNonmError;trans8s(heatByOdor8sNonmError)],...
    [selId4;selId8(:,5:end)],true,4);

mNmIndex([heatByOdor4sMatch],[heatByOdor4sNonm],...
    [heatByOdor4sMatchError],[heatByOdor4sNonmError],...
    [selId4],false,4);


[~,~,selId4]=sel2wayDNMS(4,[],false);
[~,~,selId8]=sel2wayDNMS(8,[],false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% sample cross decode %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lf=listF();
decodingByOdor4s=sampleByType(lf.listDNMS4s,'sample','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
decodingByOdor4sError=sampleByType(lf.listDNMS4s,'sampleError','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
valid4=decodingByOdor4sError(:,1,1)<65500;

pcd=plotCrossDecoding;
pcd.plotDecoding(decodingByOdor4s(valid4,:,:),decodingByOdor4sError(valid4,:,:),4,'crossDecode4s');

pb=0;
dc=0;
while pb<0.05 && dc<20
    decodingByOdor8s=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
    decodingByOdor8sError=sampleByType(lf.listDNMS8s,'sampleError','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
    valid8=decodingByOdor8sError(:,1,1)<65500;
    pc=0;
    while pb<0.05 && pc<50
        close all;
        pb=pcd.plotDecoding(decodingByOdor8s(valid8,:,:),decodingByOdor8sError(valid8,:,:),8,'crossDecode8s');
        disp(pb);
        pc=pc+1;
    end
    dc=dc+1;
end
