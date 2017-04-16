function lickTriggeredAverage
load('lickTrigFR.mat')

[p,fr,frz]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],0);
% [pL3,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],-0.75);
[pL2,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],-0.5);
[pL1,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],-0.25);
[pR1,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],0.25);
[pR2,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],0.5);
% [pR3,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],0.75);
[pRS,~,~]=alignLickTrigAvg([id4;id8],[lickTrigAvg4;lickTrigAvg8],'r');



bootratio=nan(50,6);
bootratio(:,1)=bootstrp(50,@(x) sum(x(:,1)<0.05)./size(x,1),pL2);
bootratio(:,2)=bootstrp(50,@(x) sum(x(:,1)<0.05)./size(x,1),pL1);
bootratio(:,3)=bootstrp(50,@(x) sum(x(:,1)<0.05)./size(x,1),p);
bootratio(:,4)=bootstrp(50,@(x) sum(x(:,1)<0.05)./size(x,1),pR1);
bootratio(:,5)=bootstrp(50,@(x) sum(x(:,1)<0.05)./size(x,1),pR2);
bootratio(:,6)=bootstrp(50,@(x) sum(x(:,1)<0.05)./size(x,1),pRS);

figure();
hold on;

for i=1:6
    bias=rand(50,1)*0.6-0.3;
    plot(i+bias,bootratio(:,i),'Marker','o','LineStyle','none','MarkerFaceColor',[0.7,0.7,0.7],'MarkerEdgeColor','none','MarkerSize',1);
end
ci=nan(2,6);
ci(:,1)=bootci(500,@(x) sum(x(:,1)<0.05)./size(x,1),pL2);
ci(:,2)=bootci(500,@(x) sum(x(:,1)<0.05)./size(x,1),pL1);
ci(:,3)=bootci(500,@(x) sum(x(:,1)<0.05)./size(x,1),p);
ci(:,4)=bootci(500,@(x) sum(x(:,1)<0.05)./size(x,1),pR1);
ci(:,5)=bootci(500,@(x) sum(x(:,1)<0.05)./size(x,1),pR2);
ci(:,6)=bootci(500,@(x) sum(x(:,1)<0.05)./size(x,1),pRS);

for i=1:6
    errorbar(i,mean(bootratio(:,i)),mean(bootratio(:,i))-ci(1,i),ci(2,i)-mean(bootratio(:,i)),'o','Color','k','LineWidth',1);
end


set(gcf,'Color','w','Position',[100,100,330,80]);
set(gca,'XTick',[1:6],'XTickLabel',-0.5:0.25:0.75);
[tab,chi2,chisqP]=crosstab([ones(size(p,1),1);ones(size(p,1),1)*2;ones(size(p,1),1)*3;ones(size(p,1),1)*4;ones(size(p,1),1)*5;ones(size(p,1),1)*6],...
    [p(:,1)<0.05;pL2(:,1)<0.05;pL1(:,1)<0.05;pR1(:,1)<0.05;pR2(:,1)<0.05;pRS(:,1)<0.05]);
xlim([0,7]);
set(gca,'box','off');


% bar([sum(pL2(:,1)<0.05)./size(p,1),sum(pL1(:,1)<0.05)./size(p,1),sum(p(:,1)<0.05)./size(p,1),sum(pR1(:,1)<0.05)./size(p,1),sum(pR2(:,1)<0.05)./size(p,1),sum(pRS(:,1)<0.05)./size(p,1)],'FaceColor','k');