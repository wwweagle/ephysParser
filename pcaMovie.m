function pcaMovie()
binSize=0.2;
lf=listF();
% trajectoryByOdor4s=sampleByType(lf.listDNMS4s,'Sample','Average2Hz',-2,binSize,7,[20,20;20,20],100,1);
trajectoryByOdor8s=sampleByType(lf.listDNMS8s,'Sample','Average2Hz',-2,binSize,11,[20,20;20,20],100,1);
% load('videoData.mat','trajectoryByOdor8s');
data=trajectoryByOdor8s;


segLen=[1,1,8];% CAUTION OF DELAY LEN


segColor={'k','b','r'};

pcs=1:3;
% azel=[-165,10];%4s dnms
azel=[95,5];%8s dnms

avged=mean(data,2);
permed=permute(avged,[1 3 2]);
trialLen=sum(segLen)+1;%sum+1 in 8s delay, sum in 4s delay dual to plotting history
transversed=permed(:,[1/binSize+1:(trialLen+1)/binSize,(1/binSize+1:(trialLen+1)/binSize)+size(data,3)/2])';


[~,score,latent]=pca(transversed);
half=size(score,1)/2;

fprintf('first 3 %f\n',sum(latent(1:3))/sum(latent));
fprintf('first 20 %f\n',sum(latent(1:20)/sum(latent)));


close all
figure('Color','w','Position',[100,100,1280,720]);
plotAll(score);

    function plotAll(score)
        
    v=VideoWriter('PCAVideo.avi','Uncompressed AVI');
    v.FrameRate=5;
    open(v);
        
        
        lw=2;
        ms=24;
        clf;
        hold on;
        grid on;
        onset=0;

        ph=gobjects(2,sum(segLen)/binSize);
        ph(1,1)=plot3(score(onset+1,(pcs(1))),score(onset+1,(pcs(2))),score(onset+1,(pcs(3))),'-k.','LineWidth',lw,'MarkerSize',ms);
        ph(1,2)=plot3(score(onset+half+1,(pcs(1))),score(onset+half+1,(pcs(2))),score(onset+half+1,(pcs(3))),':k.','LineWidth',lw,'MarkerSize',ms);
        
        xlabel('PC1 (a.u.)');
        ylabel('PC2 (a.u.)');
        zlabel('PC3 (a.u.)');
        view(azel);
        seqLegend(1,ph);
        pause(0.2);
        f=getframe(gcf);
        writeVideo(v,f);
        for j=onset+2:onset+(sum(segLen)/binSize)
            ph(j,1)=plot3(score(j-1:j,(pcs(1))),score(j-1:j,(pcs(2))),score(j-1:j,(pcs(3))),['-',getColor(j),'.'],'LineWidth',lw,'MarkerSize',ms);
            ph(j,2)=plot3(score((j-1:j)+half,(pcs(1))),score((j-1:j)+half,(pcs(2))),score((j-1:j)+half,(pcs(3))),[':',getColor(j),'.'],'LineWidth',lw,'MarkerSize',ms);
            seqLegend(j,ph);
            pause(0.2);
            f=getframe(gcf);
            writeVideo(v,f);
        end
        
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

    function seqLegend(bin,ph)
        tags={'BN sample, baseline','PF sample,baseline','BN sample, sample','PF sample, sample','BN sample, delay','PF sample,delay'};
        seg=ceil(bin*binSize);
        if seg<=1
            legend([ph(1,1),ph(1,2)],tags(1:2),'Location','northeastoutside','FontSize',14);
        elseif seg<=2
            legend([ph(1,1),ph(1,2),ph(1/binSize+1,1),ph(1/binSize+1,2)],tags(1:4),'Location','northeastoutside','FontSize',14);
        else
            legend([ph(1,1),ph(1,2),ph(1/binSize+1,1),ph(1/binSize+1,2),ph(2/binSize+1,1),ph(2/binSize+1,2)],tags,'Location','northeastoutside','FontSize',14);
        end
    end

    function out=getColor(bin)
%         bin=bin-1/binSize;
        seg=ceil(bin*binSize);
        for i=1:size(segLen,2)
            if sum(segLen(1:i))>=seg
                out=segColor{i};
                return;
            end
        end
    end
end