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
selA=allByTypeDNMS('odor','Average2Hz',-2,0.5,12,true,false);
selB=allByTypeDNMS('odor','Average2Hz',-2,0.5,12,false,false);
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
selA=allByTypeDNMS('odor','Average2Hz',2,0.5,16,true,true);
selB=allByTypeDNMS('odor','Average2Hz',2,0.5,16,false,true);
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
[pL3,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],-0.75);
[pL2,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],-0.5);
[pL1,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],-0.25);
[pR1,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],0.25);
[pR2,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],0.5);
[pR3,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],0.75);
bar([sum(pL2(:,1)<0.05)./size(p,1),sum(pL1(:,1)<0.05)./size(p,1),sum(p(:,1)<0.05)./size(p,1),sum(pR1(:,1)<0.05)./size(p,1),sum(pR2(:,1)<0.05)./size(p,1)],'FaceColor','k');

set(gcf,'Color','w','Position',[100,100,330,60]);
set(gca,'XTickLabel',[-0.5:0.25:0.5]);
[tab,chi2,chisqP]=crosstab([ones(size(p,1),1);ones(size(p,1),1)*2;ones(size(p,1),1)*3;ones(size(p,1),1)*4;ones(size(p,1),1)*5],[p(:,1)<0.05;pL2(:,1)<0.05;pL1(:,1)<0.05;pR1(:,1)<0.05;pR2(:,1)<0.05]);
