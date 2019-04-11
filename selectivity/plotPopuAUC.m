close all

AUCS=AUC4;

bins=linspace(0,1,21);
histCorr=histcounts(AUCS(1,:),bins,'Normalization','probability');
% histErr=histcounts(AUCS(2,:),bins);
fh=figure('Color','w');
fh.Position(3:4)=[285,250];
hold on;
xpos=bins(1:end-1)+diff(bins(1:2));
bar(xpos,histCorr,0.8,'EdgeColor','none','FaceColor','k');
xlabel('AUC');
ylabel('Probability');
% bar(xpos+dpos*0.225,histErr,0.45,'EdgeColor','none','FaceColor','r');