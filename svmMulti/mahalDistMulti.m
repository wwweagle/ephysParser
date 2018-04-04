load('multiSamplesCross.mat','samples');

distRpt=1;
permRpt=1000;
instCount=50;
tsLen=(delayLen+8)*10;

dist=nan(distRpt*2*instCount,2,tsLen+2);

futures=parallel.FevalFuture.empty(0,tsLen);
for ts=3:tsLen
    futures(ts)=parfeval(@mahalOne,1,ts,instCount,samples,distRpt);
%                 dist(:,:,ts)=mahalOne(ts,instCount,samples,distRpt);
end

for ts=3:tsLen
    dist(:,:,ts)=fetchOutputs(futures(ts));
end

%         accuracy=accu(randperm(1000,500),:,:);
%         accuracy(:,3,:)=accuracy(:,2,:);
close all;
figure('Color','w','Position',[100,100,275,220]);
hold on;
pvShuf=permTest(tsLen,dist,1,2,permRpt).*(tsLen-2);
ciWithin=bootci(100,@mean,squeeze(dist(:,1,3:tsLen-2)));
ciBetween=bootci(100,@mean, squeeze(dist(:,2,3:tsLen-2)));
fill([3:tsLen-2,tsLen-2:-1:3]-2,[(ciWithin(1,:)),(fliplr(ciWithin(2,:)))],[1,0.8,0.8],'EdgeColor','none');
fill([3:tsLen-2,tsLen-2:-1:3]-2,[(ciBetween(1,:)),(fliplr(ciBetween(2,:)))],[0.8,0.8,1],'EdgeColor','none');
plot((squeeze(mean(dist(:,1,3:tsLen-2)))),'-r','LineWidth',1);
plot((squeeze(mean(dist(:,2,3:tsLen-2)))),'-b','LineWidth',1);



for i=3:tsLen-1
    if max(pvShuf(i:i+1))<0.001
        plot(i-2:i-1,[0.05,0.05],'-r','LineWidth',1);
    end
end



arrayfun(@(x) plot([x,x],ylim(),':k'),[0 1 6 7]*10+18.5);
set(gca,'XTick',[1:5:11]*10+8.5,'XTickLabel',0:5:10);
xlim([9,98]);
% ylim([0,1]);
xlabel('Time (s)');
ylabel('Mahalanobis distance');
fname=sprintf('MahalDist_%d',randi(1000000));
savefig([fname,'.fig']);
print([fname,'.png'],'-dpng','-r0');
% title(sprintf('%s, c@%.4f, g@%0.4f, n = %d',strrep(dataFile,'.mat',''),c,g,sum(cellfun(@(x) size(x,1),samples{1}))));
% print(sprintf('SVM%s_c%.4f_g%0.4f.png',dataFile,c,g),'-dpng');
%         close(fh);
% avgAccu(cIdx,gIdx,:,1)=mean(squeeze(dist(:,1,3:tsLen)));
% avgAccu(cIdx,gIdx,:,2)=mean(squeeze(dist(:,2,3:tsLen)));
% accuAll(cIdx,gIdx,:,:,:)=dist;
% pvShufAll(cIdx,gIdx,:)=pvShuf;
% save(sprintf('avgAccu%s',dataFile),'avgAccu');
% save(sprintf('Accu%s',dataFile),'accuAll','pvShufAll');





function dist=mahalOne(ts,instCount,allSpks,disRpt)
dist=nan(disRpt*2*instCount,2);

for rpt=1:disRpt
    grpA=[1 4 6];
    grpB=[2 3 5];
    testIdxA=grpA(randperm(3,1));
    testIdxB=grpB(randperm(3,1));
    
    sampleIdces=1:6;
    sampleIdces(ismember(sampleIdces,[testIdxA,testIdxB]))=[];
    
    test=cell(1,2);
    template=cell(1,5);
    
    [~,test{1}]=chooseKfromMultiN(allSpks{testIdxA},false,instCount,ts);
    [~,test{2}]=chooseKfromMultiN(allSpks{testIdxB},false,instCount,ts);
    for sampIdx=1:4
        [~,template{sampIdx}]=chooseKfromMultiN(allSpks{sampleIdces(sampIdx)},false,instCount,ts);
    end
    
    grpA=cell2mat(template(ismember(sampleIdces,[1 4 6])))';
    grpB=cell2mat(template(~ismember(sampleIdces,[1 4 6])))';
    
    dist((rpt-1)*2*instCount+1:rpt*2*instCount,1)=[mahal(test{1}',grpA);mahal(test{2}',grpB)];
    dist((rpt-1)*2*instCount+1:rpt*2*instCount,2)=[mahal(test{1}',grpB);mahal(test{2}',grpA)];
    dist(isnan(dist))=-1;
   
end
end



function [test,template]=chooseKfromMultiN(spk,isTest,K,ts)
trialCounts=cellfun(@(x) size(x,2),spk);
if isTest
    testIdx=arrayfun(@(x) randperm(x,1),trialCounts);
    test=cell2mat(arrayfun(@(x) sum(spk{x}(:,testIdx(x),ts-2:ts+2),3),1:length(testIdx),'UniformOutput',false)');
    for i=1:length(testIdx)
        spk{i}(:,testIdx(i),:)=[];
    end
    trialCounts=trialCounts-1;
else
    test=nan;
end
idces=arrayfun(@(x) flexPerm(x,K),trialCounts,'UniformOutput',false);
template=cell2mat(arrayfun(@(x) sum(spk{x}(:,idces{x},ts-2:ts+2),3),(1:length(idces))','UniformOutput',false));
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

