function svmCrossCluster()

%%%%%%%%onCluster%%%%%%%%%%
addpath('/home/zhangxiaoxing/libsvm-3.22/matlab');
decRpt=500;
permRpt=1000;

% %%%%%%%%%%local%%%%%%%%%
% addpath('R:\ZX\libsvm-3.22\windows\');
% decRpt=5%00;
% permRpt=10%00;

instCount=30;
load('dualCrossSVM.mat','allSpks');
delayLen=8;
tsLen=(delayLen+8)*2;

crange=2.^(-5:0.5:5);
grange=2.^(-10:0.5:0);

avgAccu=nan(length(crange),length(grange),length(3:tsLen),3);

for cIdx=1%:length(crange)
    for gIdx=1%:length(grange)
         c=crange(5);
         g=grange(7);
        
        accuracyAll=nan(decRpt,length(allSpks)-2,(tsLen+2));
        pvShufAll=nan(3,tsLen+2);
        futures=parallel.FevalFuture.empty(0,tsLen);
        for ts=3:tsLen
            futures(ts)=parfeval(@svmOneTSBin,1,ts,instCount,allSpks,decRpt,c,g);
%                         accuracyAll(:,:,ts)=svmOneTSBin(ts,instCount,allSpks,decRpt,c,g);
        end
        
        for ts=3:tsLen
            accuracyAll(:,:,ts)=fetchOutputs(futures(ts));
        end
        
        for tIdx=1:2:size(accuracyAll,2)
            accuracy=nan(decRpt,3,(tsLen+2));
            accuracy(:,[1 3],:)=accuracyAll(:,tIdx:tIdx+1,:);

            pvShuf=permTest(tsLen,accuracy,1,3,permRpt).*(tsLen-2);
            
            fh=figure('Color','w','Position',[1000,100,250,180]);
            hold on;
            ci=bootci(100,@mean,accuracy(:,1,3:tsLen));
            
            ciShuf=bootci(100,@mean, accuracy(:,3,3:tsLen));
            fill([3:tsLen,tsLen:-1:3]-2,[ci(1,:),fliplr(ci(2,:))]./100,[1,0.8,0.8],'EdgeColor','none');
            
            fill([3:tsLen,tsLen:-1:3]-2,[ciShuf(1,:),fliplr(ciShuf(2,:))]./100,[0.8,0.8,0.8],'EdgeColor','none');
            plot(mean(squeeze(accuracy(:,1,3:tsLen)))./100,'-r','LineWidth',1);
            
            plot(mean(squeeze(accuracy(:,3,3:tsLen)))./100,'-k','LineWidth',1);
            
            for i=3:tsLen-1
                if max(pvShuf(1,i:i+1))<0.001
                    plot(i-2:i-1,[0.425,0.425],'-r','LineWidth',1);
                end
            end
            
            
            arrayfun(@(x) plot([x,x],ylim(),':k'),[1 2 delayLen+2 delayLen+3]*2+0.5);
            set(gca,'XTick',[0:5:10]*2+0.5,'XTickLabel',0:5:10,'YTick',0.5:0.25:1);
            xlim([0,tsLen-6]);
            ylim([0.4,1]);
            xlabel('Time (s)');
            ylabel('Sample decoding accuracy');
            title(sprintf('%s, c@%.4f, g@%0.4f, n = %d',sprintf('dualCross %d ',tIdx),c,g,sum(cellfun(@(x) size(x,1),allSpks{1}))));
            print(sprintf('SVM%s_c%.4f_g%0.4f.png',sprintf('dualCross_%d_',tIdx),c,g),'-dpng');
            savefig(sprintf('SVM%s_c%.4f_g%0.4f.fig',sprintf('dualCross_%d_',tIdx),c,g));
            close(fh);
            avgAccu(cIdx,gIdx,:,(tIdx+1)/2)=mean(squeeze(accuracy(:,1,3:tsLen)));
            pvShufAll((tIdx+1)/2,:)=pvShuf;
        end
        save('avgAccuCross','avgAccu');
        save('accuCross','accuracyAll','pvShufAll');
    end
end



end



function accuracy=svmOneTSBin(ts,instCount,allSpks,decRpt,c,g)

accuracy=nan(decRpt,length(allSpks)-2);
for rpt=1:decRpt
%     instPerSess=[cell2mat(arrayfun(@(y) cellfun(@(x) size(x,2),allSpks{y}),[3 5 7],'UniformOutput',false));
%         cell2mat(arrayfun(@(y) cellfun(@(x) size(x,2),allSpks{y}),[4 6 8],'UniformOutput',false))];
%     instIdces=cell(size(instPerSess,1),instCount+1);
%     for i=1:size(instPerSess,1)
%         idces=flexPerm(sum(instPerSess(i,:)),instCount+1)
%         
%     end
%     
%     instIdces=cell2mat(arrayfun(@(x) flexPerm(x,instCount+1),instPerSess,'UniformOutput',false));
%   
%     instMatRaw=[cell2mat(arrayfun(@(x) allSpks{1}{x}(:,instIdces(x,:),ts),(1:size(instIdces,1)/2)','UniformOutput',false)),...
%         cell2mat(arrayfun(@(x) allSpks{2}{x}(:,instIdces(x+size(instIdces,1)/2,:),ts),(1:size(instIdces,1)/2)','UniformOutput',false))]';

    for interest=3:2:7
        noIntA=[3 5 7];
        noIntA(noIntA==interest)=[];
        noIntB=noIntA+1;
    [testA,templateA]=chooseKfromMultiN(allSpks(noIntA),allSpks{interest},instCount,ts);
    [testB,templateB]=chooseKfromMultiN(allSpks(noIntB),allSpks{interest+1},instCount,ts);
    instMatRaw=[templateA';templateB'];
    testMatRaw=[testA';testB'];
    
    scale=(max(instMatRaw)-min(instMatRaw));
    instMat=(instMatRaw-repmat(min(instMatRaw),2*instCount,1))./repmat(scale,2*instCount,1);
    instMat(:,scale==0)=[];
    labelVec=[ones(instCount,1);ones(instCount,1)*2];
    svmModel=svmtrain(labelVec,instMat,sprintf('-q -t 2 -c %.4f -g %0.4f',c,g));
    shufModel=svmtrain(labelVec(randperm(length(labelVec))),instMat,sprintf('-q -t 2 -c %.4f -g %0.4f',c,g));

        testMat=(testMatRaw-repmat(min(instMatRaw),2,1))./repmat(scale,2,1);
        testMat(:,scale==0)=[];
        testLabelVec=[1;2];
        [prLbl,accuracyVec,~]=svmpredict(testLabelVec,testMat,svmModel);
        rtnIdx=interest-2;
        accuracy(rpt,rtnIdx)=accuracyVec(1);
        [~,accuracyVec,~]=svmpredict(testLabelVec,testMat,shufModel);
        accuracy(rpt,rtnIdx+1)=accuracyVec(1);
    end
end
end
%cell2mat(arrayfun(@(x) allSpks{1}{x}(:,instIdces(x,:),ts),(1:size(instIdces,1)/2)','UniformOutput',false)),...
% function out=getInstCrossSrc(allSrc,srcIdces,idx)
% for j=1:length(idx)
%     for i=1:length(srcIdces)
%         if idx(j)<size(allSrc{srcIdces(i)}
%         end
%     end
% end
% end




function out=flexPerm(n,k)
if k<=sum(n)
    out=randperm(n,k);
else
    out=nan(1,k);
    pool=1:n;
    out(1)=randperm(n,1);
    pool(pool==out(1))=[];
    out(2:end)=datasample(pool,k-1);
end
end

function [test,template]=chooseKfromMultiN(spks,spksW_test,K,ts)
trialCounts=cellfun(@(x) size(x,2),spksW_test);
testIdx=arrayfun(@(x) randperm(x,1),trialCounts);
test=cell2mat(arrayfun(@(x) spksW_test{x}(:,testIdx(x),ts),1:length(testIdx),'UniformOutput',false)');
for i=1:length(testIdx)
    spksW_test{i}(:,testIdx(i),:)=[];
end
spks{length(spks)+1}=spksW_test;

suCount=cell2mat(arrayfun(@(y) ...
    cell2mat(cellfun(@(x) size(x,2),spks{y},'UniformOutput',false)),...
    1:length(spks),'UniformOutput',false));
template=[];
for i=1:size(suCount,1)
    paired=cell2mat(arrayfun(@(x) [repmat(x,1,suCount(i,x));1:suCount(i,x)],1:size(suCount,2),'UniformOutput',false));
    idces=flexPerm(sum(suCount(i,:)),K);
    template=[template;...
        cell2mat(arrayfun(@(j) spks{paired(1,idces(j))}{i}(:,paired(2,idces(j)),ts),1:K,'UniformOutput',false))];
end
end



function pvShufOne=permTest(tsLen,accuracy,a,b,permRpt)
pvShufOne=nan(1,tsLen+2);
for ts=3:tsLen
    currDiff=abs(mean(accuracy(:,a,ts))-mean(accuracy(:,b,ts)));
    flat=@(x) x(:);
    pool=flat(accuracy(:,[a b],ts));
    shufDiff=nan(permRpt);
    for rpt=1:permRpt
        sPool=pool(randperm(length(pool)));
        shufDiff(rpt)=abs(mean(sPool(1:size(accuracy,1)))-mean(sPool(size(accuracy,1)+1:end)));
    end
    pvShufOne(ts)=nnz(shufDiff>=currDiff)/permRpt;
end
end


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

save('dualCrossSVM.mat','allTags','allSpks','nameTags');
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
