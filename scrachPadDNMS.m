pause();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Trajectory Disntace %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lf=listF();
pc=plotCurve;
trajectoryByOdor4s=sampleByType(lf.listDNMS4s,'sample','Average2Hz',-2,0.5,7,[20,20;20,20],100,1);
trajectoryByOdor8s=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-2,0.5,11,[20,20;20,20],100,1);
pc.binSize=0.5;
pc.plotTrajectory(trajectoryByOdor8s,'trajectoryByOdor8s',1:20,22);
pc.plotTrajectory(trajectoryByOdor4s,'trajectoryByOdor4s',1:20,14);

[decodingByOdor4s,tags]=sampleByType(lf.listDNMS4s,'sample','Average2Hz',-2,0.5,7,[30,1;30,1],500,true);
decodingByOdor8s=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-2,0.5,11,[30,1;30,1],500,true);
pc.plotDecoding(decodingByOdor4s,'decodingByOdor4s','dynamic');
pc.plotDecoding(decodingByOdor8s,'decodingByOdor8s','dynamic');

tagsExp=cell(0,0);
for i=1:length(tags)
    for u=1:size(tags{i,2},1)
        tagsExp=[tagsExp;{tags{i,1},tags{i,2}(u,:)}];
    end
end

transientIdx=p(transient,1);
transientSel=false(size(tagsExp,1),1);
for i=1:size(tagsExp,1)
    for j=1:size(transientIdx,1)
        if all(tagsExp{i,2}==transientIdx{j}{2}) && strcmp(tagsExp{i,1},transientIdx{j}{1})
            transientSel(i)=true;
            continue;
        end
    end
end
pc.plotDecoding(decodingByOdor4s(transientSel,:,:),'decodingByOdor4s_only_transient','dynamic');
xlim([0.5,14])
savefig(gcf,'decodingByOdor4s_only_transient.fig','compact');


sustIdx=p(sust,1);
sustSel=false(size(tagsExp,1),1);
for i=1:size(tagsExp,1)
    for j=1:size(sustIdx,1)
        if all(tagsExp{i,2}==sustIdx{j}{2}) && strcmp(tagsExp{i,1},sustIdx{j}{1})
            sustSel(i)=true;
            continue;
        end
    end
end
pc.plotDecoding(decodingByOdor4s(sustSel,:,:),'decodingByOdor4s_only_sustained','dynamic');
xlim([0.5,14])
savefig(gcf,'decodingByOdor4s_only_sustained.fig','compact');


pc.plotDecoding(decodingByOdor4s(~(sustSel | transientSel),:,:),'decodingByOdor4s_noIm','dynamic');
xlim([0.5,14])
savefig(gcf,'decodingByOdor4s_noImA.fig','compact');




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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% sel2wayDNMS  %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% selNwayDNMS %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

binSize=0.5;
selA=allByTypeDNMS('sample','Average2Hz',-2,binSize,12,true,4,true);
selB=allByTypeDNMS('sample','Average2Hz',-2,binSize,12,false,4,true);
selMatchA=allByTypeDNMS('match','Average2Hz',-2,binSize,12,true,4,true);
selMatchB=allByTypeDNMS('match','Average2Hz',-2,binSize,12,false,4,true);
selTestA=allByTypeDNMS('test','Average2Hz',-2,binSize,12,true,4,true);
selTestB=allByTypeDNMS('test','Average2Hz',-2,binSize,12,false,4,true);

[selMatchAError,seqA]=allByTypeDNMS('matchError','Average2Hz',-2,binSize,12,true,4,true);
[selMatchBError,seqB]=allByTypeDNMS('matchError','Average2Hz',-2,binSize,12,false,4,true);
inA=ismember(cell2mat(seqB(:,1)),cell2mat(seqA(:,1)),'rows');
selMatchBError=selMatchBError(inA,:);
save('sel2wayDNMS4s.mat','binSize','selA','selB','selTestA','selTestB','selMatchA','selMatchB','selMatchAError','selMatchBError');
% sel2wayDNMS(4);
% savefig('SelectivityDNMS4sSample.fig')
% convertFigs('SelectivityDNMS4sSample')
% 
% selMatchAError=allByTypeDNMS('matchError','Average2Hz',3,0.5,12,true,4,true);
% selMatchBError=allByTypeDNMS('matchError','Average2Hz',3,0.5,12,false,4,true);





binSize=0.5;
selA=allByTypeDNMS('sample','Average2Hz',-2,binSize,16,true,8,true);
selB=allByTypeDNMS('sample','Average2Hz',-2,binSize,16,false,8,true);
selTestA=allByTypeDNMS('test','Average2Hz',-2,binSize,16,true,8,true);
selTestB=allByTypeDNMS('test','Average2Hz',-2,binSize,16,false,8,true);
selMatchA=allByTypeDNMS('match','Average2Hz',-2,binSize,16,true,8,true);
selMatchB=allByTypeDNMS('match','Average2Hz',-2,binSize,16,false,8,true);
[selMatchAError,seqA]=allByTypeDNMS('matchError','Average2Hz',-2,binSize,16,true,8,true);
[selMatchBError,seqB]=allByTypeDNMS('matchError','Average2Hz',-2,binSize,16,false,8,true);
inA=ismember(cell2mat(seqB(:,1)),cell2mat(seqA(:,1)),'rows');
selMatchBError=selMatchBError(inA,:);
inB=ismember(cell2mat(seqA(:,1)),cell2mat(seqB(:,1)),'rows');
selMatchAError=selMatchAError(inB,:);

save('sel2wayDNMS8s.mat','binSize','selA','selB','selTestA','selTestB','selMatchA','selMatchB','selMatchAError','selMatchBError');
% sel2wayDNMS(8);
% savefig('SelectivityDNMS8sSample.fig')
% convertFigs('SelectivityDNMS8sSample')

binSize=0.5;
selA=allByTypeDNMS('sampleAll','Average2Hz',-2,binSize,13,true,5,false);
selB=allByTypeDNMS('sampleAll','Average2Hz',-2,binSize,13,false,5,false);
save('sel2wayDNMS5s.mat','binSize','selA','selB');



