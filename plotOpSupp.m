% lf=listF();
% osf=lf.listOpSupp();

% s=sampleByType(osf(:,:),'OpSuppress','Average2HzWhole',-2,0.1,11,[100,0;100,0],1,2);
function s=plotOpSupp(ramp)
s=SampleOpSupp('OpSuppress','Average2HzWhole',-2,0.2,11,[100,0;100,0],1,false,ramp);
% figure();
% hh=squeeze(s);
% hh(:,1)=mean(hh(:,16:25),2);
% hh=sortrows(hh,1);
% figure('Color','w','Position',[100,100,300,300]);
% imagesc(flip(hh(:,6:35)),[-3 3]);
% imagesc(flip(bsxfun(@rdivide,hh(:,6:35),mean(hh(:,6:15),2))),[0,2]);
colorbar;
colormap('jet');
set(gca,'XTick',[10:10:100]+0.5,'XTickLabel',[0:2:10])
% set(gca,'XTick',[0:20:100],'XTickLabel',[0:2:10]);
xlabel('Time(s)');
ylabel('Unit No.');

p=nan(size(s,1),2);

if ramp
    lEnd=23;
else 
    lEnd=25;
end

for i=1:size(s,1)
% [~,p(i,1)]=ttest(s(i,6:15),s(i,16:25));
% p(i,1)=ranksum(s(i,6:15),s(i,16:lEnd));
p(i,1)=permTest(s(i,6:15),s(i,16:lEnd),1000);
p(i,2)=mean(s(i,16:lEnd))>mean(s(i,6:15));
end


figure('Color','w','Position',[100,100,170,120]);



%%%%%%%%%%%%%%%%%%%%%%%%%
% subplot('Position',[0.15,0.15,0.8,0.36]);
yyaxis right;
hold on;
sample=s(p(:,1)<0.05 & p(:,2)==1,6:35);
fprintf('Activated, %d/%d, %03f\n',size(sample,1),size(p,1),size(sample,1)/size(p,1));

% sem=std(sample)./sqrt(size(sample,1));

ci=bootci(100,@(x) mean(x),sample);
fill([1:size(sample,2),size(sample,2):-1:1],[ci(1,:),flip(ci(2,:))],[1,0.8,0.8],'EdgeColor','none');
plot(mean(sample),'-r','LineWidth',1);
% plot(sample','Color','r','LineWidth',1);

% plot([20,25;20,25],[ylim()',ylim()'],'k:');
arrayfun(@(x) plot(x,ylim(),'k:','LineWidth',1),[10,20,25]);
if ramp
%     ylim([0,20]);
    set(gca,'XTick',[5:5:30],'XTickLabel',{'','0','','2','','4'},'YTick',[0,20]);
else
%     ylim([0,40]);
    set(gca,'XTick',[5:5:30],'XTickLabel',{'','0','','2','','4'},'YTick',[0,40]);
end
xlim([0,30]);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% subplot('Position',[0.15,0.59,0.8,0.36]);
yyaxis left;
hold on;
sample=s(p(:,1)<0.05 & p(:,2)==0,6:35);
% sample=s(p(:,2)~=0,6:35);
fprintf('Suppressed, %d/%d, %03f\n',size(sample,1),size(p,1),size(sample,1)/size(p,1));

% sem=std(sample)./sqrt(size(sample,1));
% fill([1:size(sample,2),size(sample,2):-1:1],[mean(sample)+sem,fliplr(mean(sample)-sem)],[0.8,0.8,1],'EdgeColor','none');
ci=bootci(100,@(x) mean(x),sample);
fill([1:size(sample,2),size(sample,2):-1:1],[ci(1,:),flip(ci(2,:))],[0.8,0.8,1],'EdgeColor','none');

plot(mean(sample),'-b','LineWidth',1);
% plot(sample','LineWidth',1);
plot([20,25;20,25],[ylim()',ylim()'],'k:');

% ylim([-1,7]);
xlim([0,30]);
% xlabel('Time (s)');
% ylabel('FR (Hz)');
set(gca,'box','off','XTick',[5:5:30],'XTickLabel',[],'YTick',[0,5]);

% subplot('Position',[0.1,0.55,0.8,0.4]);
% 
% 
% h=pie([67 10 85-67-10],{'Suppressed','Activated','Others'});
% h(1).FaceColor='b';
% h(2).FaceColor='r';
% h(3).FaceColor='k';
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