function pcaMovie()
binSize=0.2;
lf=listF();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%these are for choice%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trajectorByLick4s=sampleByType(lf.listDNMS4s,'LickAll','Average2Hz',-2,0.2,12,[20,20;20,20],100,1);
trajectorByLick8s=sampleByType(lf.listDNMS8s,'Match','Average2Hz',-2,0.2,16,[20,20;20,20],100,1);
data=[trajectorByLick4s;trans8s(trajectorByLick8s,0.2)];


binSize=0.2;
avged=mean(data,2);
permed=permute(avged,[1 3 2]);
trialLen=size(data,3)/4*binSize-2;
transversed=permed(:,[6/binSize+1:(trialLen+1)/binSize,(6/binSize+1:(trialLen+1)/binSize)+size(data,3)/2])';


[~,score,latent]=pca(transversed);
segLen=[2,1,0.6];% CAUTION OF DELAY LEN
segColor={'k','r','b'};
azel=[-100,5];% match
pcs=1:3;
%%%%%%%%%%%%%%%%%%%%%%%
%%% end here%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%these are for sample %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% trajectoryByOdor4s=sampleByType(lf.listDNMS4s,'Sample','Average2Hz',-2,binSize,7,[20,20;20,20],100,1);
% % trajectoryByOdor8s=sampleByType(lf.listDNMS8s,'Sample','Average2Hz',-2,binSize,11,[20,20;20,20],100,1);
% data=trajectoryByOdor4s;
% 
% 
% segLen=[1,1,4];
% segColor={'k','b','r'};
% 
% 
% pcs=1:3;
% azel=[-165,10];% 4s dnms
% % azel=[95,5];% 8s dnms
% 
% avged=mean(data,2);
% permed=permute(avged,[1 3 2]);
% trialLen=sum(segLen)+1;
% transversed=permed(:,[1/binSize+1:(trialLen+1)/binSize,(1/binSize+1:(trialLen+1)/binSize)+size(data,3)/2])';
% 
% [~,score,latent]=pca(transversed);

%%%%%%%%%%%%%%%%%%%%%%%
%%% end here%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%


half=size(score,1)/2;

fprintf('first 3 %f\n',sum(latent(1:3))/sum(latent));
fprintf('first 20 %f\n',sum(latent(1:20)/sum(latent)));


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
%         lw=1;
%         ms=6;
        clf;
        hold on;
        grid on;
        onset=1/binSize;%1/binSize for match, 0 for else;

        ph=gobjects(sum(segLen)/binSize,2);
        ph(onset+1,1)=plot3(score(onset+1,(pcs(1))),score(onset+1,(pcs(2))),score(onset+1,(pcs(3))),'-k.','LineWidth',lw,'MarkerSize',ms);
        ph(onset+1,2)=plot3(score(onset+half+1,(pcs(1))),score(onset+half+1,(pcs(2))),score(onset+half+1,(pcs(3))),':k.','LineWidth',lw,'MarkerSize',ms);
        
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
            ph(j,1)=plot3(score(j-1:j,(pcs(1))),score(j-1:j,(pcs(2))),score(j-1:j,(pcs(3))),['-',getColor(j),'.'],'LineWidth',lw,'MarkerSize',ms);
            ph(j,2)=plot3(score((j-1:j)+half,(pcs(1))),score((j-1:j)+half,(pcs(2))),score((j-1:j)+half,(pcs(3))),[':',getColor(j),'.'],'LineWidth',lw,'MarkerSize',ms);
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
        
        
%         tags={'\begin{tabular}{l}PF sample,\\baseline period\end{tabular}',...
%             '\begin{tabular}{l}BN sample,\\baseline period\end{tabular}',...
%             '\begin{tabular}{l}PF sample,\\sample period\end{tabular}',...
%             '\begin{tabular}{l}BN sample,\\sample period\end{tabular}',...
%             '\begin{tabular}{l}PF sample,\\delay period\end{tabular}',...
%             '\begin{tabular}{l}BN sample,\\delay period\end{tabular}'};

        tags={'\begin{tabular}{l}Lick choice,\\test period\end{tabular}',...
            '\begin{tabular}{l}No-lick choice,\\test period\end{tabular}',...
            '\begin{tabular}{l}Lick choice,\\pre-response period\end{tabular}',...
            '\begin{tabular}{l}No-lick choice,\\pre-response period\end{tabular}',...
            '\begin{tabular}{l}Lick choice,\\response period\end{tabular}',...
            '\begin{tabular}{l}No-lick choice,\\response period\end{tabular}'};

        seg=ceil(bin*binSize);
        if seg<=segLen(1)
            legend([ph(onset+1,1),ph(onset+1,2)],tags(1:2),'FontSize',14,'Interpreter','latex','Position',[0.1,0.9,0.27,0.08],'Orientation','Horizontal');
        elseif seg<=sum(segLen(1:2))
            legend([ph(onset+1,1),ph(onset+1,2),ph(onset+1/binSize+1,1),ph(onset+1/binSize+1,2)],tags(1:4),'FontSize',14,'Interpreter','latex','Position',[0.1,0.9,0.54,0.08],'Orientation','Horizontal');
        else
            legend([ph(onset+1,1),ph(onset+1,2),ph(onset+1/binSize+1,1),ph(onset+1/binSize+1,2),ph(onset+2/binSize+1,1),ph(onset+2/binSize+1,2)],tags,'FontSize',14,'Interpreter','latex','Position',[0.1,0.9,0.81,0.08],'Orientation','Horizontal');
        end
    end

    function out=getColor(bin)

        seg=ceil(bin*binSize);
        for i=1:size(segLen,2)
            if sum(ceil(segLen(1:i)))>=seg
                out=segColor{i};
                return;
            end
        end
    end


end