% accu4s=load('Accu4sDNMS_0830_174SU_190226_1457.mat');
% accu8s=load('Accu8sDNMS_0830_147SU_190226_1528.mat');
% pvalues4=testOne(accu4s.accuracy);
% pvalues8=testOne(accu8s.accuracy);
% return
close all
ct4=plotOne(accu4s.accuracy,pvalues4);
plotOne(accu8s.accuracy,pvalues8,ct4);


function pvalues=testOne(accu)

for i=3:(size(accu,3)-8)
    parfor j=3:(size(accu,4)-8)
        pvalues(i,j)=Tools.permTest(accu(:,1,i,j),accu(:,2,i,j));
    end
end
end


function coutourMat=plotOne(accu,pvalues,ct2Mat)
delayLen=(size(accu,4)-18)/2;
figure('Color','w','Position',[100,100,350,250]);
hold on;
imagesc(squeeze(mean(accu(:,1,3:end-8,3:end-8),1)));
colormap('jet');
colorbar;

gcore=[0.077847	0.123317	0.077847;
0.123317	0.195346	0.123317;
0.077847	0.123317	0.077847]
coutourMat=conv2(pvalues(3:end,3:end),gcore,'same');
contour(coutourMat,[0.001,0.001],'LineStyle','-','LineWidth',1.5,'LineColor','w');
if exist('ct2Mat','var')
    contour(ct2Mat,[0.001,0.001],'LineStyle',':','LineWidth',1.5,'LineColor','w');
end
set(gca,'XTick',2.5:10:22.5,'XTickLabel',0:5:10,'YTick',2.5:10:22.5,'YTickLabel',0:5:10)
xlabel('Template time (s)');
ylabel('Test time (s)');
arrayfun(@(x) plot([x,x],ylim(),':k','LineWidth',1),[2.5,4.5,4.5+2*delayLen,6.5+2*delayLen]);
arrayfun(@(x) plot(xlim(),[x,x],':k','LineWidth',1),[2.5,4.5,4.5+2*delayLen,6.5+2*delayLen]);
ylim([0.5,2*delayLen+8.5]);
xlim([0.5,2*delayLen+8.5]);
end
