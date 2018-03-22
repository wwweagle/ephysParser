function svm
% pause();
decRpt=500;
permRpt=500;
% delayLen=4;
fstr=load('4s.mat');
spkCA=fstr.spkCA;
spkCB=fstr.spkCB;
% [spkCA,~]=allByTypeDNMS('sample','Average2Hz',-2,0.5,11,true,delayLen,true);
% [spkCB,~]=allByTypeDNMS('sample','Average2Hz',-2,0.5,11,false,delayLen,true);
% instanceCount=min([cellfun(@(x) size(x,2),spkCA); cellfun(@(x) size(x,2), spkCB)]);
instanceCount=40;
sel=(cellfun(@(x) size(x,2),spkCA)>41 & cellfun(@(x) size(x,2), spkCB)>41);
spkCA=spkCA(sel);
spkCB=spkCB(sel);


crange=2.^[-1:5];
grange=2.^[-9:-3];

for cIdx=1:length(crange)
    for gIdx=1:length(grange)
    c=crange(cIdx);
    g=grange(gIdx);
accuracy=nan(decRpt,2,26);

futures=parallel.FevalFuture.empty(0,24);
for ts=3:24
    futures(ts)=parfeval(@svmOneTSBin,1,ts,instanceCount,spkCA,spkCB,decRpt);
end

for ts=3:24
    accuracy(:,:,ts)=fetchOutputs(futures(ts)); 
end
% plot(mean(accuracy));

pvShuf=nan(1,26);
for ts=3:24
    currDiff=abs(mean(accuracy(:,1,ts))-mean(accuracy(:,2,ts)));
    flat=@(x) x(:);
    pool=flat(accuracy(:,:,ts));
    shufDiff=nan(permRpt);
    for i=1:permRpt
        sPool=pool(randperm(length(pool)));
        shufDiff(i)=abs(mean(sPool(1:size(accuracy,1)))-mean(sPool(size(accuracy,1)+1:end)));
    end
    pvShuf(ts)=nnz(shufDiff>=currDiff)/permRpt;
end

disp(pvShuf);
 
fh=figure('Color','w');
hold on;
ci=bootci(100,@mean,accuracy(:,1,3:24));
ciShuf=bootci(100,@mean, accuracy(:,2,3:24));
fill([3:24,24:-1:3]-2,[ci(1,:),fliplr(ci(2,:))]./100,[1,0.8,0.8],'EdgeColor','none');
fill([3:24,24:-1:3]-2,[ciShuf(1,:),fliplr(ciShuf(2,:))]./100,[0.8,0.8,0.8],'EdgeColor','none');
plot(mean(squeeze(accuracy(:,1,3:24)))./100,'-r','LineWidth',1);
plot(mean(squeeze(accuracy(:,2,3:24)))./100,'-k','LineWidth',1);


arrayfun(@(x) plot([x,x],ylim(),':k'),[1 2 6 7]*2+0.5);
set(gca,'XTick',[0:5:10]*2+0.5,'XTickLabel',0:5:10);
xlim([0,18]);
ylim([0.4,1]);
xlabel('Time (s)');
ylabel('Sample Decoding Accuracy');
title(sprintf('c@%d, g@%0.4f',c,g));
print(sprintf('SVM4s_c%d_g%0.4f.png',c,g),'-dpng');
close(fh);
    end
end