heatByOdor4s=sampleByType(lf.listDNMS4s,'odorZ','Average2Hz',-2,0.2,7,[200,0;200,0],1,1);
heatByOdor8s=sampleByType(lf.listDNMS8s,'odorZ','Average2Hz',-2,0.2,11,[200,0;200,0],1,1);




% clear java;
lf=listF();
heatByMatch4s=sampleByType(lf.listDNMS4s,'MatchZ','Average2Hz',3,0.2,12,[200,0;200,0],1,1);
heatByMatch8s=sampleByType(lf.listDNMS8s,'MatchZ','Average2Hz',7,0.2,16,[200,0;200,0],1,1);
mod=[heatByMatch4s;heatByMatch8s];mod=permute(mod,[3 1 2]);
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
dc=0;
pl=0;
binSize=0.5;
while pl<0.05 && dc<10
    decodingByMatch4sCorrect=sampleByType(lf.listDNMS4s,'Match','Average2Hz',-2,binSize,12,[30,1;30,1],500,1);
    decodingByMatch8sCorrect=sampleByType(lf.listDNMS8s,'Match','Average2Hz',2,binSize,16,[30,1;30,1],500,1);
    decodingCorrect=[decodingByMatch4sCorrect;decodingByMatch8sCorrect];
    
    decodingByMatch4sError=sampleByType(lf.listDNMS4s,'MatchError','Average2Hz',-2,binSize,12,[30,1;30,1],500,1);
    decodingByMatch8sError=sampleByType(lf.listDNMS8s,'MatchError','Average2Hz',2,binSize,16,[30,1;30,1],500,1);
    decodingError=[decodingByMatch4sError;decodingByMatch8sError];
    
%     decodingByOdor4sShuffle=sampleByType(lf.listDNMS4s,'shuffleAll','Average2Hz',-2,binSize,12,[30,1;30,1],500,1);
%     decodingByOdor8sShuffle=sampleByType(lf.listDNMS8s,'shuffleAll','Average2Hz',2,binSize,16,[30,1;30,1],500,1);
%     decodingShuffle=[decodingByOdor4sShuffle;decodingByOdor8sShuffle];
%     
    decodingByOdor4sShuffle=sampleByType(lf.listDNMS4s,'shuffle','Average2Hz',-2,binSize,12,[30,1;30,1],500,1);
    decodingByOdor8sShuffle=sampleByType(lf.listDNMS8s,'shuffle','Average2Hz',2,binSize,16,[30,1;30,1],500,1);
    decodingShuffle=[decodingByOdor4sShuffle;decodingByOdor8sShuffle];
    

    
    pcd=plotCrossDecoding;
    noTrialIdx=(decodingError(:,1,1)<10000);

    pc=0;
    while pl<0.05 && pc<20
        [pb,pl]=pcd.plotDecoding(decodingCorrect(noTrialIdx,:,:),decodingError(noTrialIdx,:,:),decodingShuffle(noTrialIdx,:,:),4,21);
        pl=min(pb,pl);
    end
end



% 
% 
% decodingByOdor4s=sampleByType(lf.listDNMS4s,'sample','Average2Hz',-1,0.5,7,[30,1;30,1],500,1);
% decodingByOdor8s=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-1,0.5,7,[30,1;30,1],500,1);
% decodingByOdor4sError=sampleByType(lf.listDNMS4s,'sampleError','Average2Hz',-1,0.5,7,[30,1;30,1],500,1);
% decodingByOdor8sError=sampleByType(lf.listDNMS8s,'sampleError','Average2Hz',-1,0.5,7,[30,1;30,1],500,1);
%     
% error=[decodingByOdor4sError;decodingByOdor8sError];
% correct=[decodingByOdor4s;decodingByOdor8s];
% 
% decodingByOdor4sShuffle=sampleByType(lf.listDNMS4s,'shuffle','Average2Hz',-2,binSize,12,[30,1;30,1],500,1);
% decodingByOdor8sShuffle=sampleByType(lf.listDNMS8s,'shuffle','Average2Hz',2,binSize,16,[30,1;30,1],500,1);
% decodingShuffle=[decodingByOdor4sShuffle;decodingByOdor8sShuffle];
% 
% pcd=plotCrossDecoding;
% noTrialIdx=(error(:,1,1)<10000);
% pcd.plotDecoding(correct(noTrialIdx,:,:),error(noTrialIdx,:,:),decodingShuffle(noTrialIdx,:,:),4,21)
% 
% 
% 
% 
% 
% 
% decodingByOdor4s=sampleByType(lf.listDNMS4s,'test','Average2Hz',4,0.5,12,[30,1;30,1],500,1);
% decodingByOdor8s=sampleByType(lf.listDNMS8s,'test','Average2Hz',8,0.5,16,[30,1;30,1],500,1);
% decodingByOdor4sError=sampleByType(lf.listDNMS4s,'testError','Average2Hz',4,0.5,12,[30,1;30,1],500,1);
% decodingByOdor8sError=sampleByType(lf.listDNMS8s,'testError','Average2Hz',8,0.5,16,[30,1;30,1],500,1);
% error=[decodingByOdor4sError;decodingByOdor8sError];
% correct=[decodingByOdor4s;decodingByOdor8s];
% pcd=plotCrossDecoding;
% noTrialIdx=(error(:,1,1)<10000);
% pcd.plotDecoding(correct(noTrialIdx,:,:),error(noTrialIdx,:,:),'crossDecode')
% pcd.plotDecoding(correct(noTrialIdx,:,:),correct(noTrialIdx,:,:),'crossDecode')








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

binSize=1;
selA=allByTypeDNMS('sample','Average2Hz',-2,binSize,12,true,4,1);
selB=allByTypeDNMS('sample','Average2Hz',-2,binSize,12,false,4,1);
selMatchA=allByTypeDNMS('match','Average2Hz',-2,binSize,12,true,4,1);
selMatchB=allByTypeDNMS('match','Average2Hz',-2,binSize,12,false,4,1);
selTestA=allByTypeDNMS('test','Average2Hz',-2,binSize,12,true,4,1);
selTestB=allByTypeDNMS('test','Average2Hz',-2,binSize,12,false,4,1);

