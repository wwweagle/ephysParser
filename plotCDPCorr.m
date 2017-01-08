function plotCDPCorr(CDPBar)
figure('Color','w','Position',[100,100,175,175]);
hold on
plot(CDPBar(:,1),CDPBar(:,2),'.k')
plot(CDPBar(:,3),CDPBar(:,4),'.b')
plot(CDPBar(:,5),CDPBar(:,6),'.r')
xlim([-50,300]);
set(gca,'XTick',[0,200]);
savefig('CDPCorr.fig');
convertFigs('CDPCorr');

end