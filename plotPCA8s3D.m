function plotPCA8s3D(data,endpoint,pcs,isDNMS,azel)
%plotPCA8s3D([sNoneDist;trans13(sNoneDist13)],22)
% load byOdor8s100msBin.mat;
binSize=0.2;
avged=mean(data,2);
permed=permute(avged,[1 3 2]);
trialLen=size(data,3)/4*binSize-2;
transversed=permed(:,[1/binSize+1:(trialLen+1)/binSize,(1/binSize+1:(trialLen+1)/binSize)+size(data,3)/2])';

[~,score,latent]=pca(transversed);
fprintf('first 3 %f\n',sum(latent(1:3))/sum(latent));
fprintf('first 20 %f\n',sum(latent(1:20)/sum(latent)));


% close all
% figure('Color','w','Position',[2000,100,600,400]);
hold on;
bEnd=(1/binSize);
sEnd=(2/binSize);
dStart=(4/binSize);
dEnd=round(5.5/binSize);
half=(size(score,1)/2);
endpoint=endpoint/binSize;

grid on
view(azel);
xlim([-105,105]);
ylim([-50,40]);
zlim([-35,35]);

if(endpoint<=bEnd)
    pBase(true);
elseif(endpoint<=sEnd)
    pBase(false);
    pSample(true);
elseif endpoint<dStart
    pBase(false);
    pSample(false);
    pEarly(true);
elseif endpoint<dEnd
    pBase(false);
    pSample(false);
    pEarly(false);
    pD(true);
else
    pBase(false);
    pSample(false);
    pEarly(false);
    pD(false);
    pLate;
end
% plot3(score(10:30,1),score(10:30,2),score(10:30,3),'-r.');
% plot3(score(5:10,1),score(5:10,2),score(5:10,3),'-b.');
% plot3(score(10:30,1),score(10:30,2),score(10:30,3),'-r.');
%
% plot3(score(1+30:5+30,1),score(1+30:5+30,2),score(1+30:5+30,3),'--g.');
% plot3(score(5+30:10+30,1),score(5+30:10+30,2),score(5+30:10+30,3),'--b.');
% plot3(score(10+30:30+30,1),score(10+30:30+30,2),score(10+30:30+30,3),'--r.');
% grid off;
xlabel(['PC',num2str(pcs(1))]);
ylabel(['PC',num2str(pcs(2))]);
zlabel(['PC',num2str(pcs(3))]);



    function pBase(toEnd)
        if toEnd
            ep=endpoint;
        else
            ep=1/binSize;
        end
           
        
        p1=plot3(score(1:ep,(pcs(1))),score(1:ep,(pcs(2))),score(1:ep,(pcs(3))),'-k.');
        p2=plot3(score(1+half:ep+half,(pcs(1))),score(1+half:ep+half,(pcs(2))),score(1+half:ep+half,(pcs(3))),'--k.');
        lh=legend([p1,p2],{'PF sample, baseline','BN sample, baseline'},'FontSize',12,'Location','none','Position',[0.08,0.88,0.17,0.1]);
    end


    function pSample(toEnd)
        if toEnd
            ep=endpoint;
        else
            ep=2/binSize;
        end
        
        p1=plot3(score(bEnd:ep,(pcs(1))),score(bEnd:ep,(pcs(2))),score(bEnd:ep,(pcs(3))),'-b.');
        p2=plot3(score(bEnd+half:ep+half,(pcs(1))),score(bEnd+half:ep+half,(pcs(2))),score(bEnd+half:ep+half,(pcs(3))),'--b.');
        
        lh=legend([p1,p2],{'PF sample, sample','BN sample, sample'},'FontSize',12,'Location','none','Position',[0.08,0.88,0.17,0.1]);
    end


    function pD(toEnd)
        fprintf('dnms %d\n',isDNMS);
        
        if toEnd
            ep=endpoint;
        else
            ep=6/binSize;
        end
        
        if isDNMS==1
            lstyle={'-r.','--r.'};
        else
            lstyle={'-c.','--c.'};
        end
        
        
        p1=plot3(score(dStart:ep,(pcs(1))),score(dStart:ep,(pcs(2))),score(dStart:ep,(pcs(3))),lstyle{1});
        p2=plot3(score(dStart+half:ep+half,(pcs(1))),score(dStart+half:ep+half,(pcs(2))),score(dStart+half:ep+half,(pcs(3))),lstyle{2});
%         lh=legend([p1,p2],{'PF sample, distractor','BN sample, distractor'},'FontSize',12,'Location','none','Position',[0.08,0.88,0.17,0.1]);
        lh=legend([p1,p2],{'PF sample, delay','BN sample, delay'},'FontSize',12,'Location','none','Position',[0.08,0.88,0.17,0.1]);
    end

    function pEarly(toEnd)
        if toEnd
            ep=endpoint;
        else
            ep=4/binSize;
        end        
        
        p1=plot3(score(sEnd:ep,(pcs(1))),score(sEnd:ep,(pcs(2))),score(sEnd:ep,(pcs(3))),'-r.');
        p2=plot3(score(sEnd+half:ep+half,(pcs(1))),score(sEnd+half:ep+half,(pcs(2))),score(sEnd+half:ep+half,(pcs(3))),'--r.');
        lh=legend([p1,p2],{'PF sample, delay','BN sample, delay'},'FontSize',12,'Location','none','Position',[0.08,0.88,0.17,0.1]);
    end


    function pLate
        ep=endpoint;
        p1=plot3(score(dEnd:ep,(pcs(1))),score(dEnd:ep,(pcs(2))),score(dEnd:ep,(pcs(3))),'-r.');
        p2=plot3(score(dEnd+half:ep+half,(pcs(1))),score(dEnd+half:ep+half,(pcs(2))),score(dEnd+half:ep+half,(pcs(3))),'--r.');
        lh=legend([p1,p2],{'PF sample, delay','BN sample, delay'},'FontSize',12,'Location','none','Position',[0.08,0.88,0.17,0.1]);
    end




% legend({'PF baseline','PF odor Sample','PF delay','BN baseline','BN odor Sample','BN delay'});
%
% dpath=javaclasspath('-dynamic');
% if ~ismember('hel2arial\hel2arial.jar',dpath)
%     javaaddpath('hel2arial\hel2arial.jar');
% end
% h2a=hel2arial.Hel2arial;
% set(gcf,'PaperPositionMode','auto');
% print('-depsc','PCA8s3D.eps','-cmyk');
% %         close gcf;
% h2a.h2a([pwd,'\PCA8s3D.eps']);

end