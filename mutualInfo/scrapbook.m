[spkCA,uniqTag]=allByTypeDual('sample','Average2Hz',-2,0.1,15,true,true);
[spkCB,~]=allByTypeDual('sample','Average2Hz',-2,0.1,15,false,true);
save('dualAll8s.mat','spkCA','spkCB','uniqTag');

[spkCA,tagA]=allByTypeDual('distrNone','Average2Hz',-2,0.5,15,true,true);
[spkCB,tagB]=allByTypeDual('distrNone','Average2Hz',-2,0.5,15,false,true);


[spkCA,uniqTag]=allByTypeDual('sample','Average2Hz',-2,0.1,15,true,true,'WJ');
[spkCB,~]=allByTypeDual('sample','Average2Hz',-2,0.1,15,false,true,'WJ');
save('dualAll13s.mat','spkCA','spkCB','uniqTag');


delayLen=8;
[spkCA,uniqTag]=allByTypeDNMS('sample','Average2Hz',-2,0.1,15,true,delayLen,true);
[spkCB,~]=allByTypeDNMS('sample','Average2Hz',-2,0.1,15,false,delayLen,true);
save('8sDNMS.mat','spkCA','spkCB','uniqTag');


delayLen=5;
[spkCA,uniqTag]=allByTypeDNMS('sample','Average2Hz',-2,0.1,12,true,delayLen,false);
[spkCB,~]=allByTypeDNMS('sample','Average2Hz',-2,0.1,12,false,delayLen,false);
save('5sDNMSNaive.mat','spkCA','spkCB','uniqTag');


delayLen=5;
[spkCA,uniqTag]=allByTypeDNMS('sample','Average2Hz',-2,0.1,12,true,delayLen,false);
[spkCB,~]=allByTypeDNMS('sample','Average2Hz',-2,0.1,12,false,delayLen,false);
save('5sDNMSNaive.mat','spkCA','spkCB','uniqTag');


[spkCA,uniqTag]=allByTypeDual('sample','Average2Hz',-2,0.1,15,true,true);
[spkCB,~]=allByTypeDual('sample','Average2Hz',-2,0.1,15,false,true);
save('dualAll.mat','spkCA','spkCB','uniqTag');

thresh=15;
sel=cellfun(@(x) size(x,2),sample3)>thresh & ...
cellfun(@(x) size(x,2),sample2)>thresh & ...
cellfun(@(x) size(x,2),sample12)>thresh & ...
cellfun(@(x) size(x,2),sample6)>thresh & ...
cellfun(@(x) size(x,2),sample4)>thresh & ...
cellfun(@(x) size(x,2),sample5)>thresh;
% nnz(sel)
total=unique(cellfun(@(x) x{1},pCrossTime(:,1)));
selId=total(sel);

expSel=cellfun(@(x) ismember(x{1},selId),pCrossTime(:,1));

pCrossTime=pCrossTime(expSel,:);
Im=Im(expSel,:);
save('imMultiSample5s.mat','pCrossTime','Im');


%%%%%%%%%%%%%%%%%%Multi MI

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

inAll=intersect(ids12,intersect(ids6,intersect(ids5,intersect(ids4,intersect(ids2,ids3,'rows'),'rows'),'rows'),'rows'),'rows');
allSpks={sample2(sel),sample3(sel),sample4(sel),sample5(sel),sample6(sel),sample12(sel)};
ids=unique(inAll(:,1));
UniqTagR=arrayfun(@(x) inAll(inAll(:,1)==x,2:3), ids,'UniformOutput',false);
UniqTagL=arrayfun(@(x) x, ids,'UniformOutput',false);
uniqTag=[UniqTagL,UniqTagR];
save('multiSample.mat','allSpks','uniqTag');
plotImContMultiSampCluster('multiSample5s.mat','imMultiSample');





