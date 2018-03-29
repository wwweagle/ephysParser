
[sample3,ids3]=processAll('sample',3,[-2,0.5,13],[30,1],1000);
[sample2,ids2]=processAll('sample',2,[-2,0.5,13],[30,1],1000);
[sample12,ids12]=processAll('sample',12,[-2,0.5,13],[30,1],1000);
[sample6,ids6]=processAll('sample',6,[-2,0.5,13],[30,1],1000);
[sample4,ids4]=processAll('sample',4,[-2,0.5,13],[30,1],1000);
[sample5,ids5]=processAll('sample',5,[-2,0.5,13],[30,1],1000);
%%%%%%%%%  1        2       3       4      5         6
samples={sample2,sample3,sample4,sample5,sample6,sample12};


pc=plotCurve;
pc.plotRegion='test';

pc.decodeCategories=true;
cat2=pc.plotDecoding(samples([1,4,6,2,3,5]),'Multi_2_cat','multi');
cat3=pc.plotDecoding(samples([2,3,5,1,4,6]),'Multi_3_cat','multi');
cat4=pc.plotDecoding(samples([3,2,5,1,4,6]),'Multi_4_cat','multi');
cat6=pc.plotDecoding(samples([5,2,3,1,4,6]),'Multi_6_cat','multi');
cat12=pc.plotDecoding(samples([6,1,4,2,3,5]),'Multi_12_cat','multi');
cat5=pc.plotDecoding(samples([4,1,6,2,3,5]),'Multi_5_cat','multi');

figure('Color','w');
hold on;
catmix=cat(2,cat2,cat3,cat4,cat5,cat6,cat12);
colors={'r','k'};
ciMean=arrayfun(@(y) bootci(100,@(x) mean(x),catmix(:,:,y)'),1:2,'UniformOutput',0);
arrayfun(@(x) fill([1:size(ciMean{x},2),size(ciMean{x},2):-1:1],[ciMean{x}(1,:),fliplr(ciMean{x}(2,:))],'k','FaceColor',colors{x},'EdgeColor','none','FaceAlpha',0.25),1:2);
ph=arrayfun(@(x) plot(mean(catmix(:,:,x),2),['-',colors{x},'.']),1:2);
legend(ph,{'Within Group Template','Shuffled Template'},'AutoUpdate','off');
arrayfun(@(x) line([x,x],ylim(),'LineStyle',':','Color','k'),[1 2 7 8]*2+0.5);
repeats=6000;
binSize=0.5;
for i=1:12
    A=[zeros(repeats/binSize,1);ones(repeats/binSize,1)];
    B=[reshape(catmix((i-1)/binSize+1:i/binSize,:,1),repeats/binSize,1);
        reshape(catmix((i-1)/binSize+1:i/binSize,:,2),repeats/binSize,1)];
    [~,~,p]=crosstab(A,B);
    text((i-0.5)./binSize+0.5,0.425,p2Str(p),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
end
set(gca,'XTick',[0:5:10]*2+1,'XTickLabel',0:5:10);
xlim([0.5,24.5]);
xlabel('Time (s)');
ylabel('Classification accuracy');