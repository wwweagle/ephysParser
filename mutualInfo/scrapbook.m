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
