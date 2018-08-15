delayLen=4;
[spkCA,tagA]=allByTypeDNMS('sampleall','Average2Hz',-2,0.1,delayLen+7,true,delayLen,true);
[spkCB,tagB]=allByTypeDNMS('sampleall','Average2Hz',-2,0.1,delayLen+7,false,delayLen,true);


if (~all(strcmp(tagA(:,1),tagB(:,1)))) || ~isequal(tagA(:,2),tagB(:,2))
    return;
end

alpha=0.05;

binCount=size(spkCA{1},3);
parfor winIdx=1:binCount-1
    mWindow=winIdx:winIdx+1;
    selectivity{winIdx}=arrayfun(@(x) selCalAll(spkCA{x},spkCB{x},mWindow),1:length(spkCA),'UniformOutput',false);
    sig{winIdx}=arrayfun(@(x) permTAll(spkCA{x},spkCB{x},mWindow),1:length(spkCA),'UniformOutput',false);
end


flattedSig=cell2mat(cellfun(@(x) cell2mat(x),sig,'UniformOutput',false)')';
flatted=cell2mat(cellfun(@(x) cell2mat(x),selectivity,'UniformOutput',false)')';
flatted(flattedSig>0.05)=0;

[~,sIdx]=sort(mean(flatted(:,31:30+delayLen.*10),2));

figure('Color','w','Position',[200,200,300,220]);
hold on;
imagesc(flatted(sIdx,11:50+delayLen.*10));



ax=gca;
ax.XTick=[0,5,10]*10+10+0.5;
ax.XTickLabel=[0 5 10];
ax.FontSize=10;

arrayfun(@(x) plot([x,x],[0.5,size(flatted,1)+0.5],':w','LineWidth',1),[0 1 delayLen+1,delayLen+2]*10+10.5);
colormap('jet');
colorbar();
xlabel('Time (s)');
ylabel('Neuron #');
xlim([0.5,40.5+delayLen*10]);
ylim([0.5,size(flatted,1)+0.5])
print('-depsc','-painters','-r0',sprintf('sel_colormap_%d.eps',delayLen));




% delayLen=8;
% [spkCA,tagA]=allByTypeDNMS('sampleall','Average2Hz',-2,1,delayLen+7,true,delayLen,true);
% [spkCB,tagB]=allByTypeDNMS('sampleall','Average2Hz',-2,1,delayLen+7,false,delayLen,true);
% for sec=[3 3+delayLen]
%     selectivity=cell2mat(arrayfun(@(x) selCalAll(spkCA{x},spkCB{x},sec),1:length(spkCA),'UniformOutput',false));
%     permTSample=cell2mat(arrayfun(@(x) permTAll(spkCA{x},spkCB{x},sec),1:length(spkCA),'UniformOutput',false));
% 
%     figure('Color','w','Position',[200,200,300,220]);
%     % bh=histogram(selSample,-1:0.1:1,'Normalization','probability');
% 
%     bars=[histcounts(selectivity(permTSample<0.05),-1:0.1:1);histcounts(selectivity(permTSample>=0.05),-1:0.1:1)]';
% 
%     bh=bar(bars./sum(sum(bars)),'stacked');
%     ax=gca;
%     ax.XTick=1:5:21;
%     ax.XTickLabel=-1:0.5:1;
%     bh(1).FaceColor='k';
%     bh(2).FaceColor='w';
%     xlabel('Selectivity');
%     ylabel('Fraction of neurons');
%     print('-depsc','-painters',sprintf('selHist_%ds_bin%d.eps',delayLen,sec));
% end

function out=permTAll(A,B,window)
out=nan(1,size(A,1));
flat=@(x) x(:);
for i=1:size(A,1)
    if all(flat(A(i,:,window))==0) && all(flat(B(i,:,window))==0)
        out(i)=1;
    else
        out(i)=permTest(flat(A(i,:,window)),flat(B(i,:,window)));
    end
end
end

function out=selCalAll(A,B,window)
out=nan(1,size(A,1));
flat=@(x) x(:);
for i=1:size(A,1)
    if all(flat(A(i,:,window))==0) && all(flat(B(i,:,window))==0)
        out(i)=0;
    else
        out(i)=(mean(flat(A(i,:,window)))-mean(flat(B(i,:,window))))/(mean(flat(A(i,:,window)))+mean(flat(B(i,:,window))));
    end
end
end



function out=permTest(A,B)
    currDelta=abs(mean(A(:))-mean(B(:)));
    permed=nan(1,1000);
    for i=1:1000
        [AA,BB]=permSample(A,B);
        permed(i)=abs(mean(AA)-mean(BB));
    end
    out=mean(permed>=currDelta);
end

function [newA,newB]=permSample(A,B)
pool=[A(:);B(:)];
pool=pool(randperm(length(pool)));
newA=pool(1:numel(A));
newB=pool((numel(A)+1):end);
end

function out=p2str(p)
if p<0.001
    out='***';
elseif p<0.01
    out='**';
elseif p<0.05
    out='*';
else
    out='N.S.';
end
end

