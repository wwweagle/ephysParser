function svmMulti(delayLen,dataFile)
%%%%%%%%%onCluster%%%%%%%%%%
% addpath('/home/zhangxiaoxing/libsvm-3.22/matlab');
% decRpt=500;
% permRpt=1000;

%%%%%%%%%%local%%%%%%%%%
decRpt=100;
permRpt=100;

% saveFile(delayLen,dataFile);

instCount=30;
fstr=load(dataFile);
tsLen=(delayLen+8)*2;


spkCA=fstr.spkCA;
spkCB=fstr.spkCB;
% errSpkCA=fstr.errSpkCA;
% errSpkCB=fstr.errSpkCB;

crange=2.^(-5:0.5:5);
grange=2.^(-13:0.5:-3);

avgAccu=nan(length(crange),length(grange),length(3:tsLen),2);

for cIdx=1%:length(crange)
    for gIdx=1%:length(grange)
         c=crange(14);
         g=grange(15);

        accuracy=nan(decRpt,3,(tsLen+2));
        
        futures=parallel.FevalFuture.empty(0,tsLen);
        for ts=3:tsLen
%             futures(ts)=parfeval(@svmOneTSBin,1,ts,instCount,spkCA,spkCB,errSpkCA,errSpkCB,decRpt,c,g);
             futures(ts)=parfeval(@svmOneTSBin,1,ts,instCount,spkCA,spkCB,spkCA,spkCB,decRpt,c,g);
%             accuracy(:,:,ts)=svmOneTSBin(ts,instCount,spkCA,spkCB,spkCA,spkCB,decRpt,c,g);
        end
        
        for ts=3:tsLen
            accuracy(:,:,ts)=fetchOutputs(futures(ts));
        end
        % plot(mean(accuracy));
        
        pvShuf=nan(3,(tsLen+2));
        pvShuf(1,:)=permTest(tsLen,accuracy,1,3,permRpt).*(tsLen-2);
%         pvShuf(2,:)=permTest(tsLen,accuracy,2,3,permRpt).*(tsLen-2);
%         pvShuf(3,:)=permTest(tsLen,accuracy,1,2,permRpt).*(tsLen-2);
        %         for ts=3:tsLen
        %             currDiff=abs(mean(accuracy(:,1,ts))-mean(accuracy(:,2,ts)));
        %             flat=@(x) x(:);
        %             pool=flat(accuracy(:,:,ts));
        %             shufDiff=nan(permRpt);
        %             for i=1:permRpt
        %                 sPool=pool(randperm(length(pool)));
        %                 shufDiff(i)=abs(mean(sPool(1:size(accuracy,1)))-mean(sPool(size(accuracy,1)+1:end)));
        %             end
        %             pvShuf(1,ts)=nnz(shufDiff>=currDiff)/permRpt;
        %         end
        
        %         disp(pvShuf);
        
        fh=figure('Color','w');
        hold on;
        ci=bootci(100,@mean,accuracy(:,1,3:tsLen));
%         ciErr=bootci(100,@mean, accuracy(:,2,3:tsLen));
        ciShuf=bootci(100,@mean, accuracy(:,3,3:tsLen));
        fill([3:tsLen,tsLen:-1:3]-2,[ci(1,:),fliplr(ci(2,:))]./100,[1,0.8,0.8],'EdgeColor','none');
%         fill([3:tsLen,tsLen:-1:3]-2,[ciErr(1,:),fliplr(ciErr(2,:))]./100,[0.8,0.8,1],'EdgeColor','none');
        fill([3:tsLen,tsLen:-1:3]-2,[ciShuf(1,:),fliplr(ciShuf(2,:))]./100,[0.8,0.8,0.8],'EdgeColor','none');
        plot(mean(squeeze(accuracy(:,1,3:tsLen)))./100,'-r','LineWidth',1);
%         plot(mean(squeeze(accuracy(:,2,3:tsLen)))./100,'-b','LineWidth',1);
        plot(mean(squeeze(accuracy(:,3,3:tsLen)))./100,'-k','LineWidth',1);
        
        for i=3:tsLen
            if pvShuf(1,i)<0.001
                text(i-2,0.475,'.','HorizontalAlignment','center','Color','r');
            end
