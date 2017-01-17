lf=listF();
trajectoryByOdor4s=sampleByType(lf.listDNMS4s,'odor','Average2Hz',-2,0.5,7+9,[20,20;20,20],100,1);
trajectoryByOdor8s=sampleByType(lf.listDNMS8s,'odor','Average2Hz',-2,0.5,11+9,[20,20;20,20],100,1);
pc=plotCurve;
pc.binSize=0.5;
pc.plotTrajectory(trajectoryByOdor8s,'trajectoryByOdor8s',1:20);
pc.plotTrajectory(trajectoryByOdor4s,'trajectoryByOdor4s',1:20);
convertFigs('trajectoryByOdor?s');








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
selA=allByTypeDNMS('odor','Average2Hz',-2,0.5,16,true,true);
selB=allByTypeDNMS('odor','Average2Hz',-2,0.5,16,false,true);
selTestA=allByTypeDNMS('test','Average2Hz',-2,0.5,16,true,true);
selTestB=allByTypeDNMS('test','Average2Hz',-2,0.5,16,false,true);
selMatchA=allByTypeDNMS('match','Average2Hz',-2,0.5,16,true,true);
selMatchB=allByTypeDNMS('match','Average2Hz',-2,0.5,16,false,true);
[selMatchAError,seqA]=allByTypeDNMS('matchError','Average2Hz',-2,0.5,16,true,true);
[selMatchBError,seqB]=allByTypeDNMS('matchError','Average2Hz',-2,0.5,16,false,true);
inA=ismember(cell2mat(seqB(:,1)),cell2mat(seqA(:,1)),'rows');
selMatchBError=selMatchBError(inA,:);
inB=ismember(cell2mat(seqA(:,1)),cell2mat(seqB(:,1)),'rows');
selMatchAError=selMatchAError(inB,:);

save('sel2wayDNMS8s.mat','binSize','selA','selB','selTestA','selTestB','selMatchA','selMatchB','selMatchAError','selMatchBError');
sel2wayDNMS(8);
savefig('SelectivityDNMS8sSample.fig')
convertFigs('SelectivityDNMS8sSample')
