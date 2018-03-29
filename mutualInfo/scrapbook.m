[spkCA,uniqTag]=allByTypeDual('sample','Average2Hz',-2,0.1,15,true,true);
[spkCB,~]=allByTypeDual('sample','Average2Hz',-2,0.1,15,false,true);
save('dualAll.mat','spkCA','spkCB','uniqTag');

[spkCA,tagA]=allByTypeDual('distrNone','Average2Hz',-2,0.5,15,true,true);
[spkCB,tagB]=allByTypeDual('distrNone','Average2Hz',-2,0.5,15,false,true);