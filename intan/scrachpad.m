pc=plotCurve;
pc.plotRegion='test';


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
pc.decodeCategories=false;


pc.plotDecoding(samples([1,4,6,2,3,5]),'Multi_2','multi');
pc.plotDecoding(samples([2,3,5,1,4,6]),'Multi_3','multi');
pc.plotDecoding(samples([3,2,5,1,4,6]),'Multi_4','multi');
pc.plotDecoding(samples([5,2,3,1,4,6]),'Multi_6','multi');
pc.plotDecoding(samples([6,1,4,2,3,5]),'Multi_12','multi');
pc.plotDecoding(samples([4,1,6,2,3,5]),'Multi_5','multi');





test7=processAll('test',7,[-2,0.5,13],[30,1],1000);
test1=processAll('test',1,[-2,0.5,13],[30,1],1000);
tests={test1,test7};
pc.decodeCategories=false;
pc.plotDecoding(tests,'Multi_Test_1','multi');
pc.plotDecoding(tests([2 1]),'Multi_Test_7','multi');

[sample2,ids2]=processAll('sample',2,[-2,0.5,13],[30,1],1000);
[sample2Cat,ids2Cat]=processAll('sample',[3 5],[-2,0.5,13],[30,1],1000);
[sample2NonCat,ids2NonCat]=processAll('sample',[1 4 6],[-2,0.5,13],[30,1],1000);
sample2Cat=sample2Cat(ismember(ids2Cat,ids2,'rows'),:,:);
sample2NonCat=sample2NonCat(ismember(ids2NonCat,ids2,'rows'),:,:);
merge=@(x,y) cat(3,x(:,:,1:30),y(:,:,31:60));
s2catS2=merge(sample2Cat,sample2);
pc.decodeCategories=false;
celCats={s2catS2,sample2NonCat};
pc.plotDecoding(celCats,'categories','multi')


% [sampleClassA,idA]=processAll('sample',[3 5],[-2,0.5,13],[30,1],1000);
% [sampleClassB,idB]=processAll('sample',[2 4],[-2,0.5,13],[30,1],1000);
% sampleClassA=sampleClassA(ismember(idA,idB,'rows'),:,:);
% cats={sampleClassA,sampleClassB};
% pc.decodeCategories=false;
% pc.plotDecoding(cats,'Cat_A','multi')
% pc.plotDecoding(cats([2 1]),'Cat_B','multi')

scat=s2catS2(:,:,6);
s=s2catS2(:,:,36);

sfcat=sample2NonCat(:,:,6);
sfsf=sample2NonCat(:,:,36);

getR=@(x) x(1,2);
rr=nan(1000,4);
for i=1:1000
    rr(i,:)=[getR(corrcoef(scat(:,i),s(:,i))),...
        getR(corrcoef(sfcat(:,i),s(:,i))),...
        getR(corrcoef(scat(:,i),sfsf(:,i))),...
        getR(corrcoef(sfcat(:,i),sfsf(:,i)))];
end

mean(rr)
sum(rr(:,1)>rr(:,2))
sum(rr(:,1)==rr(:,2))
sum(rr(:,3)>rr(:,4))
sum(rr(:,3)==rr(:,4))

withinG=nan(35,6,2);
betweenG=nan(35,6,3);

inBetweenMap=[1 4 6 2 3 5;...
    4 1 6 2 3 5;...
    6 1 4 2 3 5;...
    2 3 5 4 1 6;...
    3 2 5 4 1 6;...
    5 2 3 4 1 6];



for j=1:6
    figure();
    hold on;
    for i=1:size(coord,1)
        withinG(i,j,1:2)=arrayfun(@(k) sum((coord(i,inBetweenMap(j,1),:)-coord(i,inBetweenMap(j,k),:)).^2),2:3);
        betweenG(i,j,1:3)=arrayfun(@(k) sum((coord(i,inBetweenMap(j,1),:)-coord(i,inBetweenMap(j,k),:)).^2),4:6);
    end
    plot(squeeze(withinG(:,j,:)),'-r');
    plot(squeeze(betweenG(:,j,:)),'-k');
end

figure()
hold on;
hi=plot(mean(mean(withinG,3),2),'-r.');
hb=plot(mean(mean(betweenG,3),2),'-k.');
xlim([1,24]);
set(gca,'XTick',1:10:21,'XTickLabel',0:5:10);
arrayfun(@(x) line([x,x],ylim(),'LineStyle',':','Color','k'),[1 2 7 8]*2);