%             if pvShuf(2,i)<0.001
%                 text(i-2,0.45,'.','HorizontalAlignment','center','Color','b');
%             end
%             if pvShuf(3,i)<0.001
%                 text(i-2,0.425,'.','HorizontalAlignment','center','Color','k');
%             end
        end
        
        arrayfun(@(x) plot([x,x],ylim(),':k'),[1 2 delayLen+2 delayLen+3]*2+0.5);
        set(gca,'XTick',[0:5:10]*2+0.5,'XTickLabel',0:5:10);
        xlim([0,tsLen-6]);
        ylim([0.4,1]);
        xlabel('Time (s)');
        ylabel('Sample Decoding Accuracy');
        title(sprintf('%s, c@%.4f, g@%0.4f, n = %d',strrep(dataFile,'.mat',''),c,g,sum(cellfun(@(x) size(x,1),spkCA))));
        print(sprintf('SVM%s_c%.4f_g%0.4f.png',dataFile,c,g),'-dpng');
%         close(fh);
        avgAccu(cIdx,gIdx,:,1)=mean(squeeze(accuracy(:,1,3:tsLen)));
        avgAccu(cIdx,gIdx,:,2)=mean(squeeze(accuracy(:,2,3:tsLen)));
    end
end

save(sprintf('avgAccu%s',dataFile),'avgAccu');
save(sprintf('Accu%s',dataFile),'accuracy');
end



