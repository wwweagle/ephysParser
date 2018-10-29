function s=plotOpSupp(ramp)
%old bin=200ms new bin=50ms
s=SampleOpSupp('OpSuppress','Average2HzWhole',-2,0.05,5,[100,0;100,0],1,false,ramp);
if size(s,1)==104
    s([78,94],:,:)=[];
end
p=nan(size(s,1),2);

if ramp
    lEnd=90;
else 
    lEnd=100;
end

for i=1:size(s,1)
p(i,1)=permTest(s(i,21:60),s(i,61:lEnd),1000);
p(i,2)=mean(s(i,61:lEnd))>mean(s(i,21:60));
end


figure('Color','w','Position',[100,100,140,180]);
% yyaxis right;
subplot(2,1,2);
hold on;
sample=s(p(:,1)<0.05 & p(:,2)==1,21:140);
fprintf('Activated, %d/%d, %03f\n',size(sample,1),size(p,1),size(sample,1)/size(p,1));

ci=bootci(100,@(x) mean(x),sample);
fill([1:size(sample,2),size(sample,2):-1:1],[ci(1,:),flip(ci(2,:))],[1,0.8,0.8],'EdgeColor','none');
plot(mean(sample),'-r','LineWidth',1);
if ramp
    set(gca,'XTick',[20:20:120]+0.5,'XTickLabel',{'','0','','2','','4'},'YTick',[0,20]);
else
    set(gca,'XTick',[20:20:120]+0.5,'XTickLabel',{'','0','','2','','4'},'YTick',0:20:40);
end
xlim([0,120]);
ylim([0,45]);
arrayfun(@(x) plot([x,x],ylim(),'k:','LineWidth',1),[40,80,100]);

% yyaxis left;
subplot(2,1,1);
hold on;
sample=s(p(:,1)<0.05 & p(:,2)==0,21:140);
fprintf('Suppressed, %d/%d, %03f\n',size(sample,1),size(p,1),size(sample,1)/size(p,1));
ci=bootci(100,@(x) mean(x),sample);
fill([1:size(sample,2),size(sample,2):-1:1],[ci(1,:),flip(ci(2,:))],[0.8,0.8,1],'EdgeColor','none');
plot(mean(sample),'-b','LineWidth',1);
arrayfun(@(x) plot([x,x],ylim(),'k:','LineWidth',1),[40,80,100]);
xlim([0,120]);
set(gca,'box','off','XTick',[20:20:120],'XTickLabel',[],'YTick',0:5:10);
print('-depsc','-painters','OpSuppCurve.eps');
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
p=sum(abs(permDiff-meanDiff)>=abs(currDiff-meanDiff))./rpt;

end