[selMatchAError,seqA]=allByTypeDNMS('matchError','Average2Hz',-2,binSize,12,true,4,1);
[selMatchBError,seqB]=allByTypeDNMS('matchError','Average2Hz',-2,binSize,12,false,4,1);
inA=ismember(cell2mat(seqB(:,1)),cell2mat(seqA(:,1)),'rows');
selMatchBError=selMatchBError(inA,:);
save('sel2wayDNMS4s.mat','binSize','selA','selB','selTestA','selTestB','selMatchA','selMatchB','selMatchAError','selMatchBError');

binSize=1;
selA=allByTypeDNMS('sample','Average2Hz',-2,binSize,16,true,8,1);
selB=allByTypeDNMS('sample','Average2Hz',-2,binSize,16,false,8,1);
selTestA=allByTypeDNMS('test','Average2Hz',-2,binSize,16,true,8,1);
selTestB=allByTypeDNMS('test','Average2Hz',-2,binSize,16,false,8,1);
selMatchA=allByTypeDNMS('match','Average2Hz',-2,binSize,16,true,8,1);
selMatchB=allByTypeDNMS('match','Average2Hz',-2,binSize,16,false,8,1);
[selMatchAError,seqA]=allByTypeDNMS('matchError','Average2Hz',-2,binSize,16,true,8,1);
[selMatchBError,seqB]=allByTypeDNMS('matchError','Average2Hz',-2,binSize,16,false,8,1);
inA=ismember(cell2mat(seqB(:,1)),cell2mat(seqA(:,1)),'rows');
selMatchBError=selMatchBError(inA,:);
inB=ismember(cell2mat(seqA(:,1)),cell2mat(seqB(:,1)),'rows');
selMatchAError=selMatchAError(inB,:);

save('sel2wayDNMS8s.mat','binSize','selA','selB','selTestA','selTestB','selMatchA','selMatchB','selMatchAError','selMatchBError');



binSize=0.5;
[selA,seqA]=allByTypeDNMS('matchincincorr','Average2Hz',-2,binSize,13,true,5);
[selB,seqB]=allByTypeDNMS('matchincincorr','Average2Hz',-2,binSize,13,false,5);
selMatchA=selA;
selMatchB=selB;
selTestA=selA;
selTestB=selB;

selMatchAError=selA;
selMatchBError=selB;
inA=ismember(cell2mat(seqB(:,1)),cell2mat(seqA(:,1)),'rows');
selMatchBError=selMatchBError(inA,:);
inB=ismember(cell2mat(seqA(:,1)),cell2mat(seqB(:,1)),'rows');
selMatchAError=selMatchAError(inB,:);


save('sel2wayDNMS5s.mat','binSize','selA','selB','selTestA','selTestB','selMatchA','selMatchB','selMatchAError','selMatchBError');
















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



mNmIndex([heatByOdor4sMatch;trans8s(heatByOdor8sMatch,1,1)],[heatByOdor4sNonm;trans8s(heatByOdor8sNonm,1,1)],...
    [heatByOdor4sMatchError;trans8s(heatByOdor8sMatchError,1,1)],[heatByOdor4sNonmError;trans8s(heatByOdor8sNonmError,1,1)],...
    [selId4;selId8(:,5:end)],true,4);


