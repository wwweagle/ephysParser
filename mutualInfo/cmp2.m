pCrossTime=cell(0,0);
Im=cell(0,0);

    wd=pwd();
    cd r:\ZX\APC\RecordingAug16\
%     [spkCA,uniqTagA]=allByTypeDNMS('sample','Average2Hz',-2,0.1,11,true,delayLen,true);
%     [spkCB,uniqTagB]=allByTypeDNMS('sample','Average2Hz',-2,0.1,11,false,delayLen,true);
[spkCA,uniqTag]=allByTypeDual('distrNogo','Average2Hz',-2,0.1,15,true,true);
[spkCB,~]=allByTypeDual('distrNogo','Average2Hz',-2,0.1,15,false,true);
    cd(wd);

fidx=0;
tag=cell(0,0);
for f= 1:length(spkCA)
    for u=1:size(spkCA{f},1)
        fidx=fidx+1;
        tag{fidx}={uniqTag{f,1},uniqTag{f,2}(u,:)};
        futures(fidx)=parfeval(@plotOne,2,spkCA,spkCB,f,u,'8sNogo');
    end
end

for ffidx=1:fidx
    try
        [ps,ims]=fetchOutputs(futures(ffidx));
        fprintf('%d,',ffidx);
        pCrossTime=[pCrossTime;{tag{ffidx},ps}];
        Im=[Im;{tag{ffidx},ims}];
    catch ME
        disp(ffidx);
        disp(ME.identifier); 
    end
end

save('Im8sNogo.mat','pCrossTime','Im');