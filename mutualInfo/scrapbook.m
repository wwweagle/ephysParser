[spkCA,uniqTag]=allByTypeDual('sample','Average2Hz',-2,0.1,15,true,true);
[spkCB,~]=allByTypeDual('sample','Average2Hz',-2,0.1,15,false,true);
save('dualAll.mat','spkCA','spkCB','uniqTag');

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
