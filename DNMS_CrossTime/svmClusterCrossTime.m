function accuracy=svmClusterCrossTime(dataFile,decRpt,shuffle)
disp('**imagesc(squeeze(mean(accuracy(:,1,3:end-2,3:end-2),1))))**');
if ~exist('decRpt','var')
    decRpt=2;
end

if isunix &&~ismac
    %%%%%%%%%onCluster%%%%%%%%%%
    addpath('/ion/fnc/zhangxiaoxing/libsvm-3.22/matlab');

elseif ispc
    %%%%%%%%%%local%%%%%%%%%09jm
    addpath('R:\ZX\libsvm-3.22\windows\');
else
    disp('Failed adding svm lib path');
    return
end
% saveFile(delayLen,dataFile);

instCount=30;
fstr=load(dataFile);
delayLen=(size(fstr.spkCA{1},3)-18)/2;

tsLen=(delayLen+8)*2;


spkCA=fstr.spkCA;
spkCB=fstr.spkCB;


% avgAccu=nan(length(3:tsLen),length(3:tsLen),2);
accuracyAll=nan(decRpt,3,(tsLen+2),(tsLen+2));
% pvShufAll=nan  (length(crange),length(grange),3,(tsLen+2),(tsLen+2));


switch delayLen
    case 8
        c=3.2490;
        g=0.1088;
    case 4
        c=1.8661;
        g=0.0292;
end

accuracy=nan(decRpt,2,(tsLen+2),(tsLen+2));
futures=parallel.FevalFuture.empty(0,tsLen,tsLen);

for ts=3:tsLen
    for tsTest=3:tsLen
            futures(ts,tsTest)=parfeval(@svmOneTSBin,1,ts,tsTest,instCount,spkCA,spkCB,decRpt,c,g);
%             accuracy(:,:,ts)=svmOneTSBin(ts,instCount,spkCA,spkCB,decRpt,c,g);
    end
end

for ts=3:tsLen
    for tsTest=3:tsLen
        accuracy(:,:,ts,tsTest)=fetchOutputs(futures(ts,tsTest));
        fprintf('%d,%d\n',ts,tsTest);
    end
end
save(sprintf('Accu%s%s.mat',replace(dataFile,'.mat',''),datestr(now(),'_yymmdd_hhMM')),'accuracy');

end



function accuracy=svmOneTSBin(ts,tsTest,instCount,spkCA,spkCB,decRpt,c,g)
accuracy=nan(decRpt,2);
for rpt=1:decRpt
    instPerSess=[cellfun(@(x) size(x,2),spkCA); cellfun(@(x) size(x,2), spkCB)];
    instIdces=cell2mat(arrayfun(@(x) flexPerm(x,instCount+1),instPerSess,'UniformOutput',false));
    testInstIdces=instIdces(:,1);
    instIdces=instIdces(:,2:end);
    
    instMatRaw=[cell2mat(arrayfun(@(x) spkCA{x}(:,instIdces(x,:),ts),(1:size(instIdces,1)/2)','UniformOutput',false)),...
        cell2mat(arrayfun(@(x) spkCB{x}(:,instIdces(x+size(instIdces,1)/2,:),ts),(1:size(instIdces,1)/2)','UniformOutput',false))]';
    
    testMatRaw=[cell2mat(arrayfun(@(x) spkCA{x}(:,testInstIdces(x,:),tsTest),(1:size(testInstIdces,1)/2)','UniformOutput',false)),...
        cell2mat(arrayfun(@(x) spkCB{x}(:,testInstIdces(x+size(testInstIdces,1)/2,:),tsTest),(1:size(testInstIdces,1)/2)','UniformOutput',false))]';

    scale=(max(instMatRaw)-min(instMatRaw));%1x205
    instMat=(instMatRaw-repmat(min(instMatRaw),2*instCount,1))./repmat(scale,2*instCount,1);
    instMat(:,scale==0)=[];
    
    testMat=(testMatRaw-repmat(min(instMatRaw),2,1))./repmat(scale,2,1);
    testMat(:,scale==0)=[];
    
    labelVec=[ones(instCount,1);ones(instCount,1)*2];
    testLabelVec=[1;2];
    
        
    svmModel=svmtrain(labelVec,instMat,sprintf('-q -t 2 -c %.4f -g %0.4f',c,g));
    [prLbl,accuracyVec,~]=svmpredict(testLabelVec,testMat,svmModel);
    accuracy(rpt,1)=accuracyVec(1);
    
    svmModel=svmtrain(labelVec(randperm(length(labelVec))),instMat,sprintf('-q -t 2 -c %.4f -g %0.4f',c,g));
    [~,accuracyVec,~]=svmpredict(testLabelVec,testMat,svmModel);
    accuracy(rpt,2)=accuracyVec(1);
end
end




function out=flexPerm(n,k)
if k<=n
    out=randperm(n,k);
else
    out=nan(1,k);
    pool=1:n;
    out(1)=randperm(n,1);
    pool(pool==out(1))=[];
    out(2:end)=datasample(pool,k-1);
end
end


function pvShufOne=permTest(tsLen,accuracy,a,b,permRpt)
pvShufOne=nan(tsLen+2,tsLen+2);
for ts=3:tsLen
    for tsTest=3:tsLen
        currDiff=abs(mean(accuracy(:,a,ts,tsTest))-mean(accuracy(:,b,ts,tsTest)));
        flat=@(x) x(:);
        pool=flat(accuracy(:,[a b],ts,tsTest));
        shufDiff=nan(1,permRpt);
        for rpt=1:permRpt
            sPool=pool(randperm(length(pool)));
            shufDiff(rpt)=abs(mean(sPool(1:size(accuracy,1)))-mean(sPool(size(accuracy,1)+1:end)));
        end
        pvShufOne(ts,tsTest)=nnz(shufDiff>=currDiff)/permRpt;
    end
end
end

