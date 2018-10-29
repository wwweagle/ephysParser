[sample3,ids3]=processAll('sample',3,[-2,0.5,13]);
[sample2,ids2]=processAll('sample',2,[-2,0.5,13]);
[sample12,ids12]=processAll('sample',12,[-2,0.5,13]);
[sample6,ids6]=processAll('sample',6,[-2,0.5,13]);
[sample4,ids4]=processAll('sample',4,[-2,0.5,13]);
[sample5,ids5]=processAll('sample',5,[-2,0.5,13]);
%%%%%%%%%  1        2       3       4      5         6
refineSamples;
thresh=30;
sel=cellfun(@(x) size(x,2),sample3)>thresh & ...
    cellfun(@(x) size(x,2),sample2)>thresh & ...
    cellfun(@(x) size(x,2),sample12)>thresh & ...
    cellfun(@(x) size(x,2),sample6)>thresh & ...
    cellfun(@(x) size(x,2),sample4)>thresh & ...
    cellfun(@(x) size(x,2),sample5)>thresh;


samples={sample2(sel),sample3(sel),sample4(sel),sample5(sel),sample6(sel),sample12(sel)};
save('multiSamples.mat','samples');


[sample3,ids3]=processAll('sample',3,[-2,0.5,13]);
[sample2,ids2]=processAll('sample',2,[-2,0.5,13]);
[sample12,ids12]=processAll('sample',12,[-2,0.5,13]);
[sample6,ids6]=processAll('sample',6,[-2,0.5,13]);
[sample4,ids4]=processAll('sample',4,[-2,0.5,13]);
[sample5,ids5]=processAll('sample',5,[-2,0.5,13]);
%%%%%%%%%  1        2       3       4      5         6





thresh=15;
sel=cellfun(@(x) size(x,2),sample3)>thresh & ...
    cellfun(@(x) size(x,2),sample2)>thresh & ...
    cellfun(@(x) size(x,2),sample12)>thresh & ...
    cellfun(@(x) size(x,2),sample6)>thresh & ...
    cellfun(@(x) size(x,2),sample4)>thresh & ...
    cellfun(@(x) size(x,2),sample5)>thresh;


samples={sample2(sel),sample3(sel),sample4(sel),sample5(sel),sample6(sel),sample12(sel)};
save('multiSamplesCross.mat','samples');
















function saveDualCrossoverFile()

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

% save('dualCrossSVM.mat','allTags','allSpks','nameTags');
fprintf('%d\n',sum(cellfun(@(x) size(x,1),spkCA)));
end

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







%%%%%%%%%%%%%%%%%%Multi MI
javaaddpath('R:\ZX\java\spk2fr\lib\commons-math3-3.5.jar');
javaaddpath('R:\ZX\java\spk2fr\build\classes');
bfl=spk2fr.multiplesample.BuildFileList();
flistA=string(bfl.toString(bfl.build('O:\ZX\intan')));
flistB=string(bfl.toString(bfl.build('O:\ZX\intan5')));
flist=[flistA;flistB];
DelayLaserFiles=find(~cellfun(@(x) isempty(x),strfind(flist(:,1),'DelayLaser')));


[sample3,ids3]=processAll('sample',3,[-2,0.1,12]);
[sample2,ids2]=processAll('sample',2,[-2,0.1,12]);
[sample12,ids12]=processAll('sample',12,[-2,0.1,12]);
[sample6,ids6]=processAll('sample',6,[-2,0.1,12]);
[sample4,ids4]=processAll('sample',4,[-2,0.1,12]);
[sample5,ids5]=processAll('sample',5,[-2,0.1,12]);

refineSamples;
thresh=30;
sel=cellfun(@(x) size(x,2),sample3)>thresh & ...
    cellfun(@(x) size(x,2),sample2)>thresh & ...
    cellfun(@(x) size(x,2),sample12)>thresh & ...
    cellfun(@(x) size(x,2),sample6)>thresh & ...
    cellfun(@(x) size(x,2),sample4)>thresh & ...
    cellfun(@(x) size(x,2),sample5)>thresh;

idkey=unique(inAll(:,1));
inAll=inAll(ismember(inAll(:,1),idkey(sel)),:);
% inAll=intersect(ids12,intersect(ids6,intersect(ids5,intersect(ids4,intersect(ids2,ids3,'rows'),'rows'),'rows'),'rows'),'rows');
allSpks={sample2(sel),sample3(sel),sample4(sel),sample5(sel),sample6(sel),sample12(sel)};
ids=unique(inAll(:,1));
UniqTagR=arrayfun(@(x) inAll(inAll(:,1)==x,2:3), ids,'UniformOutput',false);
UniqTagL=arrayfun(@(x) x, ids,'UniformOutput',false);
uniqTag=[UniqTagL,UniqTagR];
save('multiSample.mat','allSpks','uniqTag','DelayLaserFiles','inAll');