function accuracy=svmOneTSBin(ts,instCount,spkCA,spkCB,decRpt)
    accuracy=nan(decRpt,2);
    for rpt=1:decRpt
        instPerSess=[cellfun(@(x) size(x,2),spkCA); cellfun(@(x) size(x,2), spkCB)];
        instIdces=arrayfun(@(x) randperm(x,instCount+1),instPerSess,'UniformOutput',false);
        testInstIdces=cellfun(@(x) x(1),instIdces);
        instIdces=cell2mat(cellfun(@(x) x(2:end),instIdces,'UniformOutput',false));
              
        instMatRaw=[cell2mat(arrayfun(@(x) spkCA{x}(:,instIdces(x,:),ts),(1:length(instIdces)/2)','UniformOutput',false)),...
            cell2mat(arrayfun(@(x) spkCB{x}(:,instIdces(x+length(instIdces)/2,:),ts),(1:length(instIdces)/2)','UniformOutput',false))]';
        
        testMatRaw=[cell2mat(arrayfun(@(x) spkCA{x}(:,testInstIdces(x,:),ts),(1:length(testInstIdces)/2)','UniformOutput',false)),...
            cell2mat(arrayfun(@(x) spkCB{x}(:,testInstIdces(x+length(testInstIdces)/2,:),ts),(1:length(testInstIdces)/2)','UniformOutput',false))]';

        
%         
%         instMatRaw=[cell2mat(cellfun(@(x) x(:,instIdces,ts), spkCA,'UniformOutput',false)),...
%             cell2mat(cellfun(@(x) x(:,instIdces,ts), spkCB,'UniformOutput',false))]';
        
        scale=(max(instMatRaw)-min(instMatRaw));%1x205
        instMat=(instMatRaw-repmat(min(instMatRaw),2*instCount,1))./repmat(scale,2*instCount,1);
        instMat(:,scale==0)=0;
%         testMatRaw=[cell2mat(cellfun(@(x) x(:,testInstIdx,ts), spkCA,'UniformOutput',false)),...
%             cell2mat(cellfun(@(x) x(:,testInstIdx,ts), spkCB,'UniformOutput',false))]';
        testMat=(testMatRaw-repmat(min(instMatRaw),2,1))./repmat(scale,2,1);
        testMat(:,scale==0)=0;
        labelVec=[ones(instCount,1);ones(instCount,1)*2];
        testLabelVec=[1;2];

        svmModel=svmtrain(labelVec,instMat,sprintf('-q -t 2 -c %d -g %0.4f',c,g));
        [~,accuracyVec,~]=svmpredict(testLabelVec,testMat,svmModel);
        accuracy(rpt,1)=accuracyVec(1);

        svmModel=svmtrain(labelVec(randperm(length(labelVec))),instMat,sprintf('-q -t 2 -c %d -g %0.4f',c,g));
        [~,accuracyVec,~]=svmpredict(testLabelVec,testMat,svmModel);
        accuracy(rpt,2)=accuracyVec(1);
    end

end

end

% 
% 
% 
% 
% 
% delayLen=8;
% [spkCA,~]=allByTypeDNMS('sample','Average2Hz',-2,0.5,15,true,delayLen,true);
% [spkCB,~]=allByTypeDNMS('sample','Average2Hz',-2,0.5,15,false,delayLen,true);
% min([cellfun(@(x) size(x,2), spkCA),cellfun(@(x) size(x,2), spkCB)]);
% 
% accuracy=nan(34,34);
% for ts=3:32
% % crange=2.^[-11:-5];
% % accuracy=nan(35,length(crange));
% % for c=1:length(crange)
% %     ts=23;
%     for testInstIdx=1:35
%         instIdces=find(~ismember(1:35,testInstIdx));
%         instMatRaw=[cell2mat(cellfun(@(x) x(:,instIdces,ts), spkCA,'UniformOutput',false)),...
%             cell2mat(cellfun(@(x) x(:,instIdces,ts), spkCB,'UniformOutput',false))]';
%         
%         scale=(max(instMatRaw)-min(instMatRaw));
%         instMat=(instMatRaw-min(instMatRaw))./scale;
%         instMat(:,scale==0)=0;
%         testMatRaw=[cell2mat(cellfun(@(x) x(:,testInstIdx,ts), spkCA,'UniformOutput',false)),...
%             cell2mat(cellfun(@(x) x(:,testInstIdx,ts), spkCB,'UniformOutput',false))]';
%         testMat=(testMatRaw-min(instMatRaw))./scale;
%         testMat(:,scale==0)=0;
%         labelVec=[ones(34,1);ones(34,1)*2];
%         testLabelVec=[1;2];
% 
%         svmModel=svmtrain(labelVec,instMat,['-t 2 -c 4 -g 0.015']);
% 
%         [predictedLabel,accuracyVec,~]=svmpredict(testLabelVec,testMat,svmModel);
%         accuracy(testInstIdx,ts)=accuracyVec(1);
% %          accuracy(testInstIdx,c)=accuracyVec(1);
%         
%     end
% end
% % plot(mean(accuracy));
% 
% figure('Color','w');
% hold on;
% ci=bootci(100,@(x) mean(x),accuracy(:,3:32));
% fill([3:32,32:-1:3]-2,[ci(1,:),fliplr(ci(2,:))]./100,[1,0.8,0.8],'EdgeColor','none');
% plot(mean(accuracy(:,3:32))./100,'-r','LineWidth',1);
% arrayfun(@(x) plot([x,x],ylim(),':k'),[1 2 10 11]*2+0.5);
% set(gca,'XTick',[0:5:10]*2+0.5,'XTickLabel',0:5:10);
% xlim([0,26]);
% ylim([0.4,1]);
% xlabel('Time (s)');
% ylabel('Sample Decoding Accuracy');