function [coordAll,data]=pcaDistance(data)
pcIdx=1;
binSize=0.5;
if ~exist('data','var')
    [sample3,ids3]=processAll('sample',3,[-2,binSize,13],[20,20],100);
    [sample2,ids2]=processAll('sample',2,[-2,binSize,13],[20,20],100);
    
    [sample4,ids4]=processAll('sample',4,[-2,binSize,13],[20,20],100);
    [sample5,ids5]=processAll('sample',5,[-2,binSize,13],[20,20],100);
    
    [sample6,ids6]=processAll('sample',6,[-2,binSize,13],[20,20],100);
    [sample12,ids12]=processAll('sample',12,[-2,binSize,13],[20,20],100);
    
    sample2=sample2(ismember(ids2,ids3,'rows'),:,:);
    sample4=sample4(ismember(ids4,ids3,'rows'),:,:);
    sample5=sample5(ismember(ids5,ids3,'rows'),:,:);
    sample6=sample6(ismember(ids6,ids3,'rows'),:,:);
    sample12=sample12(ismember(ids12,ids3,'rows'),:,:);
    
    
    data=cat(3,sample2,sample3,sample4,sample5,sample6,sample12);
end

% load line29.mat;

trialLen=size(data,3)/12*binSize-2;
idces=repmat(1/binSize+1:(trialLen+1)/binSize,1,6)+cell2mat(arrayfun(@(x) zeros(1,trialLen/binSize)+x*size(data,3)/6,0:5,'UniformOutput',0));
coord=nan(trialLen/binSize,6,size(data,2));
coordAll=nan(trialLen/binSize,20,6,size(data,2));
latent=nan(1,size(data,2));
for rpt=1:size(data,2)
    [~,score,latentAll]=pca(squeeze(data(:,rpt,idces))');
    latent(rpt)=latentAll(pcIdx)/sum(latentAll);
    for s=1:6
        coord(:,s,rpt)=score([1:trialLen/binSize]+(s-1)*(trialLen/binSize),pcIdx);
        coordAll(:,:,s,rpt)=score([1:trialLen/binSize]+(s-1)*(trialLen/binSize),1:20);
    end
end
fprintf('%0.2f +- %0.2f %%\n',mean(latent)*100,std(latent)/sqrt(length(latent))*100);

styles={'-',':',':','-',':','-'};
fh=figure('Color','w','Position',[100,100,350,240]);
hold on;
colors={[240,15,15]./255,[0,159,212]./255,[255,69,10]./255,[184,134,11]./255,[191,85,236]./255,[0.2,0.2,0.2]};
ciMean=arrayfun(@(y) bootci(100,@(x) mean(x),squeeze(coord(:,y,:))'),1:6,'UniformOutput',0);
arrayfun(@(x) fill([1:trialLen/binSize,trialLen/binSize:-1:1],[ciMean{x}(1,:),fliplr(ciMean{x}(2,:))],'k','FaceColor',colors{x},'EdgeColor','none','FaceAlpha',0.25),6:-1:1);
fhs=arrayfun(@(x) plot(squeeze(mean(coord(:,x,:),3)),[styles{x}],'Marker','.','Color',colors{x},'LineWidth',1.5),6:-1:1);
fhs=flip(fhs);
legend(fhs([1 4 6 2 3 5]),{'PFA (w/MBN)','BFA (w/MBN)','MBA (w/MBN)','BN (w/PA)','PN (w/PA)','EPA (w/PA)'},'AutoUpdate','off');
arrayfun(@(x) line([x,x],ylim(),'LineStyle',':','Color','k'),[1 2 7 8]*2+0.5);
set(gca,'XTick',[0:5:10]*2+0.5,'XTickLabel',0:5:10);
xlim([0,25]);
xlabel('Time (s)');
ylabel('PC1 score (A.U.)');
savefig(fh,'6SamplePC1.fig');



pairs=nchoosek(1:6,2);
inGrp=all(ismember(pairs,[3 4 6]),2) | ~any(ismember(pairs,[3 4 6]),2);
dists=nan(15,26,100);

for rpt=1:size(coordAll,4)
    for ts=1:26
        for p=1:length(pairs)
            pair=pairs(p,:);
            dists(p,ts,rpt)=sqrt(sum((coordAll(ts,:,pair(1),rpt)-coordAll(ts,:,pair(2),rpt)).^2));
        end
    end
end

flat=@(x) x(:,:);
inGrpDist=flat(permute(dists(inGrp,:,:),[2,1,3]));
betGrpDist=flat(permute(dists(~inGrp,:,:),[2,1,3]));

fh=figure('Color','w','Position',[100,100,350,240]);
hold on;
cii=bootci(100,@mean,inGrpDist');
cio=bootci(100,@mean,betGrpDist');
len=length(cii);
fill([1:len,len:-1:1],[cii(1,:),fliplr(cii(2,:))],'r','FaceAlpha',0.2,'EdgeColor','none');
fill([1:len,len:-1:1],[cio(1,:),fliplr(cio(2,:))],'k','FaceAlpha',0.2,'EdgeColor','none');
pi=plot(mean(inGrpDist,2),'-r','LineWidth',1);
po=plot(mean(betGrpDist,2),'-k','LineWidth',1);
arrayfun(@(x) line([x,x],ylim(),'LineStyle',':','Color','k'),[1 2 7 8]*2+0.5);
set(gca,'XTick',[0:5:10]*2+0.5,'XTickLabel',0:5:10);
xlim([0,25]);
xlabel('Time (s)');
ylabel('Distance in PCA Space (A.U.)');
legend([pi,po],{'Same pairing distance','Opposite pairing distance'},'AutoUpdate','off');
flat=@(x) x(:);

for i=1:2:len
    p=ranksum(flat(inGrpDist(i:i+1,:)),flat(betGrpDist(i:i+1,:)))*len/2;
    text(i+0.5,min(ylim)+diff(ylim)*0.05,p2str(p),'HorizontalAlignment','center');
end


savefig(fh,'6SampleGrpDist.fig');

    function out=p2str(p)
        if p>0.05
            out='';
        elseif p<0.001
            out='***';
        else
            out=sprintf('%.3f',p);
        end
    end

end