[~,~,selId4]=sel2wayDNMS(4,[],false);
sel2wayDNMS(12,[],false);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% sample cross decode %%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pb=0;
% pll=0;
% dc=0;
% lf=listF();
% pcd=plotCrossDecoding;
% while (pb<0.05 || pl<0.001) && dc<20
% decodingByOdor4s=sampleByType(lf.listDNMS4s,'sample','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
% decodingByOdor4sError=sampleByType(lf.listDNMS4s,'sampleError','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
% valid4=decodingByOdor4sError(:,1,1)<65500;
%     pc=0;
%     while (pb<0.05 || pl<0.001) && pc<50
%         close all;
%         [pb,pl]=pcd.plotDecoding(decodingByOdor8s(valid8,:,:),decodingByOdor8sError(valid8,:,:),8,'crossDecode8s');
%         disp([pb);
%         pc=pc+1;
%     end
%     dc=dc+1;
% 
% pcd.plotDecoding(decodingByOdor4s(valid4,:,:),decodingByOdor4sError(valid4,:,:),4);
% xlim([0,14])
% end
% 
% pb=0;
% dc=0;
% while pb<0.05 && dc<20
%     decodingByOdor8s=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
%     decodingByOdor8sError=sampleByType(lf.listDNMS8s,'sampleError','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
%     valid8=decodingByOdor8sError(:,1,1)<65500;
%     pc=0;
%     while pb<0.05 && pc<50
%         close all;
%         pb=pcd.plotDecoding(decodingByOdor8s(valid8,:,:),decodingByOdor8sError(valid8,:,:),8,'crossDecode8s');
%         disp(pb);
%         pc=pc+1;
%     end
%     dc=dc+1;
% end
% 
% 
% %%%%%%%% combined late delay to response %%%%%%%%%%%%
% 
% lf=listF();
% decodingByOdor4s=sampleByType(lf.listDNMS4s,'sample','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
% decodingByOdor4sError=sampleByType(lf.listDNMS4s,'sampleError','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
% valid4=decodingByOdor4sError(:,1,1)<65500;
% 
% decodingByOdor8s=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
% decodingByOdor8sError=sampleByType(lf.listDNMS8s,'sampleError','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
% valid8=decodingByOdor8sError(:,1,1)<65500;
% 
% decodingCorrect=[decodingByOdor4s(valid4,:,:);trans8s(decodingByOdor8s(valid8,:,:),0.5,true)];
% decodingError=[decodingByOdor4sError(valid4,:,:);trans8s(decodingByOdor8sError(valid8,:,:),0.5,true)];
% 
% pcd=plotCrossDecoding;
% pcd.plotDecoding(decodingCorrect,decodingError,4);
% 
% % pcd.plotDecoding(decodingByOdor4s(valid4,:,:),decodingByOdor4sError(valid4,:,:),4);
% % 
% % pb=0;
% % dc=0;
% % while pb<0.05 && dc<20
% %     decodingByOdor8s=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
% %     decodingByOdor8sError=sampleByType(lf.listDNMS8s,'sampleError','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
% %     valid8=decodingByOdor8sError(:,1,1)<65500;
% %     pc=0;
% %     while pb<0.05 && pc<50
% %         close all;
% %         pb=pcd.plotDecoding(decodingByOdor8s(valid8,:,:),decodingByOdor8sError(valid8,:,:),8,'crossDecode8s');
% %         disp(pb);
% %         pc=pc+1;
% %     end
% %     dc=dc+1;
% % end
% 
% 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% DNMS sample decoding %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lf=listF();
pcd=plotCrossDecoding;
pb=0;
dc=0;
while (pb<0.05 ||  pl<0.001 || pl>=0.0015 )  && dc<20
    close all;
    decodingByOdor4s=sampleByType(lf.listDNMS4s,'sample','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
    [decodingByOdor4sError,seq4sError]=sampleByType(lf.listDNMS4s,'sampleError','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
    decodingByOdor4sShuffle=sampleByType(lf.listDNMS4s,'shuffle','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
    valid4=decodingByOdor4sError(:,1,1)<65500;
    pc=0;
    while (pb<0.05 || pl<0.001 || pl>=0.0015 ) && pc<50
         close all;
        [pb,pl]=pcd.plotDecoding(decodingByOdor4s(valid4,:,:),decodingByOdor4sError(valid4,:,:),decodingByOdor4sShuffle(valid4,:,:),4,21);
        disp([pb,pl]);
        pc=pc+1;
    end
    dc=dc+1;
end




lf=listF();
pcd=plotCrossDecoding;
pb=0;
dc=0;
while (pb<0.05 || pl>0.05 )  && dc<20
    close all;
    decodingByOdor8s=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
    [decodingByOdor8sError,seq8sError]=sampleByType(lf.listDNMS8s,'sampleError','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
    decodingByOdor8sShuffle=sampleByType(lf.listDNMS8s,'shuffle','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
    valid8=decodingByOdor8sError(:,1,1)<65500;
    pc=0;
     while (pb<0.05 || pl>0.05) && pc<50
%          pause;
          close all;
        [pb,pl]=pcd.plotDecoding(decodingByOdor8s(valid8,:,:),decodingByOdor8sError(valid8,:,:),decodingByOdor8sShuffle(valid8,:,:),8,33);
        disp([pb,pl]);
        pc=pc+1;
     end
    dc=dc+1;
end











%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Match cross decode %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lf=listF();

pcd=plotCrossDecoding2;
pb=0;
dc=0;
% while pb<0.05  && dc<20
    decodingByOdor4s=sampleByType(lf.listDNMS4s,'sample','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
    decodingByOdor4sError=sampleByType(lf.listDNMS4s,'sampleError','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
    valid4=decodingByOdor4sError(:,1,1)<65500;
    decodingByOdor8s=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
    decodingByOdor8sError=sampleByType(lf.listDNMS8s,'sampleError','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
    valid8=decodingByOdor8sError(:,1,1)<65500;

    decodingByTest=[decodingByOdor4s(valid4,:,:);trans8s(decodingByOdor8s(valid8,:,:),0.5,true)];
    decodingByTestError=[decodingByOdor4sError(valid4,:,:);trans8s(decodingByOdor8sError(valid8,:,:),0.5,true)];
    pc=0;
%     while pb<0.05  && pc<20
        close all;
        pcd.alwaysLeft=0;pcd.alwaysRight=0;[pb,pl]=pcd.plotDecoding(decodingByTest,decodingByTestError,4,21);
        disp([pb,pl]);
        pc=pc+1;
%     end
    dc=dc+1;
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Match Trajectory PCA 3d %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lf=listF();
binSize=0.2;
trajectorByMatch4s=sampleByType(lf.listDNMS4s,'Match','Average2Hz',-2,binSize,12,[20,20;20,20],100,1);
trajectorByMatch8s=sampleByType(lf.listDNMS8s,'Match','Average2Hz',-2,binSize,16,[20,20;20,20],100,1);
data=[trajectorByMatch4s;trans8s(trajectorByMatch8s,binSize)];
plotPCAMatch3D;
% view([az,el]);
xlim([-40,110])
ylim([-65,100]);
zlim([-27,35])



binSize=0.5;
trajectorByMatch4s=sampleByType(lf.listDNMS4s,'Match','Average2Hz',-2,binSize,12,[20,20;20,20],100,1);
trajectorByMatch8s=sampleByType(lf.listDNMS8s,'Match','Average2Hz',-2,binSize,16,[20,20;20,20],100,1);
data=[trajectorByMatch4s;trans8s(trajectorByMatch8s,binSize)];
pc.plotTrajectory(data,'trajectoryByMatch',1:20,7);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Trajectory Bar %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lf=listF();
binSize=0.5;
trajectorByOdor5sNaive=sampleByType(lf.listDNMSNaive5s(),'sample','Average2Hz',-2,binSize,10,[20,20;20,20],100,2);
trajectoryByOdor8s=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-2,binSize,13,[20,20;20,20],100,2);
trajectoryByOdor4sEarly=sampleByType(remapFiles(recordingFiles.heat4s(recordingFiles.early4sLogical,:)),'sample','Average2Hz',-2,binSize,9,[20,20;20,20],100,2);
trajectoryByOdor4sLate=sampleByType(remapFiles(recordingFiles.heat4s(~recordingFiles.early4sLogical,:)),'sample','Average2Hz',-2,binSize,9,[20,20;20,20],100,2);
trajectoryBarForGnuplot(trajectorByOdor5sNaive,trajectoryByOdor4sEarly,trajectoryByOdor4sLate,trajectoryByOdor8s,true)
pc=plotCurve;
pc.plotTrajectory(trajectorByOdor5sNaive,'trajectoryByOdor8sError',1:20)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Decoding   Bar %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lf=listF();
binSize=0.5;
decodingByOdor5sNaive=sampleByType(lf.listDNMSNaive5s(),'sampleAll','Average2Hz',-2,binSize,10,[30,1;30,1],500,2);
decodingByOdor8s=sampleByType(lf.listDNMS8s,'sampleAll','Average2Hz',-2,binSize,13,[30,1;30,1],500,2);
decodingByOdor4sEarly=sampleByType(remapFiles(recordingFiles.heat4s(recordingFiles.early4sLogical,:)),'sampleAll','Average2Hz',-2,binSize,9,[30,1;30,1],500,2);
decodingByOdor4sLate=sampleByType(remapFiles(recordingFiles.heat4s(~recordingFiles.early4sLogical,:)),'sampleAll','Average2Hz',-2,binSize,9,[30,1;30,1],500,2);

decodingBarForGnuplot(decodingByOdor5sNaive,decodingByOdor4sEarly,decodingByOdor4sLate,decodingByOdor8s,true);


lf=listF();
binSize=0.5;
decodingByOdor5sNaive=sampleByType(lf.listDNMSNaive5s(),'testAll','Average2Hz',-2,binSize,10,[30,1;30,1],500,2);
decodingByOdor8s=sampleByType(lf.listDNMS8s,'testAll','Average2Hz',-2,binSize,13,[30,1;30,1],500,2);
decodingByOdor4sEarly=sampleByType(remapFiles(recordingFiles.heat4s(recordingFiles.early4sLogical,:)),'testAll','Average2Hz',-2,binSize,9,[30,1;30,1],500,2);
decodingByOdor4sLate=sampleByType(remapFiles(recordingFiles.heat4s(~recordingFiles.early4sLogical,:)),'testAll','Average2Hz',-2,binSize,9,[30,1;30,1],500,2);

decodingBarForGnuplot(decodingByOdor5sNaive,decodingByOdor4sEarly,decodingByOdor4sLate,decodingByOdor8s,false);


lf=listF();
binSize=0.5;
decodingByOdor5sNaive=sampleByType(lf.listDNMSNaive5s(),'lickAll','Average2Hz',-2,binSize,10,[30,1;30,1],500,2);
decodingByOdor8s=sampleByType(lf.listDNMS8s,'lickAll','Average2Hz',-2,binSize,13,[30,1;30,1],500,2);
decodingByOdor4sEarly=sampleByType(remapFiles(recordingFiles.heat4s(recordingFiles.early4sLogical,:)),'lickAll','Average2Hz',-2,binSize,9,[30,1;30,1],500,2);
decodingByOdor4sLate=sampleByType(remapFiles(recordingFiles.heat4s(~recordingFiles.early4sLogical,:)),'lickAll','Average2Hz',-2,binSize,9,[30,1;30,1],500,2);

decodingBarForGnuplot(decodingByOdor5sNaive,decodingByOdor4sEarly,decodingByOdor4sLate,decodingByOdor8s,false);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Test cross decode %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lf=listF();

% decodingByOdor8s=sampleByType(lf.listDNMS8s,'test','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
% decodingByOdor8sError=sampleByType(lf.listDNMS8s,'testError','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
% valid8=decodingByOdor8sError(:,1,1)<65500;
% 
% decodingByTest=[decodingByOdor4s(valid4,:,:);trans8s(decodingByOdor8s(valid8,:,:),0.5,true)];
% decodingByTestError=[decodingByOdor4sError(valid4,:,:);trans8s(decodingByOdor8sError(valid8,:,:),0.5,true)];
% 
pcd=plotCrossDecoding;
% pcd.plotDecoding(decodingByTest,decodingByTestError,4);

pb=0;
dc=0;
while pb<0.05 && dc<20
    decodingByOdor4s=sampleByType(lf.listDNMS4s,'test','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
    decodingByOdor4sError=sampleByType(lf.listDNMS4s,'testError','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
    valid4=decodingByOdor4sError(:,1,1)<65500;
    decodingByOdor8s=sampleByType(lf.listDNMS8s,'test','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
    decodingByOdor8sError=sampleByType(lf.listDNMS8s,'testError','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
    valid8=decodingByOdor8sError(:,1,1)<65500;

    decodingByTest=[decodingByOdor4s(valid4,:,:);trans8s(decodingByOdor8s(valid8,:,:),0.5,true)];
    decodingByTestError=[decodingByOdor4sError(valid4,:,:);trans8s(decodingByOdor8sError(valid8,:,:),0.5,true)];
    pc=0;
    while pb<0.05 && pc<50
        close all;
        pb=pcd.plotDecoding(decodingByTest,decodingByTestError,4,21);
        disp(pb);
        pc=pc+1;
    end
    dc=dc+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Match cross decode %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% lf=listF();
% 
% % decodingByOdor8s=sampleByType(lf.listDNMS8s,'test','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
% % decodingByOdor8sError=sampleByType(lf.listDNMS8s,'testError','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
% % valid8=decodingByOdor8sError(:,1,1)<65500;
% % 
% % decodingByTest=[decodingByOdor4s(valid4,:,:);trans8s(decodingByOdor8s(valid8,:,:),0.5,true)];
% % decodingByTestError=[decodingByOdor4sError(valid4,:,:);trans8s(decodingByOdor8sError(valid8,:,:),0.5,true)];
% % 
% pcd=plotCrossDecoding;
% % pcd.plotDecoding(decodingByTest,decodingByTestError,4);
% 
% pb=0;
% dc=0;
% while (pb<0.05 || pl<0.001) && dc<20
%     decodingByOdor4s=sampleByType(lf.listDNMS4s,'match','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
%     decodingByOdor4sError=sampleByType(lf.listDNMS4s,'matchError','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
%     valid4=decodingByOdor4sError(:,1,1)<65500;
%     decodingByOdor8s=sampleByType(lf.listDNMS8s,'match','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
%     decodingByOdor8sError=sampleByType(lf.listDNMS8s,'matchError','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
%     valid8=decodingByOdor8sError(:,1,1)<65500;
% 
%     decodingByTest=[decodingByOdor4s(valid4,:,:);trans8s(decodingByOdor8s(valid8,:,:),0.5,true)];
%     decodingByTestError=[decodingByOdor4sError(valid4,:,:);trans8s(decodingByOdor8sError(valid8,:,:),0.5,true)];
%     pc=0;
%     while (pb<0.05 || pl<0.001) && pc<20
%         close all;
%         [pb,pl]=pcd.plotDecoding(decodingByTest,decodingByTestError,4,21);
%         disp([pb,pl]);
%         pc=pc+1;
%     end
%     dc=dc+1;
% end



lf=listF();
dc=0;
pl=0;
pb=0;
binSize=0.5;
while pb<0.05 
    decodingByMatch4sCorrect=sampleByType(lf.listDNMS4s,'Match','Average2Hz',-2,binSize,12,[30,1;30,1],500,1);
    decodingByMatch8sCorrect=sampleByType(lf.listDNMS8s,'Match','Average2Hz',2,binSize,16,[30,1;30,1],500,1);
    decodingCorrect=[decodingByMatch4sCorrect;decodingByMatch8sCorrect];
    
    decodingByMatch4sError=sampleByType(lf.listDNMS4s,'MatchError','Average2Hz',-2,binSize,12,[30,1;30,1],500,1);
    decodingByMatch8sError=sampleByType(lf.listDNMS8s,'MatchError','Average2Hz',2,binSize,16,[30,1;30,1],500,1);
    decodingError=[decodingByMatch4sError;decodingByMatch8sError];
    
%     decodingByOdor4sShuffle=sampleByType(lf.listDNMS4s,'shuffleAll','Average2Hz',-2,binSize,12,[30,1;30,1],500,1);
%     decodingByOdor8sShuffle=sampleByType(lf.listDNMS8s,'shuffleAll','Average2Hz',2,binSize,16,[30,1;30,1],500,1);
%     decodingShuffle=[decodingByOdor4sShuffle;decodingByOdor8sShuffle];
%     
    decodingByOdor4sShuffle=sampleByType(lf.listDNMS4s,'shuffle','Average2Hz',-2,binSize,12,[30,1;30,1],500,1);
    decodingByOdor8sShuffle=sampleByType(lf.listDNMS8s,'shuffle','Average2Hz',2,binSize,16,[30,1;30,1],500,1);
    decodingShuffle=[decodingByOdor4sShuffle;decodingByOdor8sShuffle];
    

    
    pcd=plotCrossDecoding;
    noTrialIdx=(decodingError(:,1,1)<10000);
    
%     pcd.alwaysLeft=1;pcd.alwaysRight=0;[pb,pl]=pcd.plotDecoding(decodingCorrect(noTrialIdx,:,:),decodingError(noTrialIdx,:,:),decodingShuffle(noTrialIdx,:,:),4,21);
%     pcd.alwaysLeft=0;pcd.alwaysRight=1;[pb,pl]=pcd.plotDecoding(decodingCorrect(noTrialIdx,:,:),decodingError(noTrialIdx,:,:),decodingShuffle(noTrialIdx,:,:),4,21);
    

%     pc=0;
    while pb<0.05 && pc<5
        close all;
         pcd.alwaysLeft=1;pcd.alwaysRight=0;[pb,pl]=pcd.plotDecoding(decodingCorrect(noTrialIdx,:,:),decodingError(noTrialIdx,:,:),decodingShuffle(noTrialIdx,:,:),4,21);

        pc=pc+1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% decoding by lick %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


lf=listF();
dc=0;
pl=0;
binSize=0.5;
pb=0;
while pb<0.05
    decodingByLick4sCorrect=sampleByType(lf.listDNMS4s,'Lick','Average2Hz',-2,binSize,12,[30,1;30,1],500,1);
    decodingByLick8sCorrect=sampleByType(lf.listDNMS8s,'Lick','Average2Hz',2,binSize,16,[30,1;30,1],500,1);
    decodingCorrect=[decodingByLick4sCorrect;decodingByLick8sCorrect];
    
    decodingByLick4sError=sampleByType(lf.listDNMS4s,'LickError','Average2Hz',-2,binSize,12,[30,1;30,1],500,1);
    decodingByLick8sError=sampleByType(lf.listDNMS8s,'LickError','Average2Hz',2,binSize,16,[30,1;30,1],500,1);
    decodingError=[decodingByLick4sError;decodingByLick8sError];
    
%     decodingByOdor4sShuffle=sampleByType(lf.listDNMS4s,'shuffleAll','Average2Hz',-2,binSize,12,[30,1;30,1],500,1);
%     decodingByOdor8sShuffle=sampleByType(lf.listDNMS8s,'shuffleAll','Average2Hz',2,binSize,16,[30,1;30,1],500,1);
%     decodingShuffle=[decodingByOdor4sShuffle;decodingByOdor8sShuffle];
%     
    decodingByOdor4sShuffle=sampleByType(lf.listDNMS4s,'shuffle','Average2Hz',-2,binSize,12,[30,1;30,1],500,1);
    decodingByOdor8sShuffle=sampleByType(lf.listDNMS8s,'shuffle','Average2Hz',2,binSize,16,[30,1;30,1],500,1);
    decodingShuffle=[decodingByOdor4sShuffle;decodingByOdor8sShuffle];
    

    
    pcd=plotCrossDecoding2;
    noTrialIdx=(decodingError(:,1,1)<10000);
    
    pcd.alwaysLeft=0;pcd.alwaysRight=0;[pb,pl]=pcd.plotDecoding(decodingCorrect(noTrialIdx,:,:),decodingError(noTrialIdx,:,:),decodingShuffle(noTrialIdx,:,:),4,21);
    
    

%     pc=0;
%     while pl<0.05 && pc<20
%         [pb,pl]=pcd.plotDecoding(decodingCorrect(noTrialIdx,:,:),decodingError(noTrialIdx,:,:),decodingShuffle(noTrialIdx,:,:),4,21);
%         pl=min(pb,pl);
%     end
end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[~,~,selId]=sel2wayDNMS(12,[]);

toSave=nan(25,4);
toSave(2:end,2)=sum(selId==1 | selId==5)'./size(selId,1);%sample
toSave(2:end,3)=sum(selId==3 | selId==7)'./size(selId,1);%both
toSave(2:end,4)=sum(selId==2 | selId==6)'./size(selId,1);%test
save('sel2way.txt','toSave','-ascii');
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuPlotSel2way.txt')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[~,~,selId]=sel2wayDNMS(12,[]);

toSave=nan(25,4);
toSave(2:end,2)=sum(selId==4)'./size(selId,1);%choice
toSave(2:end,3)=sum(selId==5 | selId==6 | selId==7)'./size(selId,1);%both
toSave(2:end,4)=sum(selId==1 | selId==2 | selId==3)'./size(selId,1);%sensory
save('sel2way.txt','toSave','-ascii');
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuPlotSel2way.txt')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% all trial match heatmap %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lf=listF();
heatByMatch4s=sampleByType(lf.listDNMS4s,'MatchIncIncorrZ','Average2Hz',3,0.2,12,[200,0;200,0],1,1);
heatByMatch8s=sampleByType(lf.listDNMS8s,'MatchIncIncorrZ','Average2Hz',7,0.2,16,[200,0;200,0],1,1);
ph=plotHeat();
ph.sortBy='match';
ph.plot([heatByMatch4s;heatByMatch8s],false,'heatByMatch');
savefig('heatByMatchIncIncorr.fig');
convertFigs('heatByMatchIncIncorr',true);

% xlim([0.5,34.5]);

lf=listF();
heatByMatch4s=sampleByType(lf.listDNMS4s,'MatchZ','Average2Hz',3,0.2,12,[200,0;200,0],1,1);
heatByMatch8s=sampleByType(lf.listDNMS8s,'MatchZ','Average2Hz',7,0.2,16,[200,0;200,0],1,1);
ph=plotHeat();
ph.sortBy='match';
ph.plot([heatByMatch4s;heatByMatch8s],false,'heatByMatch');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  Match correct and Error %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

heatByMatch8s=sampleByType(lf.listDNMS8s,'MatchZ','Average2Hz',7,0.2,16,[200,0;200,0],1,1);
heatByMatch4s=sampleByType(lf.listDNMS4s,'MatchZ','Average2Hz',3,0.2,12,[200,0;200,0],1,1);

heatByMatch8sError=sampleByType(lf.listDNMS8s,'MatchErrorZ','Average2Hz',7,0.2,16,[200,0;200,0],1,1);
heatByMatch4sError=sampleByType(lf.listDNMS4s,'MatchErrorZ','Average2Hz',3,0.2,12,[200,0;200,0],1,1);

aIdx=~[heatByMatch4sError(:,1,1)>10000;heatByMatch8sError(:,1,1)>10000];
ph=plotHeat();
ph.sortBy='match';
d=[heatByMatch4s;heatByMatch8s];
d=d(aIdx,:,:);
mod=permute(d,[3 1 2]);
for i=1:size(mod,2)
    mod(:,i)=smooth(mod(:,i));
end
modB=shiftdim(mod,-1);
modB=permute(modB,[3,1,2]);
mod=modB;
ph=plotHeat;
ph.importIdx=false;
ph.sortBy='match';
ph.plot(mod,false,'heatByMatchCorrect')
savefig('heatByMatchCorrect');


ph.importIdx=true;
d=[heatByMatch4sError;heatByMatch8sError];
d=d(aIdx,:,:);
mod=permute(d,[3 1 2]);
for i=1:size(mod,2)
    mod(:,i)=smooth(mod(:,i));
end
modB=shiftdim(mod,-1);
modB=permute(modB,[3,1,2]);
mod=modB;

ph.plot(mod,false,'heatByMatchError');
savefig('heatByMatchError');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Recording Session Performance %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,seq4sError]=sampleByType(lf.listDNMS4s,'sampleError','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
fs=seq4sError;
summ=cell(length(fs),6);
for i=1:length(fs)
load(fs{i,1},'TrialInfo');
totalTrial=size(TrialInfo,1);
hit=sum((TrialInfo(:,3)~=TrialInfo(:,4) & TrialInfo(:,5)==1))./totalTrial;
miss=sum((TrialInfo(:,3)~=TrialInfo(:,4) & TrialInfo(:,5)==0))./totalTrial;
fa=sum((TrialInfo(:,3)==TrialInfo(:,4) & TrialInfo(:,5)==1))./totalTrial;
cr=sum((TrialInfo(:,3)==TrialInfo(:,4) & TrialInfo(:,5)==0))./totalTrial;
miss50=sum((TrialInfo(end-50:end,3)~=TrialInfo(end-50:end,4) & TrialInfo(end-50:end,5)==0))./50;
summ(i,:)={fs{i,1},hit,miss,fa,cr,miss50};
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% sel relation & lick during learning %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


binSize=0.5;
selA=allByTypeDNMS('sample','Average2Hz',-2,binSize,12,true,4,1);
selB=allByTypeDNMS('sample','Average2Hz',-2,binSize,12,false,4,1);
selMatchA=allByTypeDNMS('match','Average2Hz',-2,binSize,12,true,4,1);
selMatchB=allByTypeDNMS('match','Average2Hz',-2,binSize,12,false,4,1);
selTestA=allByTypeDNMS('test','Average2Hz',-2,binSize,12,true,4,1);
selTestB=allByTypeDNMS('test','Average2Hz',-2,binSize,12,false,4,1);
selLickA=allByTypeDNMS('lickAll','Average2Hz',-2,binSize,12,true,4,1);
selLickB=allByTypeDNMS('lickAll','Average2Hz',-2,binSize,12,false,4,1);


save('sel2wayDNMS4sL.mat','binSize','selA','selB','selTestA','selTestB','selMatchA','selMatchB','selLickA','selLickB');



binSize=0.5;
selA=allByTypeDNMS('sample','Average2Hz',-2,binSize,16,true,8,1);
selB=allByTypeDNMS('sample','Average2Hz',-2,binSize,16,false,8,1);
selTestA=allByTypeDNMS('test','Average2Hz',-2,binSize,16,true,8,1);
selTestB=allByTypeDNMS('test','Average2Hz',-2,binSize,16,false,8,1);
selMatchA=allByTypeDNMS('match','Average2Hz',-2,binSize,16,true,8,1);
selMatchB=allByTypeDNMS('match','Average2Hz',-2,binSize,16,false,8,1);

selLickA=allByTypeDNMS('lickAll','Average2Hz',-2,binSize,16,true,8,1);
selLickB=allByTypeDNMS('lickAll','Average2Hz',-2,binSize,16,false,8,1);

save('sel2wayDNMS8sL.mat','binSize','selA','selB','selTestA','selTestB','selMatchA','selMatchB','selLickA','selLickB');
[~,~,smp]=sel2wayDNMS(-12,[],true);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Lick Heat Map  %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lf=listF();
heatByLick4s=sampleByType(lf.listDNMS4s,'lickAllZ','Average2Hz',3,0.2,12,[200,0;200,0],1,1);
heatByLick8s=sampleByType(lf.listDNMS8s,'lickAllZ','Average2Hz',7,0.2,16,[200,0;200,0],1,1);
mod=[heatByLick4s;heatByLick8s];
ph=plotHeat();
ph.importIdx=false;
ph.sortBy='match';
ph.plot(mod,false,'heatByLickAll')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lf=listF();
binSize=0.5;
pc=plotCurve;
pp=0;

while pp<0.05
trajectorByLick4s=sampleByType(lf.listDNMS4s,'LickAll','Average2Hz',-2,binSize,12,[20,20;20,20],100,1);
trajectorByLick8s=sampleByType(lf.listDNMS8s,'LickAll','Average2Hz',-2,binSize,16,[20,20;20,20],100,1);
data=[trajectorByLick4s;trans8s(trajectorByLick8s,binSize)];


pp=pc.plotTrajectory(data,'trajectoryByLick',1:20,7);
end






%%


addpath('..')
lf=listF();
decodingByOdor=sampleByType(lf.listDNMS4s,'sample','Average2Hz',-2,0.5,7,[30,1;30,1],500,1);
% decodingByOdor=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-2,0.5,11,[30,1;30,1],500,1);

suv=SUVarTCurve();
mvDec=suv.plotDecoding(decodingByOdor);
avgDec=suv.plotAvgedDecoding(decodingByOdor,'late');
mAvgDec=mean(avgDec,2);
mMvDec=mean(mvDec,2);

dynIdx=(mMvDec-mAvgDec)./(mMvDec+mAvgDec);
[~,sIdx]=sort(dynIdx);
pc=plotCurve;

pc.plotDecoding(decodingByOdor,'7725DecoSampleVLate4s','sample','late');
pc.plotDecoding(decodingByOdor,'7725DecoDynVDelay4s','dynamic','delay');
pc.plotDecoding(decodingByOdor(dynIdx>0,:,:),'7725DecoDynVDelay4sPosDynIdx','dynamic','delay');
pc.plotDecoding(decodingByOdor(dynIdx<0,:,:),'7725DecoDynVDelay4sNegDynIdx','dynamic','delay');
pc.plotDecoding(decodingByOdor(sIdx(1:20),:,:),'7725DecoDynVDelay4sNegDynIdx20','dynamic','delay');
pc.plotDecoding(decodingByOdor(sIdx(end-19:end),:,:),'7725DecoDynVDelay4sPosDynIdx20','dynamic','delay');

% 
% pc.plotDecoding(decodingByOdor,'7725DecoSampVDelay8s','sample','late');
% pc.plotDecoding(decodingByOdor,'7725DecoDynVDelay8s','dynamic','late');
% pc.plotDecoding(decodingByOdor(dynIdx>0,:,:),'7725DecoDynVDelay8sPosDynIdx','dynamic','late');
% pc.plotDecoding(decodingByOdor(dynIdx<0,:,:),'7725DecoDynVDelay8sNegDynIdx','dynamic','late');
% pc.plotDecoding(decodingByOdor(sIdx(1:10),:,:),'7725DecoDynVDelay8sNegDynIdx10','dynamic','late');
% pc.plotDecoding(decodingByOdor(sIdx(end-9:end),:,:),'7725DecoDynVDelay8sPosDynIdx10','dynamic','late');




%%
[spkCA,seqSpkCA]=allByTypeDNMS('sample','Average2Hz',-2,1,11,true,8,1);
fl=expand(seqSpkCA);
close all;plotShowCaseWJ(22,5);


%%
addpath('..');
lf=listF();
decodingByOdor=sampleByType(lf.listDNMS4s,'sample','Average2Hz',-2,0.5,7,[30,1;30,1],500,1);
suv=SUVarTCurve();
mvDec=suv.plotDecoding(decodingByOdor);
avgDec=suv.plotAvgedDecoding(decodingByOdor,'sampledelay');
mAvgDec=mean(avgDec,2);
mMvDec=mean(mvDec,2);
dynIdx=(mMvDec-mAvgDec)./(mMvDec+mAvgDec);
[ans,sIdx]=sort(dynIdx);

len=size(mvDec,1);
dynP=nan(len,1);
for i=1:len
    [~,~,dynP(i)]=crosstab([zeros(1,size(mvDec,2)),ones(1,size(mvDec,2))],[mvDec(i,:),avgDec(i,:)]);
end

pc=plotCurve;
pc.plotDecoding(decodingByOdor((dynP.*len<0.05 & dynIdx>0),:,:),'7727t3','dynamic','sampledelay');
pc.plotDecoding(decodingByOdor((dynP.*len<0.05 & dynIdx<0),:,:),'7727t4','dynamic','sampledelay');

[ImPerUnit,ImShuf,selPerUnit,selShuf, avgFR]=plotIm('delay',4,3);
figure();
plot(abs(selPerUnit),dynIdx,'k.');
hold on;
plot(abs(selPerUnit(sIdx(end-19:end))),dynIdx(sIdx(end-19:end)),'r.');


addpath('..');
lf=listF();
decodingByOdor=sampleByType(lf.listDNMS4s,'sample','Average2Hz',-2,0.5,7,[30,1;30,1],500,1);
suv=SUVarTCurve();
smpDec=suv.plotAvgedDecoding(decodingByOdor,'sample');
lateDec=suv.plotAvgedDecoding(decodingByOdor,'late');
mSmpDec=mean(avgDec,2);
mLateDec=mean(mvDec,2);
s_lIdx=(mLateDec-mSmpDec)./(mLateDec+mSmpDec);
[ans,sIdx]=sort(s_lIdx);
pc=plotCurve;
pc.plotDecoding(decodingByOdor,'7727t3','dynamic','sampledelay');

s_l_dyn=suv.plotDynamic(decodingByOdor);
s_l_m=mean(s_l_dyn,3);
plot(s_l_m(:,1),s_l_m(:,2),'k.')


delayLen=4;
[spkCA,uniqTagA]=allByTypeDNMS('sample','Average2Hz',-2,0.5,11,true,delayLen,1);
[spkCB,uniqTagB]=allByTypeDNMS('sample','Average2Hz',-2,0.5,11,false,delayLen,1);

min([cellfun(@(x) size(x,2), spkCA),cellfun(@(x) size(x,2), spkCB)])