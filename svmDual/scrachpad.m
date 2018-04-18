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




