function plotSeq(dataZ,dataSel,fn)
close all;
binSize=0.5;
trialLen=size(dataZ,3)/4-2/binSize;
perm=permute(dataZ,[1 3 2]);
pf=perm(:,1:trialLen+1/binSize);
% pf=smoothOne(perm(:,1:1/binSize+trialLen));
[~,I]=max(pf(:,end-6/binSize+1:end-1/binSize),[],2);

pf=perm(:,1:1/binSize+trialLen);
pf(:,1)=I;
pf=sortrows(pf,1);


bn=perm(:,(1:1/binSize+trialLen)+size(dataZ,3)/2);
bn(:,1)=I;
bn=sortrows(bn,1);
figure('Position',[100,100,800,300],'Color','w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,2,1);
hold on;
imagesc(pf(:,1/binSize+1:end),[-3,3]);
colormap('jet');

xlim([0,trialLen]+0.4);
xlabel('Time (s)');
ylabel('Cell No.');
ylim([-0.5,size(dataZ,1)]);
colorbar();
title('Normalized FR, PF sample');
tag(dataZ);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,2,2);
hold on;
imagesc(bn(:,1/binSize+1:end),[-3,3]);
colormap('jet');

xlim([0,trialLen]+0.4);
xlabel('Time (s)');
ylabel('Cell No.');
ylim([-0.5,size(dataZ,1)+0.5]);
colorbar();
title('Normalized FR, BN sample');
tag(dataZ);

savefig([fn,'_FR_Seq.fig']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
permed=permute(dataSel,[1 3 2]);
% avged=nanmean(permed,3);
permed(permed==0)=realmin;
avged=permed;
selec=(avged(:,1:12/binSize)-avged(:,(1:12/binSize)+size(dataSel,3)/2))./(avged(:,1:12/binSize)+avged(:,(1:12/binSize)+size(dataSel,3)/2));
% a=reshape(avged(:,1:12/binSize),numel(avged(:,1:12/binSize)),1);
% b=reshape(avged(:,(1:12/binSize)+size(data,3)/2),numel(avged(:,1:12/binSize)),1);
% c=(a-b)./(a+b);


smoothed=selec;
for i=1:size(smoothed)
    smoothed(i,:)=smooth(selec(i,:));
end
[~,I]=max(smoothed(:,end-6/binSize+1:end-1/binSize),[],2);
selec(:,1)=I;
figure('Color','w','Position',[100,100,400,300]);
sorted=sortrows(selec,1);

hold on;
imagesc(sorted(:,1/binSize+1:end),[-0.5,0.5]);
colormap('jet');
xlim([0,trialLen]+0.4);
xlabel('Time (s)');
ylabel('Cell No.');
ylim([-0.5,size(dataSel,1)+0.5]);
colorbar();
title('Raw selectivity');
tag(dataZ);
savefig([fn,'_Raw_Selectivity.fig']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selec=abs(selec);
smoothed=selec;
for i=1:size(smoothed)
    smoothed(i,:)=smooth(selec(i,:));
end
[~,I]=max(smoothed(:,end-6/binSize+1:end-1/binSize),[],2);
selec(:,1)=I;
figure('Color','w','Position',[100,100,400,300]);
sorted=sortrows(selec,1);

hold on;
imagesc(sorted(:,1/binSize+1:end),[-0.5,0.5]);
colormap('jet');
if size(dataSel,3)/4*binSize-5==8
    set(gca,'XTick',(1:3:11)./binSize+0.5,'XTickLabel',0:3:9);
    plot([1,2,10,11;1,2,10,11]./binSize+0.5,repmat(ylim()',1,4),':k');
end
xlim([0,trialLen]+0.4);
xlabel('Time (s)');
ylabel('Cell No.');
ylim([-0.5,size(dataSel,1)+0.5]);
colorbar();
title('abs selectivity');
tag(dataZ);
savefig([fn,'_abs_selectivity.fig']);


    function tag(dataZ)
        switch size(dataZ,3)/4*binSize-5
    case 8
        set(gca,'XTick',(1:3:11)./binSize+0.5,'XTickLabel',0:3:9);
        plot([1,2,10,11;1,2,10,11]./binSize+0.5,repmat(ylim()',1,4),':k');
    case 4
        set(gca,'XTick',(1:5:6)./binSize+0.5,'XTickLabel',0:5:5);
        plot([1,2,6,7;1,2,6,7]./binSize+0.5,repmat(ylim()',1,4),':k');
        end
    end


    function smoothed=smoothOne(data)
        smoothed=nan(size(data,1),size(data,2));
        for i=1:size(data,1)
            smoothed(i,:)=smooth(data(i,:));
        end
    end


end