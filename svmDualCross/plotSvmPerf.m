close all;
barRange=21:24;
load('accuCrossdualIncErrorCrossSVM.mat','accuracyAll');
load('dualIncErrorCrossSVM.mat','allEvts');
perf=cell2mat(arrayfun(@(x) cellfun(@(evts) nnz(xor(evts(:,1)==evts(:,5), evts(:,7)) & evts(:,3)==x)/nnz(evts(:,3)==x),allEvts{1}),[0 2 1],'UniformOutput',false));
figure('Color','w','Position',[1700,400,240,150]);
hold on;
yyaxis left;
yValue=mean(accuracyAll(:,[1 5 3],barRange),3)./100;
bdh=bar(1:3,mean(yValue),'FaceColor','r');
dci=bootci(500,@(x) mean(x),yValue-mean(yValue));
% randd=@(x) rand(size(x,1),1)*0.5-0.25;

% plot((1:3)+randd(yValue),yValue,'r.');
errorbar(1:3,mean(yValue),dci(1,:),dci(2,:),'.k','LineWidth',1);
ylim([0.50,0.65]);
set(gca,'YTick',[0.5,0.6]);
ylabel('DPA sample decoding accuracy');
yyaxis right;


bph=bar((4:6)+1,mean(perf).*100,'FaceColor','b');


pci=(bootci(500,@(x) mean(x),perf)-mean(perf)).*100;
errorbar((4:6)+1,mean(perf).*100,pci(1,:),pci(2,:),'.k','LineWidth',1);
ylim([75,90]);
ylabel('Correct rate (%)');

anova1(mean(accuracyAll(:,[1,5,3],barRange),3))
anova1(perf)

