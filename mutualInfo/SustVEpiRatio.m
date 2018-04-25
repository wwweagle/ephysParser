close all
figure('Color','w','Position',[200,200,240,180]);

ratio=[0.0196,0.1912;...
    0.0705,0.3654;...
    0.0625,0.4911;...
    0,0.1631;...
    0.0088,0.2368];

bh=bar(ratio,'stacked','LineWidth',1);
bh(1).FaceColor='k';
bh(2).FaceColor='w';
xlim([0.5,5.5]);
set(gca,'XTick',[]);
ylabel('Ratio of neuron');