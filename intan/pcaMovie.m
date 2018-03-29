function pcaMovie()
binSize=0.2;



[sample3,ids3]=processAll('sample',3,[-2,0.2,8],[20,20],100);
[sample2,ids2]=processAll('sample',2,[-2,0.2,8],[20,20],100);

[sample4,ids4]=processAll('sample',4,[-2,0.2,8],[20,20],100);
[sample5,ids5]=processAll('sample',5,[-2,0.2,8],[20,20],100);

[sample6,ids6]=processAll('sample',6,[-2,0.2,8],[20,20],100);
[sample12,ids12]=processAll('sample',12,[-2,0.2,8],[20,20],100);

sample2=sample2(ismember(ids2,ids3,'rows'),:,:);
sample4=sample4(ismember(ids4,ids3,'rows'),:,:);
sample5=sample5(ismember(ids5,ids3,'rows'),:,:);
sample6=sample6(ismember(ids6,ids3,'rows'),:,:);
sample12=sample12(ismember(ids12,ids3,'rows'),:,:);


permed=squeeze(mean(cat(3,sample2,sample3,sample4,sample5,sample6,sample12),2));
segLen=[1,1,5];

pcs=1:3;
azel=[-165,10];


trialLen=sum(segLen)+1;
transversed=[];
for k=1:6
    offset=(k-1)*size(permed,2)/6;
    transversed=[transversed;permed(:,(1/binSize+1:(trialLen+1)/binSize)+offset)'];
end


[~,score,latent]=pca(transversed);

delta=size(score,1)/6;

% fprintf('first 3 %f\n',sum(latent(1:3))/sum(latent));
% fprintf('first 20 %f\n',sum(latent(1:20)/sum(latent)));


close all
figure('Color','w','Position',[100,100,1280,720]);
plotAll(score);

    function plotAll(score)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Video head %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    v=VideoWriter('PCAVideo.avi','Uncompressed AVI');
    v.FrameRate=5;
    open(v);
        
        
        lw=2;
        ms=24;

        clf;
        hold on;
        grid on;
        onset=0;%1/binSize;%1/binSize for match, 0 for else;

        ph=gobjects(sum(segLen)/binSize,2);
        for i=1:6
            offset=(i-1)*delta;
            ph(onset+1,i)=plot3(score(onset+1+offset,(pcs(1))),score(onset+1+offset,(pcs(2))),score(onset+1+offset,(pcs(3))),getStyle(i,onset+1),'LineWidth',lw,'MarkerSize',ms);
        end
        
        xlabel('PC1 (a.u.)');
        ylabel('PC2 (a.u.)');
        zlabel('PC3 (a.u.)');
        view(azel);
        seqLegend(onset,1,ph);
        pause(0.2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Video Tail %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
        f=getframe(gcf);
        writeVideo(v,f);
        for j=onset+2:(sum(segLen)/binSize)
            for i=1:6
                offset=(i-1)*delta;
                ph(j,i)=plot3(score(j-1+offset:j+offset,(pcs(1))),score(j-1+offset:j+offset,(pcs(2))),score(j-1+offset:j+offset,(pcs(3))),getStyle(i,j),'LineWidth',lw,'MarkerSize',ms);
            end
            seqLegend(onset,j,ph);
            pause(0.2);
            f=getframe(gcf);
            writeVideo(v,f);
        end
%         
        viewAng=(0:10:360)+azel(1);
        viewAng=[repmat(azel(1),1,5),viewAng];
        viewAng(viewAng>180)=viewAng(viewAng>180)-360;
        viewAng=[viewAng,repmat(viewAng(end),1,5)];
        for az=viewAng
            view(az,azel(2));
            pause(0.2);
            f=getframe(gcf);
            writeVideo(v,f);
        end
        close(v);
        
    end

    function seqLegend(onset,bin,ph)
        
        
        tags={'\begin{tabular}{l}PF sample,\\baseline period\end{tabular}',...
            '\begin{tabular}{l}BN sample,\\baseline period\end{tabular}',...
            '\begin{tabular}{l}PF sample,\\sample period\end{tabular}',...
            '\begin{tabular}{l}BN sample,\\sample period\end{tabular}',...
            '\begin{tabular}{l}PF sample,\\delay period\end{tabular}',...
            '\begin{tabular}{l}BN sample,\\delay period\end{tabular}'};

        seg=ceil(bin*binSize);
        if seg<=segLen(1)
            legend([ph(onset+1,1),ph(onset+1,2)],tags(1:2),'FontSize',14,'Interpreter','latex','Position',[0.1,0.9,0.27,0.08],'Orientation','Horizontal');
        elseif seg<=sum(segLen(1:2))
            legend([ph(onset+1,1),ph(onset+1,2),ph(onset+1/binSize+1,1),ph(onset+1/binSize+1,2)],tags(1:4),'FontSize',14,'Interpreter','latex','Position',[0.1,0.9,0.54,0.08],'Orientation','Horizontal');
        else
            legend([ph(onset+1,1),ph(onset+1,2),ph(onset+1/binSize+1,1),ph(onset+1/binSize+1,2),ph(onset+2/binSize+1,1),ph(onset+2/binSize+1,2)],tags,'FontSize',14,'Interpreter','latex','Position',[0.1,0.9,0.81,0.08],'Orientation','Horizontal');
        end
    end

    function out=getStyle(lineIdx,bin)
        segColor={'r','b','b','r','m','r'};
        segLineStyles={':','-','-'};
        seg=ceil(bin*binSize);
        for i=1:size(segLen,2)
            if sum(ceil(segLen(1:i)))>=seg
                out=[segLineStyles{i},segColor{lineIdx},'.'];
                return;
            end
        end
    end

    function trim()
%         set(gcf,'Position',[100,100,370,300])
        ls=findobj(gcf,'type','line');
        for i=1:length(ls)
        ls(i).MarkerSize=8;
        end
        for i=1:length(ls)
        ls(i).LineWidth=1;
        end
        legend('off')
        set(gcf,'Position',[100,100,800,400])
    end
        


end