function accuracy=svmOneTSBin(ts,instCount,spkCA,spkCB,errSpkCA,errSpkCB,decRpt,c,g)
accuracy=nan(decRpt,3);
for rpt=1:decRpt
    instPerSess=[cellfun(@(x) size(x,2),spkCA); cellfun(@(x) size(x,2), spkCB)];
    instIdces=cell2mat(arrayfun(@(x) flexPerm(x,instCount+1),instPerSess,'UniformOutput',false));
    testInstIdces=instIdces(:,1);
    instIdces=instIdces(:,2:end);
    
    instPerErrSess=[cellfun(@(x) size(x,2),errSpkCA); cellfun(@(x) size(x,2), errSpkCB)];
    errTestIdces=arrayfun(@(x) randperm(x,1),instPerErrSess);
    
    instMatRaw=[cell2mat(arrayfun(@(x) spkCA{x}(:,instIdces(x,:),ts),(1:length(instIdces)/2)','UniformOutput',false)),...
        cell2mat(arrayfun(@(x) spkCB{x}(:,instIdces(x+length(instIdces)/2,:),ts),(1:length(instIdces)/2)','UniformOutput',false))]';
    
    testMatRaw=[cell2mat(arrayfun(@(x) spkCA{x}(:,testInstIdces(x,:),ts),(1:length(testInstIdces)/2)','UniformOutput',false)),...
        cell2mat(arrayfun(@(x) spkCB{x}(:,testInstIdces(x+length(testInstIdces)/2,:),ts),(1:length(testInstIdces)/2)','UniformOutput',false))]';
    
    errTestMatRaw=[cell2mat(arrayfun(@(x) errSpkCA{x}(:,errTestIdces(x),ts),(1:length(errTestIdces)/2)','UniformOutput',false)),...
        cell2mat(arrayfun(@(x) errSpkCB{x}(:,errTestIdces(x+length(errTestIdces)/2),ts),(1:length(errTestIdces)/2)','UniformOutput',false))]';
    
    
    %
    %         instMatRaw=[cell2mat(cellfun(@(x) x(:,instIdces,ts), spkCA,'UniformOutput',false)),...
    %             cell2mat(cellfun(@(x) x(:,instIdces,ts), spkCB,'UniformOutput',false))]';
    
    scale=(max(instMatRaw)-min(instMatRaw));%1x205
    instMat=(instMatRaw-repmat(min(instMatRaw),2*instCount,1))./repmat(scale,2*instCount,1);
    instMat(:,scale==0)=[];
    %         testMatRaw=[cell2mat(cellfun(@(x) x(:,testInstIdx,ts), spkCA,'UniformOutput',false)),...
    %             cell2mat(cellfun(@(x) x(:,testInstIdx,ts), spkCB,'UniformOutput',false))]';
    testMat=(testMatRaw-repmat(min(instMatRaw),2,1))./repmat(scale,2,1);
    errTestMat=(errTestMatRaw-repmat(min(instMatRaw),2,1))./repmat(scale,2,1);
    
    testMat(:,scale==0)=[];
    errTestMat(:,scale==0)=[];
    labelVec=[ones(instCount,1);ones(instCount,1)*2];
    testLabelVec=[1;2];
    
    
    
    svmModel=svmtrain(labelVec,instMat,sprintf('-q -t 2 -c %.4f -g %0.4f',c,g));

    [prLbl,accuracyVec,~]=svmpredict(testLabelVec,testMat,svmModel);
%     fprintf('%d_1_%d, %d_2_%d, ',ts,prLbl(1),ts,prLbl(2));
    accuracy(rpt,1)=accuracyVec(1);
%     accuracy(rpt,1)=svmModel;
    
%     [~,accuracyVec,~]=svmpredict(testLabelVec,errTestMat,svmModel);
%     accuracy(rpt,2)=accuracyVec(1);
    
    svmModel=svmtrain(labelVec(randperm(length(labelVec))),instMat,sprintf('-q -t 2 -c %.4f -g %0.4f',c,g));
    [~,accuracyVec,~]=svmpredict(testLabelVec,testMat,svmModel);
    accuracy(rpt,3)=accuracyVec(1);
%     accuracy(rpt,3)=svmModel;
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

function out=expand(in)
if size(in,2)==2
    in=in(:,[2 1]);
end
subTotal=sum(cellfun(@(x) size(x,1),in(:,1)));
cIdx=1;
out=cell(subTotal,1);
for i=1:length(in)
    for j=1:size(in{i,1},1)
        if size(in,2)==1
            out{cIdx}=in{i}(j,:,:);
        else
            out{cIdx}=[num2str(in{i,1}(j,:)),char(in{i,2})];
        end
        cIdx=cIdx+1;
    end
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

function saveDNMSFile(delayLen,dataFile)
delayLen=8;
[spkCA,tagA]=allByTypeDNMS('sample','Average2Hz',-2,0.5,delayLen+7,true,delayLen,true);
[spkCB,tagB]=allByTypeDNMS('sample','Average2Hz',-2,0.5,delayLen+7,false,delayLen,true);
% [errSpkCA,tagAE]=allByTypeDNMS('sampleerror','Average2Hz',-2,0.5,delayLen+7,true,delayLen,false);
% [errSpkCB,tagBE]=allByTypeDNMS('sampleerror','Average2Hz',-2,0.5,delayLen+7,false,delayLen,false);

dataFile='8sDNMS.mat';

spkCA=spkCA(ismember(tagA(:,1),tagB(:,1)));
tagA=tagA(ismember(tagA(:,1),tagB(:,1)),:);

spkCB=spkCB(ismember(tagB(:,1),tagA(:,1)));
tagB=tagB(ismember(tagB(:,1),tagA(:,1)),:);
if ~all(strcmp(tagA(:,1),tagB(:,1)))
    spkCA=[];
    spkCB=[];
    return
end

for i=1:size(tagA,1)
    spkCA{i}=spkCA{i}(ismember(tagA{i,2},tagB{i,2},'rows'),:,:);
    tagA{i,2}=tagA{i,2}(ismember(tagA{i,2},tagB{i,2},'rows'),:);
end

for i=1:size(tagB,1)
    spkCB{i}=spkCB{i}(ismember(tagB{i,2},tagA{i,2},'rows'),:,:);
    tagB{i,2}=tagB{i,2}(ismember(tagB{i,2},tagA{i,2},'rows'),:);
end



% spkCA=expand(spkCA);
% spkCB=expand(spkCB);
% tagA=expand(tagA);
% tagB=expand(tagB);

% errSpkCA=expand(errSpkCA);
% errSpkCB=expand(errSpkCB);
% tagAE=expand(tagAE);
% tagBE=expand(tagBE);

% spkCA=spkCA(ismember(tagA,tagB));
% spkCB=spkCB(ismember(tagB,tagA));

% spkCA=spkCA(ismember(tagA,tagB) & ismember(tagA,tagAE) & ismember(tagA,tagBE));
% spkCB=spkCB(ismember(tagB,tagA) & ismember(tagB,tagAE) & ismember(tagB,tagBE));
% errSpkCA=errSpkCA(ismember(tagAE,tagA) & ismember(tagAE,tagBE) & ismember(tagAE,tagB));
% errSpkCB=errSpkCB(ismember(tagBE,tagA) & ismember(tagBE,tagAE) & ismember(tagBE,tagB));
% 
sel=(cellfun(@(x) size(x,2),spkCA)>30 & cellfun(@(x) size(x,2),spkCB)>30);
% 
spkCA=spkCA(sel);
spkCB=spkCB(sel);
% errSpkCA=errSpkCA(sel);
% errSpkCB=errSpkCB(sel);


save(dataFile,'spkCA','spkCB');
end

function saveDualFile(delayLen,dataFile)
% 
[spkCA,tagA]=allByTypeDual('distrNone','Average2Hz',-2,0.5,15,true,true);
[spkCB,tagB]=allByTypeDual('distrNone','Average2Hz',-2,0.5,15,false,true);
% 
% [spkCA,tagA]=allByTypeDual('distrNone','Average2Hz',-2,0.5,20,true,true,'WJ');
% [spkCB,tagB]=allByTypeDual('distrNone','Average2Hz',-2,0.5,20,false,true,'WJ');

dataFile='8sDualNone.mat';

spkCA=spkCA(ismember(tagA(:,1),tagB(:,1)));
tagA=tagA(ismember(tagA(:,1),tagB(:,1)),:);

spkCB=spkCB(ismember(tagB(:,1),tagA(:,1)));
tagB=tagB(ismember(tagB(:,1),tagA(:,1)),:);
if ~all(strcmp(tagA(:,1),tagB(:,1)))
    spkCA=[];
    spkCB=[];
    return
end

for i=1:size(tagA,1)
    spkCA{i}=spkCA{i}(ismember(tagA{i,2},tagB{i,2},'rows'),:,:);
    tagA{i,2}=tagA{i,2}(ismember(tagA{i,2},tagB{i,2},'rows'),:);
end

for i=1:size(tagB,1)
    spkCB{i}=spkCB{i}(ismember(tagB{i,2},tagA{i,2},'rows'),:,:);
    tagB{i,2}=tagB{i,2}(ismember(tagB{i,2},tagA{i,2},'rows'),:);
end

sel=(cellfun(@(x) size(x,2),spkCA)>15 & cellfun(@(x) size(x,2),spkCB)>15);

spkCA=spkCA(sel);
spkCB=spkCB(sel);

save(dataFile,'spkCA','spkCB');

fprintf('%d\n',sum(cellfun(@(x) size(x,1),spkCA)));
end

function combineDual(datafile13,datafile8)
datafile13='13sDualNoGo.mat';datafile8='8sDualNoGo.mat';dataFile='CombinedDualNoGo.mat';
fstr13=load(datafile13);
fstr8=load(datafile8);

a13=cellfun(@(x) x(:,:,[1:6,11:26,33:44]),fstr13.spkCA,'UniformOutput',false);
a8=cellfun(@(x) x(:,:,[1:6,7:22,23:34]),fstr8.spkCA,'UniformOutput',false);
spkCA=[a13;a8];

b13=cellfun(@(x) x(:,:,[1:6,11:26,33:44]),fstr13.spkCB,'UniformOutput',false);
b8=cellfun(@(x) x(:,:,[1:6,7:22,23:34]),fstr8.spkCB,'UniformOutput',false);
spkCB=[b13;b8];


save(dataFile,'spkCA','spkCB');

end


function saveErrorFile(delayLen,dataFile)
delayLen=8;dataFile='8sDNMS_Err.mat';
[spkCA,tagA]=allByTypeDNMS('sample','Average2Hz',-2,0.5,delayLen+7,true,delayLen,true);
[spkCB,tagB]=allByTypeDNMS('sample','Average2Hz',-2,0.5,delayLen+7,false,delayLen,true);
[errSpkCA,tagAE]=allByTypeDNMS('sampleerror','Average2Hz',-2,0.5,delayLen+7,true,delayLen,false);
[errSpkCB,tagBE]=allByTypeDNMS('sampleerror','Average2Hz',-2,0.5,delayLen+7,false,delayLen,false);


spkCA=spkCA(ismember(tagA(:,1),tagB(:,1)) & ismember(tagA(:,1),tagAE(:,1)) & ismember(tagA(:,1),tagBE(:,1)));
tagA=tagA(ismember(tagA(:,1),tagB(:,1)) & ismember(tagA(:,1),tagAE(:,1)) & ismember(tagA(:,1),tagBE(:,1)),:);

spkCB=spkCB(ismember(tagB(:,1),tagA(:,1)) & ismember(tagB(:,1),tagAE(:,1)) & ismember(tagB(:,1),tagBE(:,1)));
tagB=tagB(ismember(tagB(:,1),tagA(:,1)) & ismember(tagB(:,1),tagAE(:,1)) & ismember(tagB(:,1),tagBE(:,1)),:);

errSpkCA=errSpkCA(ismember(tagAE(:,1),tagA(:,1)) & ismember(tagAE(:,1),tagB(:,1)) & ismember(tagAE(:,1),tagBE(:,1)));
tagAE=tagAE(ismember(tagAE(:,1),tagA(:,1)) & ismember(tagAE(:,1),tagB(:,1)) & ismember(tagAE(:,1),tagBE(:,1)),:);

errSpkCB=errSpkCB(ismember(tagBE(:,1),tagA(:,1)) & ismember(tagBE(:,1),tagB(:,1)) & ismember(tagBE(:,1),tagAE(:,1)));
tagBE=tagBE(ismember(tagBE(:,1),tagA(:,1)) & ismember(tagBE(:,1),tagB(:,1)) & ismember(tagBE(:,1),tagAE(:,1)),:);


if (~all(strcmp(tagA(:,1),tagB(:,1)))) || (~all(strcmp(tagA(:,1),tagAE(:,1)))) || (~all(strcmp(tagA(:,1),tagBE(:,1))))
    spkCA=[];
    spkCB=[];
    errSpkCA=[];
    errSpkCB=[];
    return
end

for i=1:size(tagA,1)
    spkCA{i}=spkCA{i}(ismember(tagA{i,2},tagB{i,2},'rows') & ismember(tagA{i,2},tagAE{i,2},'rows') & ismember(tagA{i,2},tagBE{i,2},'rows'),:,:);
    tagA{i,2}=tagA{i,2}(ismember(tagA{i,2},tagB{i,2},'rows') & ismember(tagA{i,2},tagAE{i,2},'rows') & ismember(tagA{i,2},tagBE{i,2},'rows'),:);
end

for i=1:size(tagB,1)
    spkCB{i}=spkCB{i}(ismember(tagB{i,2},tagA{i,2},'rows') & ismember(tagB{i,2},tagAE{i,2},'rows') & ismember(tagB{i,2},tagBE{i,2},'rows'),:,:);
    tagB{i,2}=tagB{i,2}(ismember(tagB{i,2},tagA{i,2},'rows') & ismember(tagB{i,2},tagAE{i,2},'rows') & ismember(tagB{i,2},tagBE{i,2},'rows'),:);
end

for i=1:size(tagAE,1)
    errSpkCA{i}=errSpkCA{i}(ismember(tagAE{i,2},tagA{i,2},'rows') & ismember(tagAE{i,2},tagB{i,2},'rows') & ismember(tagAE{i,2},tagBE{i,2},'rows'),:,:);
    tagAE{i,2}=tagAE{i,2}(ismember(tagAE{i,2},tagA{i,2},'rows') & ismember(tagAE{i,2},tagB{i,2},'rows') & ismember(tagAE{i,2},tagBE{i,2},'rows'),:);
end

for i=1:size(tagBE,1)
    errSpkCB{i}=errSpkCB{i}(ismember(tagBE{i,2},tagA{i,2},'rows') & ismember(tagBE{i,2},tagB{i,2},'rows') & ismember(tagBE{i,2},tagAE{i,2},'rows'),:,:);
    tagBE{i,2}=tagBE{i,2}(ismember(tagBE{i,2},tagA{i,2},'rows') & ismember(tagBE{i,2},tagB{i,2},'rows') & ismember(tagBE{i,2},tagAE{i,2},'rows'),:);
end

sel=(cellfun(@(x) size(x,2),spkCA)>10 & cellfun(@(x) size(x,2),spkCB)>10 & cellfun(@(x) size(x,2),errSpkCA)>10 & cellfun(@(x) size(x,2),errSpkCB)>10);

spkCA=spkCA(sel);
spkCB=spkCB(sel);
errSpkCA=errSpkCA(sel);
errSpkCB=errSpkCB(sel);


save(dataFile,'spkCA','spkCB','errSpkCA','errSpkCB');
fprintf('%d\n',sum(cellfun(@(x) size(x,1),spkCA)));
end
