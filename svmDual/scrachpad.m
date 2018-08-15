[spkCA,tagA]=allByTypeDual('sample','Average2Hz',-2,0.5,15,true,true);
[spkCB,tagB]=allByTypeDual('sample','Average2Hz',-2,0.5,15,false,true);

[spkCANone,tagANone]=allByTypeDual('distrNone','Average2Hz',-2,0.1,15,true,true);
[spkCBNone,tagBNone]=allByTypeDual('distrNone','Average2Hz',-2,0.1,15,false,true);


[spkCAGo,tagAGo]=allByTypeDual('distrGo','Average2Hz',-2,0.1,15,true,true);
[spkCBGo,tagBGo]=allByTypeDual('distrGo','Average2Hz',-2,0.1,15,false,true);

[spkCANogo,tagANogo]=allByTypeDual('distrNogo','Average2Hz',-2,0.1,15,true,true);
[spkCBNogo,tagBNogo]=allByTypeDual('distrNogo','Average2Hz',-2,0.1,15,false,true);

allTags={tagA,tagB,tagANone,tagBNone,tagAGo,tagBGo,tagANogo,tagBNogo};
allSpks={spkCA,spkCB,spkCANone,spkCBNone,spkCAGo,spkCBGo,spkCANogo,spkCBNogo};
nameTags={'spkCA','spkCB','spkCANone','spkCBNone','spkCAGo','spkCBGo','spkCANogo','spkCBNogo'};

for i=1:length(allTags)
    [allSpks,allTags]=matchTag(allSpks,allTags,i);
end

for i=1:length(allTags)
    [allSpks,allTags]=matchSU(allSpks,allTags,i);
end

sel=cellfun(@(x) size(x,2),allSpks{1})>15 & cellfun(@(x) size(x,2),allSpks{2})>15;

save('dualCrossSVM.mat','allTags','allSpks','nameTags');
fprintf('%d\n',sum(cellfun(@(x) size(x,1),spkCA)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Distr Im  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load ImDualByDistr.mat
combined=cell(1,3);
for i=3:2:7
    combined{(i-1)/2}=arrayfun(@(x) cat(2,allSpks{i}{x},allSpks{i+1}{x}),1:93,'UniformOutput',false);
end
allSpks=combined;
uniqTag=allTags{3};
% nameTags=nameTags(3:2:7);
save('ImDualByDistrCombined.mat','allSpks','uniqTag');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% naive welltrain comparison

delayLen=8;
[spkCA,tagA]=allByTypeDNMS('sampleall','Average2Hz',-2,0.5,12,true,delayLen,false);
[spkCB,tagB]=allByTypeDNMS('sampleall','Average2Hz',-2,0.5,12,false,delayLen,false);
spkCA=spkCA(ismember(tagA(:,1),tagB(:,1)));
tagA=tagA(ismember(tagA(:,1),tagB(:,1)),:);
spkCB=spkCB(ismember(tagB(:,1),tagA(:,1)));
tagB=tagB(ismember(tagB(:,1),tagA(:,1)),:);
if ~all(strcmp(tagA(:,1),tagB(:,1)))
spkCA=[];
spkCB=[];
return
end
for i=1:size(tagA,1)
spkCA{i}=spkCA{i}(ismember(tagA{i,2},tagB{i,2},'rows'),:,:);
tagA{i,2}=tagA{i,2}(ismember(tagA{i,2},tagB{i,2},'rows'),:);
end
for i=1:size(tagB,1)
spkCB{i}=spkCB{i}(ismember(tagB{i,2},tagA{i,2},'rows'),:,:);
tagB{i,2}=tagB{i,2}(ismember(tagB{i,2},tagA{i,2},'rows'),:);
end
%
sel=(cellfun(@(x) size(x,2),spkCA)>30 & cellfun(@(x) size(x,2),spkCB)>30);
%
spkCA=spkCA(sel);
spkCB=spkCB(sel);
tagA=tagA(sel,:);
tagB=tagB(sel,:);

%%%%%%%%%%%%%%
%save('5sDNMSNaive.mat','spkCA','spkCB','tagA','tagB','sel','delayLen');



delayLen=4;
[spkCA,tagA]=allByTypeDNMS('sampleall','Average2Hz',-2,0.5,delayLen+7,true,delayLen,true);
[spkCB,tagB]=allByTypeDNMS('sampleall','Average2Hz',-2,0.5,delayLen+7,false,delayLen,true);
spkCA=spkCA(ismember(tagA(:,1),tagB(:,1)));
tagA=tagA(ismember(tagA(:,1),tagB(:,1)),:);
spkCB=spkCB(ismember(tagB(:,1),tagA(:,1)));
tagB=tagB(ismember(tagB(:,1),tagA(:,1)),:);
if ~all(strcmp(tagA(:,1),tagB(:,1)))
spkCA=[];
spkCB=[];
return
end
for i=1:size(tagA,1)
spkCA{i}=spkCA{i}(ismember(tagA{i,2},tagB{i,2},'rows'),:,:);
tagA{i,2}=tagA{i,2}(ismember(tagA{i,2},tagB{i,2},'rows'),:);
end
for i=1:size(tagB,1)
spkCB{i}=spkCB{i}(ismember(tagB{i,2},tagA{i,2},'rows'),:,:);
tagB{i,2}=tagB{i,2}(ismember(tagB{i,2},tagA{i,2},'rows'),:);
end
%
sel=(cellfun(@(x) size(x,2),spkCA)>40 & cellfun(@(x) size(x,2),spkCB)>40);
%
spkCA=spkCA(sel);
spkCB=spkCB(sel);
tagA=tagA(sel,:);
tagB=tagB(sel,:);

sum(cellfun(@(x) size(x,1),spkCA))

%%%%%%%%%%%%%%
%save('8sDNMSAllTrial.mat','spkCA','spkCB','tagA','tagB','sel','delayLen');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% naive average MI
delayLen=5;
[spkCA,tagA]=allByTypeDNMS('sampleall','Average2Hz',-2,0.1,12,true,delayLen,false);
[spkCB,tagB]=allByTypeDNMS('sampleall','Average2Hz',-2,0.1,12,false,delayLen,false);
spkCA=spkCA(ismember(tagA(:,1),tagB(:,1)));
tagA=tagA(ismember(tagA(:,1),tagB(:,1)),:);
spkCB=spkCB(ismember(tagB(:,1),tagA(:,1)));
tagB=tagB(ismember(tagB(:,1),tagA(:,1)),:);
if ~all(strcmp(tagA(:,1),tagB(:,1)))
spkCA=[];
spkCB=[];
return
end
for i=1:size(tagA,1)
spkCA{i}=spkCA{i}(ismember(tagA{i,2},tagB{i,2},'rows'),:,:);
tagA{i,2}=tagA{i,2}(ismember(tagA{i,2},tagB{i,2},'rows'),:);
end
for i=1:size(tagB,1)
spkCB{i}=spkCB{i}(ismember(tagB{i,2},tagA{i,2},'rows'),:,:);
tagB{i,2}=tagB{i,2}(ismember(tagB{i,2},tagA{i,2},'rows'),:);
end

uniqTag=tagA;


%%%%%%%%%%%%%%
%save('5sDNMSNaive4MI.mat','spkCA','spkCB','uniqTag','delayLen');

