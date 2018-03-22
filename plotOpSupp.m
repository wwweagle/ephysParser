function s=plotOpSupp(ramp)
s=SampleOpSupp('OpSuppress','Average2HzWhole',-2,0.2,11,[100,0;100,0],1,false,ramp);
p=nan(size(s,1),2);

if ramp
    lEnd=23;
else 
    lEnd=25;
end

for i=1:size(s,1)
p(i,1)=permTest(s(i,6:15),s(i,16:lEnd),1000);
p(i,2)=mean(s(i,16:lEnd))>mean(s(i,6:15));
end


figure('Color','w','Position',[100,100,140,75]);
yyaxis right;
hold on;
sample=s(p(:,1)<0.05 & p(:,2)==1,6:35);
fprintf('Activated, %d/%d, %03f\n',size(sample,1),size(p,1),size(sample,1)/size(p,1));

ci=bootci(100,@(x) mean(x),sample);
fill([1:size(sample,2),size(sample,2):-1:1],[ci(1,:),flip(ci(2,:))],[1,0.8,0.8],'EdgeColor','none');
plot(mean(sample),'-r','LineWidth',1);
if ramp
    set(gca,'XTick',[5:5:30],'XTickLabel',{'','0','','2','','4'},'YTick',[0,20]);
else
    set(gca,'XTick',[5:5:30],'XTickLabel',{'','0','','2','','4'},'YTick',0:20:40);
end
xlim([0,30]);
ylim([0,45]);
yyaxis left;
hold on;
sample=s(p(:,1)<0.05 & p(:,2)==0,6:35);
fprintf('Suppressed, %d/%d, %03f\n',size(sample,1),size(p,1),size(sample,1)/size(p,1));
ci=bootci(100,@(x) mean(x),sample);
fill([1:size(sample,2),size(sample,2):-1:1],[ci(1,:),flip(ci(2,:))],[0.8,0.8,1],'EdgeColor','none');
plot(mean(sample),'-b','LineWidth',1);
arrayfun(@(x) plot([x,x],ylim(),'k:','LineWidth',1),[10,20,25]);
xlim([0,30]);
set(gca,'box','off','XTick',[5:5:30],'XTickLabel',[],'YTick',0:5:10);

end



function p=permTest(a,b,rpt)
currDiff=abs(mean(a)-mean(b));
permDiff=nan(rpt,1);
pool=[a,b];
for rptIdx=1:rpt
pool=pool(randperm(length(pool)));
poolA=pool(1:length(a));
poolB=pool(length(a)+1:end);
permDiff(rptIdx)=abs(mean(poolA)-mean(poolB));
end

meanDiff=mean(permDiff);
p=nnz(abs(permDiff-meanDiff)>=abs(currDiff-meanDiff))./rpt;

end