function svmCluster()

%%%%%%%%%onCluster%%%%%%%%%%
addpath('/home/zhangxiaoxing/libsvm-3.22/matlab');
decRpt=500;
permRpt=1000;

%%%%%%%%%%local%%%%%%%%%
% addpath('R:\ZX\libsvm-3.22\windows\');
% decRpt=50;
% permRpt=100;

% saveFile(delayLen,dataFile);

instCount=30;
dataFile='multiSamples.mat';
load(dataFile,'samples');
delayLen=5;
tsLen=(delayLen+8)*2;
crange=2.^(-6:2:6);
grange=2.^(-12:2:0);

%crange=2.^(-5:0.5:5);
%grange=2.^(-13:0.5:-3);


avgAccu=nan(length(crange),length(grange),length(3:tsLen),2);
accuAll=nan(length(crange),length(grange),decRpt,3,tsLen+2);
pvShufAll=nan(length(crange),length(grange),tsLen+2);
for cIdx=1:length(crange)
    for gIdx=1:length(grange)
        c=crange(cIdx);
        g=grange(gIdx);
        accuracy=nan(decRpt,3,tsLen+2);
        
        futures=parallel.FevalFuture.empty(0,tsLen);
        for ts=3:tsLen
            futures(ts)=parfeval(@svmOneTSBin,1,ts,instCount,samples,decRpt,c,g);
%             accuracy(:,:,ts)=svmOneTSBin(ts,instCount,samples,decRpt,c,g);
        end
        
        for ts=3:tsLen
            accuracy(:,:,ts)=fetchOutputs(futures(ts));
        end

%         accuracy=accu(randperm(1000,500),:,:);
%         accuracy(:,3,:)=accuracy(:,2,:);
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
            if max(pvShuf(i:i+1))<0.001
                plot(i-2:i-1,[0.05,0.05],'-r','LineWidth',1);
            end
        end
        
        
        arrayfun(@(x) plot([x,x],ylim(),':k'),[1 2 delayLen+2 delayLen+3]*2+0.5);
        set(gca,'XTick',[1:5:11]*2+0.5,'XTickLabel',0:5:10,'YTick',0:0.5:1);
        xlim([0,tsLen-6]);
        ylim([0,1]);
        xlabel('Time (s)');
        ylabel('Sample decoding accuracy');
        title(sprintf('%s, c@%.4f, g@%0.4f, n = %d',strrep(dataFile,'.mat',''),c,g,sum(cellfun(@(x) size(x,1),samples{1}))));
        print(sprintf('SVM%s_c%.4f_g%0.4f.png',dataFile,c,g),'-dpng');
%         close(fh);
        avgAccu(cIdx,gIdx,:,1)=mean(squeeze(accuracy(:,1,3:tsLen)));
        avgAccu(cIdx,gIdx,:,2)=mean(squeeze(accuracy(:,2,3:tsLen)));
        accuAll(cIdx,gIdx,:,:,:)=accuracy;
        pvShufAll(cIdx,gIdx,:)=pvShuf;
        save(sprintf('avgAccu%s',dataFile),'avgAccu');
        save(sprintf('Accu%s',dataFile),'accuAll','pvShufAll');
    end
end

end


function accuracy=svmOneTSBin(ts,instCount,allSpks,decRpt,c,g)

accuracy=nan(decRpt,3);
for rpt=1:decRpt
    test=cell(1,6);
    template=cell(1,6);
    for sampIdx=1:6
        [test{sampIdx},template{sampIdx}]=chooseKfromMultiN(allSpks{sampIdx},true,instCount,ts);
    end
    
    instMatRaw=cell2mat(template)';
    testMatRaw=cell2mat(test)';
    
    scale=(max(instMatRaw)-min(instMatRaw));
    instMat=(instMatRaw-repmat(min(instMatRaw),instCount*6,1))./repmat(scale,instCount*6,1);
    instMat(:,scale==0)=[];
    labelVec=cell2mat(arrayfun(@(x) repmat(x,instCount,1),(1:6)','UniformOutput',false));
    svmModel=svmtrain(labelVec,instMat,sprintf('-q -t 2 -c %.4f -g %0.4f',c,g));
    shufModel=svmtrain(labelVec(randperm(length(labelVec))),instMat,sprintf('-q -t 2 -c %.4f -g %0.4f',c,g));
    
    testMat=(testMatRaw-repmat(min(instMatRaw),6,1))./repmat(scale,6,1);
    testMat(:,scale==0)=[];
    testLabelVec=(1:6)';
    [prLbl,accuracyVec,~]=svmpredict(testLabelVec,testMat,svmModel);
    accuracy(rpt,1)=accuracyVec(1);
    [~,accuracyVec,~]=svmpredict(testLabelVec,testMat,shufModel);
    accuracy(rpt,3)=accuracyVec(1);
    
end
end
% 
% function [test,template]=chooseKfromMultiN(spks,spksW_test,K,ts)
% trialCounts=cellfun(@(x) size(x,2),spksW_test);
% testIdx=arrayfun(@(x) randperm(x,1),trialCounts);
% test=cell2mat(arrayfun(@(x) spksW_test{x}(:,testIdx(x),ts),1:length(testIdx),'UniformOutput',false)');
% for i=1:length(testIdx)
%     spksW_test{i}(:,testIdx(i),:)=[];
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%
% % full or partial cross %
% %%%%%%%%%%%%%%%%%%%%%%%%%
% spks{length(spks)+1}=spksW_test;
% 
% suCount=cell2mat(arrayfun(@(y) ...
%     cell2mat(cellfun(@(x) size(x,2),spks{y},'UniformOutput',false)),...
%     1:length(spks),'UniformOutput',false));
% template=[];
% templateLabel=[];
% for i=1:size(suCount,1)
%     paired=cell2mat(arrayfun(@(x) [repmat(x,1,suCount(i,x));1:suCount(i,x)],1:size(suCount,2),'UniformOutput',false));
%     idces=flexPerm(sum(suCount(i,:)),K);
%     template=[template;...
%         cell2mat(arrayfun(@(j) spks{paired(1,idces(j))}{i}(:,paired(2,idces(j)),ts),1:K,'UniformOutput',false))];
%     templateLabel=[templateLabel;...
%         ];
% end
% end


function [test,template]=chooseKfromMultiN(spk,isTest,K,ts)
trialCounts=cellfun(@(x) size(x,2),spk);
if isTest
    testIdx=arrayfun(@(x) randperm(x,1),trialCounts);
    test=cell2mat(arrayfun(@(x) spk{x}(:,testIdx(x),ts),1:length(testIdx),'UniformOutput',false)');
    for i=1:length(testIdx)
        spk{i}(:,testIdx(i),:)=[];
    end
    trialCounts=trialCounts-1;
end
idces=arrayfun(@(x) flexPerm(x,K),trialCounts,'UniformOutput',false);
template=cell2mat(arrayfun(@(x) spk{x}(:,idces{x},ts),(1:length(idces))','UniformOutput',false));
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


function plotAdditionalDec
ci=bootci(100,@(x) mean(x),squeeze(accuracy(:,1,3:end-2)))./100;
fill([1:length(ci),length(ci):-1:1],[ci(1,:),fliplr(ci(2,:))],[0.8,0.8,1],'EdgeColor','none');
plot(mean(squeeze(accuracy(:,1,3:end-2))./100),'-b','LineWidth',1);
xlim([0,length(ci)-6]);

        for i=3:length(pvShuf)-1
%             fprintf('%.4f,',max(pvShuf(1,i:i+1)))
            if max(pvShuf(1,i:i+1))<0.001
                plot(i-2:i-1,[0.45,0.45],'-b','LineWidth',1);
            end
        end

end
