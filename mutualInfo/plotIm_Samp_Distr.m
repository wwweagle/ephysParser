% plotDualIm
sampFstr=load('ImDualAll8s.mat');
distrFstr=load('Im8sDistr.mat');

for i=1:length(sampFstr.Im)
    cf=figure();
    % fprintf('new figure for %d %d',f,u);
    hold on;
    xPos=[1:length(sampFstr.Im{i,2})]*0.1-1.75-0.1;
%     shufs=bootci(3,@(x) mean(x),imShuf);
%     fill([xPos,fliplr(xPos)],[shufs(1,:),fliplr(shufs(2,:))],'k','FaceAlpha',0.2,'EdgeColor','none');
%     plot(xPos,mean(shufs),'-k','LineWidth',1);

    plot(xPos,sampFstr.Im{i,2},'-r','LineWidth',1);
    plot(xPos,distrFstr.Im{i,2},'-b','LineWidth',1);
    ylim([-0.1,1.2]);
    set(gca,'XTick',0:5:10);
    xlabel('Time (s)');
    ylabel('Mutual Info (bits)');

    plotTag=@(x) plot([x,x],[-1,1],':k','LineWidth',0.5);
%     if contains(inName,'8s','IgnoreCase',true) || contains(outName,'8s','IgnoreCase',true)
        arrayfun(plotTag,[0 1 3 3.5 4 4.5 9 10]);
%     else
%         arrayfun(plotTag,[0 1 5 6]);
%     end
    plot(xPos(sampFstr.pCrossTime{i,2}<0.01),-0.05,'r.');
    plot(xPos(distrFstr.pCrossTime{i,2}<0.01),-0.075,'b.');
    xlim([-1,11]);
%     savefig(cf,[fnameTag,num2str(f*1000+u),'.fig'],'compact');
    print('-dpng',sprintf('ImDualSamp_Distr_%d.png',i));
    close(cf);
end