%%%%%%%%%%%%%%%%%%%%%%%%%
grps={'group1','group2','group3'};
sample2=cell(1,3);ids2=cell(1,3);
sample3=cell(1,3);ids3=cell(1,3);
sample4=cell(1,3);ids4=cell(1,3);
sample5=cell(1,3);ids5=cell(1,3);
sample6=cell(1,3);ids6=cell(1,3);
sample12=cell(1,3);ids12=cell(1,3);


for i=1:3
[sample3{i},ids3{i}]=processAll('sample',3,[-2,0.5,13],[30,1],1000,grps{i});
[sample2{i},ids2{i}]=processAll('sample',2,[-2,0.5,13],[30,1],1000,grps{i});
[sample12{i},ids12{i}]=processAll('sample',12,[-2,0.5,13],[30,1],1000,grps{i});
[sample6{i},ids6{i}]=processAll('sample',6,[-2,0.5,13],[30,1],1000,grps{i});
[sample4{i},ids4{i}]=processAll('sample',4,[-2,0.5,13],[30,1],1000,grps{i});
[sample5{i},ids5{i}]=processAll('sample',5,[-2,0.5,13],[30,1],1000,grps{i});
end

close all;
pc=plotCurve;
pc.plotRegion='test';
pc.decodeCategories=false;
% samples={sample2{j},sample3{j},sample4{j},sample5{j},sample6{j},sample12{j}};
samples50={sample2{2},sample3{2},sample4{1},sample5{1},sample6{3},sample12{3}};
samples100={sample2{1},sample3{1},sample4{3},sample5{3},sample6{2},sample12{2}};
samples200={sample2{3},sample3{3},sample4{2},sample5{2},sample6{1},sample12{1}};
samples={samples50,samples100,samples200};

for j=1:3
    
    
    out2=pc.plotDecoding(samples{j}([1,4,6,2,3,5]),'Multi_2','multi','',true);
    out3=pc.plotDecoding(samples{j}([2,3,5,1,4,6]),'Multi_3','multi','',true);
    out4=pc.plotDecoding(samples{j}([3,2,5,1,4,6]),'Multi_4','multi','',true);
    out6=pc.plotDecoding(samples{j}([5,2,3,1,4,6]),'Multi_6','multi','',true);
    out12=pc.plotDecoding(samples{j}([6,1,4,2,3,5]),'Multi_12','multi','',true);
    out5=pc.plotDecoding(samples{j}([4,1,6,2,3,5]),'Multi_5','multi','',true);
    
    
    figure('Color','w');
    hold on;
    outmix=cat(2,out2,out3,out4,out5,out6,out12);
    colors={'r','k'};
    ciMean=arrayfun(@(y) bootci(100,@(x) mean(x),outmix(:,:,y)'),1:2,'UniformOutput',0);
    arrayfun(@(x) fill([1:size(ciMean{x},2),size(ciMean{x},2):-1:1],[ciMean{x}(1,:),fliplr(ciMean{x}(2,:))],'k','FaceColor',colors{x},'EdgeColor','none','FaceAlpha',0.25),1:2);
    ph=arrayfun(@(x) plot(mean(outmix(:,:,x),2),['-',colors{x},'.']),1:2);
    legend(ph,{'Recorded Template','Shuffled Template'},'AutoUpdate','off');
    arrayfun(@(x) line([x,x],ylim(),'LineStyle',':','Color','k'),[1 2 7 8]*2+0.5);
    repeats=6000;
    binSize=0.5;
    for i=1:12
        A=[zeros(repeats/binSize,1);ones(repeats/binSize,1)];
        B=[reshape(outmix((i-1)/binSize+1:i/binSize,:,1),repeats/binSize,1);
            reshape(outmix((i-1)/binSize+1:i/binSize,:,2),repeats/binSize,1)];
        [~,~,p]=crosstab(A,B);
        text((i-0.5)./binSize+0.5,0.425,p2Str(p),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
    end
    set(gca,'XTick',[0:5:10]*2+1,'XTickLabel',0:5:10);
    xlim([0.5,24.5]);
    xlabel('Time (s)');
    ylabel('Classification accuracy');
    
end
