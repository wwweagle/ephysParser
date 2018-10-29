[spkCA,tagA]=allByTypeDual('sample','Average2Hz',-2,0.5,15,true,true);
[spkCB,tagB]=allByTypeDual('sample','Average2Hz',-2,0.5,15,false,true);

[spkCANone,tagANone]=allByTypeDual('distrNone','Average2Hz',-2,0.5,15,true,true);
[spkCBNone,tagBNone]=allByTypeDual('distrNone','Average2Hz',-2,0.5,15,false,true);


[spkCAGo,tagAGo]=allByTypeDual('distrGo','Average2Hz',-2,0.5,15,true,true);
[spkCBGo,tagBGo]=allByTypeDual('distrGo','Average2Hz',-2,0.5,15,false,true);

[spkCANogo,tagANogo]=allByTypeDual('distrNogo','Average2Hz',-2,0.5,15,true,true);
[spkCBNogo,tagBNogo]=allByTypeDual('distrNogo','Average2Hz',-2,0.5,15,false,true);

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

spkCA=allSpks{5};
spkCB=allSpks{6};
tagA=allTags{5};
tagA=allTags{6};
delayLen=8;
sel=[];

save('8sDualGo.mat','spkCA','spkCB','tagA','tagB','sel','delayLen');

spkCA=allSpks{7};
spkCB=allSpks{8};
tagA=allTags{7};
tagA=allTags{8};
delayLen=8;
sel=[];

save('8sDualNoGo.mat','spkCA','spkCB','tagA','tagB','sel','delayLen');


spkCA=allSpks{3};
spkCB=allSpks{4};
tagA=allTags{3};
tagA=allTags{4};
delayLen=8;
sel=[];

save('8sDualNone.mat','spkCA','spkCB','tagA','tagB','sel','delayLen');

return;

% save('dualCrossSVM.mat','allTags','allSpks','nameTags');
% fprintf('%d\n',sum(cellfun(@(x) size(x,1),spkCA)));


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
[spkCA,tagA]=allByTypeDNMS('sample','Average2Hz',-2,0.5,delayLen+7,true,delayLen,true);
[spkCB,tagB]=allByTypeDNMS('sample','Average2Hz',-2,0.5,delayLen+7,false,delayLen,true);
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
sel=(cellfun(@(x) size(x,2),spkCA)>31 & cellfun(@(x) size(x,2),spkCB)>31);
%
spkCA=spkCA(sel);
spkCB=spkCB(sel);
tagA=tagA(sel,:);
tagB=tagB(sel,:);

sum(cellfun(@(x) size(x,1),spkCA))

%%%%%%%%%%%%%%
save('8sDNMS_0830_147SU.mat','spkCA','spkCB','tagA','tagB','sel','delayLen');
save('4sDNMS_0830_174SU.mat','spkCA','spkCB','tagA','tagB','sel','delayLen');


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

[spkCA,tagA]=allByTypeDual('sample','Average2Hz',-2,0.5,15,true,true);
[spkCB,tagB]=allByTypeDual('sample','Average2Hz',-2,0.5,15,false,true);

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
sel=(cellfun(@(x) size(x,2),spkCA)>31 & cellfun(@(x) size(x,2),spkCB)>31);
%
spkCA=spkCA(sel);
spkCB=spkCB(sel);
tagA=tagA(sel,:);
tagB=tagB(sel,:);

sum(cellfun(@(x) size(x,1),spkCA))
save('8sDual_0830_215SU.mat','spkCA','spkCB','tagA','tagB','sel','delayLen');



function [spks,tags]=matchTag(spks,tags,idx)
tempTag=true(length(tags{idx}),1);
for i=1:length(tags)
    if i==idx
        continue;
    end
    tempTag=tempTag & ismember(tags{idx}(:,1),tags{i}(:,1));
end
spks{idx}=spks{idx}(tempTag);
tags{idx}=tags{idx}(tempTag,:);
end


function [spks,tags]=matchSU(spks,tags,idx)
for j=1:length(tags)
    if j==idx
        continue;
    end
    for i=1:size(tags{j},1)
        spks{idx}{i}=spks{idx}{i}(ismember(tags{idx}{i,2},tags{j}{i,2},'rows'),:,:);
        tags{idx}{i,2}=tags{idx}{i,2}(ismember(tags{idx}{i,2},tags{j}{i,2},'rows'),:);
    end
end
end

