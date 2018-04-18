% plotDualIm
sampFstr=load('ImDualAll8s.mat');
distrFstr=load('Im8sDistr.mat');
dnmsFstr=load('Im8sDNMS.mat');

dpaSampCount=zeros(1,length(sampFstr.Im{1,2})-4);
gngSampCount=zeros(1,length(sampFstr.Im{1,2})-4);
mixSampCount=zeros(1,length(sampFstr.Im{1,2})-4);
dnmsSampCount=zeros(1,length(sampFstr.Im{1,2})-4);
for i=1:length(sampFstr.Im)
    for j=3:length(sampFstr.Im{i,2})-2
        dpaSel=all(sampFstr.Im{i,2}(j-2:j+2)>0) && all(sampFstr.pCrossTime{i,2}(j-2:j+2)<0.01);
        gngSel=all(distrFstr.Im{i,2}(j-2:j+2)>0) && all(distrFstr.pCrossTime{i,2}(j-2:j+2)<0.01);
        if dpaSel && gngSel
            mixSampCount(j-2)=mixSampCount(j-2)+1;
        elseif dpaSel
            dpaSampCount(j-2)=dpaSampCount(j-2)+1;
        elseif gngSel
            gngSampCount(j-2)=gngSampCount(j-2)+1;
        end
    end    
end
for i=2:length(dnmsFstr.Im)
    for j=3:length(sampFstr.Im{i,2})-2
        if all(dnmsFstr.Im{i,2}(j-2:j+2)>0) && all(dnmsFstr.pCrossTime{i,2}(j-2:j+2)<0.01)
            dnmsSampCount(j-2)=dnmsSampCount(j-2)+1;
        end
    end
end

cf=figure('Color','w','Position',[100,100,250,180]);
hold on;
suCount=length(sampFstr.Im);
xPos=[1:length(sampFstr.Im{i,2})]*0.1-1.75-0.1;
fill([xPos(3:end-2),xPos(end-2:-1:3)],[dpaSampCount./suCount,zeros(1,length(sampFstr.Im{1,2})-4)],'r','EdgeColor','none');
fill([xPos(3:end-2),xPos(end-2:-1:3)],[(mixSampCount+dpaSampCount)./suCount,fliplr(dpaSampCount./suCount)],'c','EdgeColor','none');
fill([xPos(3:end-2),xPos(end-2:-1:3)],[(mixSampCount+dpaSampCount+gngSampCount)./suCount,fliplr((dpaSampCount+mixSampCount)./suCount)],'b','EdgeColor','none');
plot(xPos(3:end-2),dnmsSampCount./length(dnmsFstr.Im),'-k','LineWidth',2);

    ylim([0,0.7]);
    set(gca,'XTick',0:5:10);
    xlabel('Time (s)');
    ylabel('Mutual Info (bits)');

    plotTag=@(x) plot([x,x],[-1,1],':k','LineWidth',0.5);

    arrayfun(plotTag,[0 1 3 3.5 4 4.5 9 10]);
    xlim([-1,11]);

    print('-dpng',sprintf('ImDualSamp_Distr_%d.png',i));

return;    
    

    
    
    
    
    
    plot(xPos,sampFstr.Im{i,2},'-r','LineWidth',1);
    plot(xPos,distrFstr.Im{i,2},'-b','LineWidth',1);
    ylim([-0.1,1.2]);
    set(gca,'XTick',0:5:10);
    xlabel('Time (s)');
    ylabel('Mutual Info (bits)');

    plotTag=@(x) plot([x,x],[-1,1],':k','LineWidth',0.5);

    arrayfun(plotTag,[0 1 3 3.5 4 4.5 9 10]);
    plot(xPos(sampFstr.pCrossTime{i,2}<0.01),-0.05,'r.');
    plot(xPos(distrFstr.pCrossTime{i,2}<0.01),-0.075,'b.');
    xlim([-1,11]);

    print('-dpng',sprintf('ImDualSamp_Distr_%d.png',i));
    close(cf);

return;

%%%%%%%%%%%Print significant sample im SUs%%%%%%%%%%%%%%%%
for i=1:length(sampFstr.Im)
    for j=1:length(sampFstr.Im{i,2})-4
        if all(sampFstr.Im{i,2}(j:j+4)>0.1) && all(sampFstr.pCrossTime{i,2}(j:j+4)<0.01)
            fprintf('%d,',i);
            break;
        end
    end
end
