function [fName,SPK,EVT]=saveOne(channel,spkIn,evtIn,fileName)
startTs=evtIn(1)-60;
endTs=evtIn(end)+60;
SPKT=spkIn(spkIn(:,3)>startTs & spkIn(:,3)<endTs,[4,2,3,5:end]);
SPK=[];
switch channel
    case 1
        SPK=SPKT(SPKT(:,1)<33,:);
    case 2
        SPK=SPKT(SPKT(:,1)>32 & SPKT(:,1)<65,:);
    case 3
        SPK=SPKT(SPKT(:,1)>64,:);
end
EVT=evtIn;
pName=pwd();
fName=[fileName,'_',pName(length(pName)-5:end),'_OpGenSession.mat'];
if numel(SPK)>1000
    save(fName,'SPK','EVT');
end