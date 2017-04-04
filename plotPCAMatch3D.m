
function plotPCAMatch3D()%(data,endpoint,pcs,isDNMS,azel)
endpoint=7;
pcs=1:3;
% isDNMS=true;
azel=[-100,5];
% lf=listF();
% trajectorByMatch4s=sampleByType(lf.listDNMS4s,'Match','Average2Hz',-2,0.2,12,[20,20;20,20],100,1);
% trajectorByMatch8s=sampleByType(lf.listDNMS8s,'Match','Average2Hz',-2,0.2,16,[20,20;20,20],100,1);
% data=[trajectorByMatch4s;trans8s(trajectorByMatch8s,0.2)];
data=evalin('base','data');
binSize=0.2;
avged=mean(data,2);
permed=permute(avged,[1 3 2]);
trialLen=size(data,3)/4*binSize-2;
transversed=permed(:,[6/binSize+1:(trialLen+1)/binSize,(6/binSize+1:(trialLen+1)/binSize)+size(data,3)/2])';

[~,score,latent]=pca(transversed);
fprintf('first 3 %f\n',sum(latent(1:3))/sum(latent));
fprintf('first 20 %f\n',sum(latent(1:20)/sum(latent)));


close all
figure('Color','w','Position',[2000,100,370,250]);
hold on;

half=(size(score,1)/2);
seg1=1/binSize+1:2/binSize;
seg2=seg1(end)+(0:1/binSize);
seg3=seg2(end)+(0:ceil(0.5/binSize));

p1=plot3(score(seg1,(pcs(1))),score(seg1,(pcs(2))),score(seg1,(pcs(3))),'-k.','LineWidth',1);
p2=plot3(score(seg1+half,(pcs(1))),score(seg1+half,(pcs(2))),score(seg1+half,(pcs(3))),':k.','LineWidth',1);


p1=plot3(score(seg2,(pcs(1))),score(seg2,(pcs(2))),score(seg2,(pcs(3))),'-r.','LineWidth',1);
p2=plot3(score(seg2+half,(pcs(1))),score(seg2+half,(pcs(2))),score(seg2+half,(pcs(3))),':r.','LineWidth',1);

p1=plot3(score(seg3,(pcs(1))),score(seg3,(pcs(2))),score(seg3,(pcs(3))),'-b.','LineWidth',1);
p2=plot3(score(seg3+half,(pcs(1))),score(seg3+half,(pcs(2))),score(seg3+half,(pcs(3))),':b.','LineWidth',1);

% lh=legend([p1,p2],{'PF sample, delay','BN sample, delay'},'FontSize',12,'Location','none','Position',[0.08,0.88,0.17,0.1]);
            
            
            
    function useless
        dEnd=(1/binSize);
        sEnd=(2/binSize);
        rStart=(3/binSize);
        rEnd=round(3.5/binSize);
        half=(size(score,1)/2);
        endpoint=endpoint/binSize;
        
        grid on
        % view(azel);
        % xlim([-105,105]);
        % ylim([-50,40]);
        % zlim([-35,35]);
        
        if(endpoint<=dEnd)
            pDelayEnd(true);
        elseif(endpoint<=sEnd)
            pDelayEnd(false);
            pTest(true);
        elseif endpoint<rStart
            pDelayEnd(false);
            pTest(false);
            pReward(true);
        elseif endpoint<rEnd
            pDelayEnd(false);
            pTest(false);
            pReward(false);
            pPreResp(true);
        else
            pDelayEnd(false);
            pTest(false);
            pReward(false);
            pPreResp(false);
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
        
        
        
        function pDelayEnd(toEnd)
            if toEnd
                ep=endpoint;
            else
                ep=dEnd;
            end
            
            
            p1=plot3(score(1:ep,(pcs(1))),score(1:ep,(pcs(2))),score(1:ep,(pcs(3))),'-k.');
            p2=plot3(score(1+half:ep+half,(pcs(1))),score(1+half:ep+half,(pcs(2))),score(1+half:ep+half,(pcs(3))),'--k.');
            lh=legend([p1,p2],{'PF sample, baseline','BN sample, baseline'},'FontSize',12,'Location','none','Position',[0.08,0.88,0.17,0.1]);
        end
        
        
        function pTest(toEnd)
            if toEnd
                ep=endpoint;
            else
                ep=sEnd;
            end
            
            p1=plot3(score(dEnd:ep,(pcs(1))),score(dEnd:ep,(pcs(2))),score(dEnd:ep,(pcs(3))),'-b.');
            p2=plot3(score(dEnd+half:ep+half,(pcs(1))),score(dEnd+half:ep+half,(pcs(2))),score(dEnd+half:ep+half,(pcs(3))),'--b.');
            
            lh=legend([p1,p2],{'PF sample, sample','BN sample, sample'},'FontSize',12,'Location','none','Position',[0.08,0.88,0.17,0.1]);
        end
        
        
        function pReward(toEnd)
            
            if toEnd
                ep=endpoint;
            else
                ep=rEnd;
            end
            
            
            lstyle={'-c.','--c.'};
            
            
            p1=plot3(score(rStart:ep,(pcs(1))),score(rStart:ep,(pcs(2))),score(rStart:ep,(pcs(3))),lstyle{1});
            p2=plot3(score(rStart+half:ep+half,(pcs(1))),score(rStart+half:ep+half,(pcs(2))),score(rStart+half:ep+half,(pcs(3))),lstyle{2});
            %         lh=legend([p1,p2],{'PF sample, distractor','BN sample, distractor'},'FontSize',12,'Location','none','Position',[0.08,0.88,0.17,0.1]);
            lh=legend([p1,p2],{'PF sample, delay','BN sample, delay'},'FontSize',12,'Location','none','Position',[0.08,0.88,0.17,0.1]);
        end
        
        function pPreResp(toEnd)
            if toEnd
                ep=endpoint;
            else
                ep=rStart;
            end
            
            p1=plot3(score(sEnd:ep,(pcs(1))),score(sEnd:ep,(pcs(2))),score(sEnd:ep,(pcs(3))),'-r.');
            p2=plot3(score(sEnd+half:ep+half,(pcs(1))),score(sEnd+half:ep+half,(pcs(2))),score(sEnd+half:ep+half,(pcs(3))),'--r.');
            lh=legend([p1,p2],{'PF sample, delay','BN sample, delay'},'FontSize',12,'Location','none','Position',[0.08,0.88,0.17,0.1]);
        end
        
        
        function pLate
            ep=endpoint;
            p1=plot3(score(rEnd:ep,(pcs(1))),score(rEnd:ep,(pcs(2))),score(rEnd:ep,(pcs(3))),'-m.');
            p2=plot3(score(rEnd+half:ep+half,(pcs(1))),score(rEnd+half:ep+half,(pcs(2))),score(rEnd+half:ep+half,(pcs(3))),'--m.');
            lh=legend([p1,p2],{'PF sample, delay','BN sample, delay'},'FontSize',12,'Location','none','Position',[0.08,0.88,0.17,0.1]);
        end
    end
end

% 
% %
% view([-100,5]);
% xlabel('PC1 (a.u.)');
% xlim([-20,105]);
% ylabel('PC2 (a.u.)');
% ylim([-55,90]);
% zlim([-27,35])
% grid on;
% set(gcf,'Position',[100,100,375,240]);