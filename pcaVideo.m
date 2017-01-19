function pcaVideo
load videoData.mat
% sGoDist=sampleDualByType('distrGo','Average2Hz',-2,0.5,11,[20,20;20,20],100,1);
% sNogoDist=sampleDualByType('distrNoGo','Average2Hz',-2,0.5,11,[20,20;20,20],100,1);
% sNoneDist=sampleDualByType('distrNone','Average2Hz',-2,0.5,11,[20,20;20,20],100,1);
% 
% sGoDist13=sampleDualByType('distrGo','Average2Hz',-2,0.5,16,[20,20;20,20],100,1,'WJ');
% sNogoDist13=sampleDualByType('distrNoGo','Average2Hz',-2,0.5,16,[20,20;20,20],100,1,'WJ');
% sNoneDist13=sampleDualByType('distrNone','Average2Hz',-2,0.5,16,[20,20;20,20],100,1,'WJ');
% 
% lf=listF();
% trajectoryByOdor8s=sampleByType(lf.listDNMS8s,'odor','Average2Hz',-2,0.5,11,[20,20;20,20],100,1);

vName={'pcaVideoNone.mp4','pcaVideoNogo.mp4','pcaVideoGo.mp4','pcaVideoGoPC456.mp4','pcaVideoDNMS.avi'};
isDNMS=[0,0,0,0,1,1];
pcs={1:3,[6,5,1],[9,20,20],4:6,1:3,1:3};
setName={'NoneSet.mat','nogoSet.mat','GoSet.mat','GoSet.mat','DNMSSet.mat'};
dSet={[sNoneDist;trans13(sNoneDist13)],[sNogoDist;trans13(sNogoDist13)],[sGoDist;trans13(sGoDist13)],[sGoDist;trans13(sGoDist13)],trajectoryByOdor8s,trajectoryByOdor4s};
azel={[100,18],[85,3],[-10,10],[60,10],[95,5],[-165,10]};


pc=plotCurve();
for o=5
    load(setName{o});
    v=VideoWriter(vName{o},'Uncompressed AVI');
    v.FrameRate=5;
%     v.Quality=95;
    open(v);
    
%     for i=[2,2,2,2,2:22,22,22,22,22]
      for i=10%0.2:0.2:10
        close all;
%         figure('Color','w','Position',[100,100,160,300]);
        figure('Color','w','Position',[100,100,420,200]);
        subplot('Position',[0.07,0.15,0.5,0.8]);
        plotPCA8s3D(dSet{o},i,pcs{o},isDNMS(o),azel{o});
%         xlim([-25,65]);
%         ylim([-40,30]);
%         zlim([-25,30]);
        subplot('Position',[0.65,0.15,0.32,0.8]);
        pc.subPlot(plotLength,ci1,ci2,ci3,dist,normalRef,delay);
        xlim([0,i*2]);
        ylim([50,600]);
        ylabel('Normalized Distance %');
        xlabel('Time (s)');
%         pause();
        f=getframe(gcf);
        writeVideo(v,f);
%         pause
        end
    close(v);

end

% 
% 
% v=VideoWriter('pcaVideoNogo.mp4','MPEG-4');
% v.FrameRate=5;
% v.Quality=90;
% open(v);
% for i=2:22
%     close all;
%     figure('Color','w','Position',[2000,100,400,600]);
% 	subplot('Position',[0.15,0.45,0.8,0.5]);
%     plotPCA8s3D([sNogoDist;trans13(sNogoDist13)],i);
%     subplot('Position',[0.15,0.1,0.8,0.28]);
%     pc.subPlot(plotLength,ci1,ci2,ci3,dist,normalRef,delay)
%     xlim([0,i]);
%     ylabel('Normalized Distance %');
%     xlabel('Time (s)');
%     
%     f=getframe(gcf);
%     writeVideo(v,f);
% end
%     writeVideo(v,f);
%         writeVideo(v,f);
%             writeVideo(v,f);
%                 writeVideo(v,f);
%                     writeVideo(v,f);
% close(v);
% 
% 
% 
% v=VideoWriter('pcaVideoGoPC234.mp4','MPEG-4');
% v.FrameRate=5;
% v.Quality=90;
% open(v);
% for i=2:22
%     close all;
%     figure('Color','w','Position',[2000,100,400,600]);
% 	subplot('Position',[0.15,0.45,0.8,0.5]);
%     plotPCA8s3D([sGoDist;trans13(sGoDist13)],i);
%     subplot('Position',[0.15,0.1,0.8,0.28]);
%     pc.subPlot(plotLength,ci1,ci2,ci3,dist,normalRef,delay)
%     xlim([0,i]);
%     ylabel('Normalized Distance %');
%     xlabel('Time (s)');
%     
%     f=getframe(gcf);
%     writeVideo(v,f);
% end
%     writeVideo(v,f);
%         writeVideo(v,f);
%             writeVideo(v,f);
%                 writeVideo(v,f);
%                     writeVideo(v,f);
% close(v);
% 
% 
% 
% v=VideoWriter('pcaVideoDNMS.mp4','MPEG-4');
% v.FrameRate=5;
% v.Quality=90;
% open(v);
% for i=2:22
%     close all;
%     figure('Color','w','Position',[2000,100,400,600]);
% 	subplot('Position',[0.15,0.45,0.8,0.5]);
%     plotPCA8s3D(trajectoryByMatch8s,i);
%     subplot('Position',[0.15,0.1,0.8,0.28]);
%     pc.subPlot(plotLength,ci1,ci2,ci3,dist,normalRef,delay)
%     xlim([0,i]);
%     ylabel('Normalized Distance %');
%     xlabel('Time (s)');
%     
%     f=getframe(gcf);
%     writeVideo(v,f);
% end
%     writeVideo(v,f);
%         writeVideo(v,f);
%             writeVideo(v,f);
%                 writeVideo(v,f);
%                     writeVideo(v,f);
% close(v);

end