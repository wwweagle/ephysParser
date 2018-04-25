
function svmVPerfCrossCluster(inFile)

% saveDualCrossoverIncErrorFile();
% return;

% inFile='dualCrossSVM.mat';


%%%%%%%%onCluster%%%%%%%%%%
addpath('/home/zhangxiaoxing/libsvm-3.22/matlab');
% decRpt=500;
% permRpt=1000;

% %%%%%%%%%%local%%%%%%%%%
% addpath('R:\ZX\libsvm-3.22\windows\');
decRpt=500;
reSampRpt=100;
reSampleNum=85;
% permRpt=1000;
ts=21:24;
instCount=30;
load(inFile,'allSpks','allEvts');
fullSpks=allSpks;

delayLen=8;
tsLen=(delayLen+8)*2;

crange=2.^(-5:0.5:5);
grange=2.^(-13:0.5:-3);

avgAccu=nan(length(crange),length(grange),length(3:tsLen),3);
accuAll=nan(length(crange),length(grange),decRpt,3,tsLen+2);


for cIdx=1%:length(crange)
    for gIdx=1%:length(grange)
        cIdx=5;
        gIdx=7;
         c=crange(cIdx);
         g=grange(gIdx);
        
        accuracyAll=nan(decRpt,length(allSpks)/2-1,reSampRpt);
%         pvShufAll=nan(3,tsLen+2);
        futures=parallel.FevalFuture.empty(0,tsLen);
        perfIdx=nan(reSampleNum,reSampRpt);
         for rsRpt=1:reSampRpt
             selIdces=randperm(size(fullSpks{1},1),reSampleNum);
             allSpks=cellfun(@(x) x(selIdces),fullSpks,'UniformOutput',false);
             perfIdx(:,rsRpt)=selIdces;
             futures(rsRpt)=parfeval(@svmOneTSBin,1,ts,instCount,allSpks,decRpt,c,g);
%                         accuracyAll(:,:,ts)=svmOneTSBin(ts,instCount,allSpks,decRpt,c,g);
        end
        
        for rsRpt=1:reSampRpt
            fprintf('%d, ',rsRpt);
            accuracyAll(:,:,rsRpt)=fetchOutputs(futures(rsRpt));
        end
%         fprintf('\n');


        accuracy=squeeze(mean(accuracyAll));
        perf=cell2mat(arrayfun(@(x) cellfun(@(evts) nnz(xor(evts(:,1)==evts(:,5), evts(:,7)) & evts(:,3)==x)/nnz(evts(:,3)==x),allEvts{1}),[0 1 2],'UniformOutput',false))';
        
        fh=figure('Color','w');
        hold on;
        arrayfun(@(x) plot(accuracy(1,x),mean(perf(1,perfIdx(:,x))),'k.'),1:reSampRpt);
        arrayfun(@(x) plot(accuracy(3,x),mean(perf(3,perfIdx(:,x))),'b.'),1:reSampRpt);
        arrayfun(@(x) plot(accuracy(2,x),mean(perf(2,perfIdx(:,x))),'r.'),1:reSampRpt);
        
        perfCorr=cell2mat(arrayfun(@(y) arrayfun(@(x) mean(perf(y,perfIdx(:,x))),1:reSampRpt), (1:3)','UniformOutput',false));
        
        
        ylim([0.8,0.88])
        set(gca,'YTick',[0.8,0.85],'YTickLabel',[80,85],'XTick',50:10:70,'XTickLabel',0.5:0.1:0.7);
        set(gcf,'Position',[200,200,240,180])
        xlabel('DPA sample decoding accuracy')
        ylabel('Correct rate (%)');
        
        set(gcf, 'PaperPositionMode', 'auto');
        print('-depsc','-painters','-r1200','svmVPerf.eps')
        savefig('svmVPerf.fig');
        save('svmVPerfCorr.mat','perf','perfIdx','accuracy','accuracyAll');
        
 
%             avgAccu(cIdx,gIdx,:,(tIdx+1)/2)=mean(squeeze(accuracy(:,1,3:tsLen)));
% 
%             accuAll(cIdx,gIdx,:,:,:)=accuracy;
% 
%         save(sprintf('avgAccuCross%s.mat',inFile(1:end-4)),'avgAccu');
%         save(sprintf('accuCross%s.mat',inFile(1:end-4)),'accuracyAll','pvShufAll');
    end
end



end



function accuracy=svmOneTSBin(ts,instCount,allSpks,decRpt,c,g)

accuracy=nan(decRpt,length(allSpks)/2-1);
for rpt=1:decRpt
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
        
        
        testMat=(testMatRaw-repmat(min(instMatRaw),2,1))./repmat(scale,2,1);
        testMat(:,scale==0)=[];
        testLabelVec=[1;2];
        [prLbl,accuracyVec,~]=svmpredict(testLabelVec,testMat,svmModel);
        rtnIdx=(interest-1)/2;
        accuracy(rpt,rtnIdx)=accuracyVec(1);
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
test=cell2mat(arrayfun(@(x) sum(spksW_test{x}(:,testIdx(x),ts),3),1:length(testIdx),'UniformOutput',false)');
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
        cell2mat(arrayfun(@(j) sum(spks{paired(1,idces(j))}{i}(:,paired(2,idces(j)),ts),3),1:K,'UniformOutput',false))];
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
    [allSpks,allTags,~]=matchTag(allSpks,allTags,allSpks,i);
end

for i=1:length(allTags)
    [allSpks,allTags,~]=matchSU(allSpks,allTags,allSpks,i);
end

sel=cellfun(@(x) size(x,2),allSpks{1})>15 & cellfun(@(x) size(x,2),allSpks{2})>15;

save('dualCrossSVM.mat','allTags','allSpks','nameTags');
fprintf('%d\n',sum(cellfun(@(x) size(x,1),spkCA)));
end



function saveDualCrossoverIncErrorFile()

[spkCA,tagA,evtsA]=allByTypeDual('sampleIncError','Average2Hz',-2,0.5,15,true,true);
[spkCB,tagB,evtsB]=allByTypeDual('sampleIncError','Average2Hz',-2,0.5,15,false,true);

[spkCANone,tagANone,evtsANone]=allByTypeDual('distrNoneIncError','Average2Hz',-2,0.5,15,true,true);
[spkCBNone,tagBNone,evtsBNone]=allByTypeDual('distrNoneIncError','Average2Hz',-2,0.5,15,false,true);


[spkCAGo,tagAGo,evtsAGo]=allByTypeDual('distrGoIncError','Average2Hz',-2,0.5,15,true,true);
[spkCBGo,tagBGo,evtsBGo]=allByTypeDual('distrGoIncError','Average2Hz',-2,0.5,15,false,true);

[spkCANogo,tagANogo,evtsANogo]=allByTypeDual('distrNogoIncError','Average2Hz',-2,0.5,15,true,true);
[spkCBNogo,tagBNogo,evtsBNogo]=allByTypeDual('distrNogoIncError','Average2Hz',-2,0.5,15,false,true);

allTags={tagA,tagB,tagANone,tagBNone,tagAGo,tagBGo,tagANogo,tagBNogo};
allSpks={spkCA,spkCB,spkCANone,spkCBNone,spkCAGo,spkCBGo,spkCANogo,spkCBNogo};
allEvts={evtsA,evtsB,evtsANone,evtsBNone,evtsAGo,evtsBGo,evtsANogo,evtsBNogo};
nameTags={'spkCA','spkCB','spkCANone','spkCBNone','spkCAGo','spkCBGo','spkCANogo','spkCBNogo'};


for i=1:length(allTags)
    [allSpks,allTags,allEvts]=matchTag(allSpks,allTags,allEvts,i);
end

for i=1:length(allTags)
    [allSpks,allTags,allEvts]=matchSU(allSpks,allTags,allEvts,i);
end

% sel=cellfun(@(x) size(x,2),allSpks{1})>15 & cellfun(@(x) size(x,2),allSpks{2})>15;

save('dualIncErrorCrossSVM.mat','allTags','allSpks','allEvts','nameTags');
fprintf('%d\n',sum(cellfun(@(x) size(x,1),spkCA)));
end


function [spks,tags,evts]=matchTag(spks,tags,evts,idx)
tempTag=true(length(tags{idx}),1);
for i=1:length(tags)
    if i==idx
        continue;
    end
    tempTag=tempTag & ismember(tags{idx}(:,1),tags{i}(:,1));
end
spks{idx}=spks{idx}(tempTag);
evts{idx}=evts{idx}(tempTag);
tags{idx}=tags{idx}(tempTag,:);
end


function [spks,tags,evts]=matchSU(spks,tags,evts,idx)
for j=1:length(tags)
    if j==idx
        continue;
    end
    for i=1:size(tags{j},1)
        spks{idx}{i}=spks{idx}{i}(ismember(tags{idx}{i,2},tags{j}{i,2},'rows'),:,:);
%         evts{idx}{i}=evts{idx}{i}(ismember(tags{idx}{i,2},tags{j}{i,2},'rows'),:,:);
        if isempty(spks{idx}{i})
            evts{idx}{i}=[];
        end
        tags{idx}{i,2}=tags{idx}{i,2}(ismember(tags{idx}{i,2},tags{j}{i,2},'rows'),:);
    end
end
end

