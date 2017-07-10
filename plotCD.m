function barData=plotCD (sGoCD,sNogoCD,sNoneCD,late)
% path(path,'R:\ZX\APC\Script1608');
binSize=1;
delay=size(sGoCD,3)/6*binSize-5;
% sGoCD=sampleDualByType('distrGo','Average2HzWhole',-2,0.2,11,[1,0;1,0],96,1);
% sNogoCD=sampleDualByType('distrNoGo','Average2HzWhole',-2,0.2,11,[1,0;1,0],96,1);
% sNoneCD=sampleDualByType('distrNone','Average2HzWhole',-2,0.2,11,[1,0;1,0],96,1);


GoCD=genCD(sGoCD);
NogoCD=genCD(sNogoCD);
NoneCD=genCD(sNoneCD);
CD=(GoCD+NogoCD+NoneCD)./3;


goTraj=genProj(CD,sGoCD);
nogoTraj=genProj(CD,sNogoCD);
noneTraj=genProj(CD,sNoneCD);

saveBar(goTraj,nogoTraj,noneTraj);

figure('Position',[100,100,260,250],'Color','w');
subplot('Position',[0.15,0.15,0.8,0.55]);
hold on;

[fg,f1,f2]=plotOne(goTraj,'Go distractor','GoCDP',1);
[fng,~,~]=plotOne(nogoTraj,'No-go distractor','NogoCDP',2);
[fn,~,~]=plotOne(noneTraj,'No distractor','NoneCDP',0);
xlim([2,10])

legend([fn,fng,fg,f1,f2],{'PF-BN/None','PF-BN/Nogo','PF-BN/Go','PF-PF/None','BN-BN/None'},'box','off','FontSize',10,'FontName','Helvetica');

    function proj=genProj(CD,sample)
        proj=nan((delay+3)/binSize,size(CD,2),3);
        pEnd=delay+4;
        for rpt=1:size(CD,2)
            CDrpt=CD(:,rpt);
            toProj=permute(sample(:,rpt,:),[1 3 2]);
            proj(:,rpt,1)=(CDrpt'*toProj(:,[(1/binSize)+1:(pEnd/binSize)]+size(sample,3)/6)-CDrpt'*toProj(:,[(1/binSize)+1:(pEnd/binSize)]+size(sample,3)/6*4))';%PF-BN
            proj(:,rpt,2)=(CDrpt'*toProj(:,[(1/binSize)+1:(pEnd/binSize)]+size(sample,3)/6)-CDrpt'*toProj(:,[(1/binSize)+1:(pEnd/binSize)]+size(sample,3)/6*2))';%PF-PF
            proj(:,rpt,3)=(CDrpt'*toProj(:,[(1/binSize)+1:(pEnd/binSize)]+size(sample,3)/6*5)-CDrpt'*toProj(:,[(1/binSize)+1:(pEnd/binSize)]+size(sample,3)/6*4))';%BN-BN
        end
    end

    function CD=genCD(CDin)
        if late
            start=delay-1;
        else
            start=2;
        end
        PFBin=((start/binSize)+1):((delay+3)/binSize);
        BNBin=PFBin+size(CDin,3)/2;
        CD=mean(CDin(:,:,PFBin)-CDin(:,:,BNBin),3);
    end

    function [f,f1,f2]=plotOne(traj,fTitle,fileName,pType)
        m=@(mat) mean(mat);
        epfbn=bootci(100,m,shiftdim(traj(:,:,1),1));
        epfbn=[epfbn(1,:),fliplr(epfbn(2,:))];
        epfpf=bootci(100,m,shiftdim(traj(:,:,2),1));
        epfpf=[epfpf(1,:),fliplr(epfpf(2,:))];
        ebnbn=bootci(100,m,shiftdim(traj(:,:,3),1));
        ebnbn=[ebnbn(1,:),fliplr(ebnbn(2,:))];
        width=size(traj,1);
        
        fill([1:width,width:-1:1]-0.5*binSize,epfbn,[1,0.8,0.8],'EdgeColor','none');
        if pType==0
            fill([1:width,width:-1:1]-0.5*binSize,epfpf,[0.8,0.8,0.8],'EdgeColor','none');
            fill([1:width,width:-1:1]-0.5*binSize,ebnbn,[0.8,0.8,1],'EdgeColor','none');
        end
        pStyle={'-r','--r',':r'};
        f=plot((1:width)-0.5*binSize,mean(traj(:,:,1),2),pStyle{pType+1},'LineWidth',1);
        f1=f;
        f2=f;
        if pType==0
            f1=plot((1:width)-0.5*binSize,mean(traj(:,:,2),2),'-k','LineWidth',1);
            f2=plot((1:width)-0.5*binSize,mean(traj(:,:,3),2),'-b','LineWidth',1);
        end
        xlim([0,(delay+3)/binSize]);
        ylim([-50,250]);
        yspan=ylim();
        plotOdorEdge(delay);
        [xtick,xticklbl]=getXTick(delay);
        set(gca,'XTick',xtick,'XTickLabel',xticklbl,'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
        
        grpTag={'None Dtr','Nogo Dtr','Go Dtr'};
        fprintf('%s ANOVA1 p = %04f \n',grpTag{pType+1},...
            anova1([reshape(traj(:,:,1),numel(traj(:,:,1)),1), ...
            reshape(traj(:,:,2),numel(traj(:,:,2)),1), ...
            reshape(traj(:,:,3),numel(traj(:,:,3)),1)],[],'off'));
%         pause;
%         for i=1:delay+3
%             p=anova1([reshape(traj((i-1)/binSize+1:i/binSize,:,1),numel(traj((i-1)/binSize+1:i/binSize,:,1)),1),...
%                 reshape(traj((i-1)/binSize+1:i/binSize,:,2),numel(traj((i-1)/binSize+1:i/binSize,:,2)),1),...
%                 reshape(traj((i-1)/binSize+1:i/binSize,:,3),numel(traj((i-1)/binSize+1:i/binSize,:,3)),1)],[],'off');
%             text((i-0.5)/binSize,yspan(1)+diff(yspan)*0.06,p2Str(p),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
%         end
        
%         xlabel('Time (s)','FontSize',10,'FontName','Helvetica');
%         ylabel('C.D. projection (a.u.)','FontSize',10,'FontName','Helvetica');
%         legend([hpfbn,hpfpf,hbnbn],{'PF-BN','PF-PF','BN-BN'},'box','off','FontSize',10,'FontName','Helvetica');
%         text(3/binSize,yspan(2)-diff(yspan)*0.05,['n=',num2str(size(sGoCD,1))],'HorizontalAlignment','center','VerticalAlignment','top','FontSize',10,'FontName','Helvetica');
%         title(fTitle,'FontSize',12,'FontName','Helvetica');
        
%         towrite=questdlg('Save File ?','Save File');
%         if strcmpi(towrite,'yes');
%             set(gcf,'PaperPositionMode','auto');
%             if late
%                 fileName=[fileName,'LateCD'];
%             end
%             savefig([fileName,'.fig']);
%         end
        
    end


    function saveBar(goTraj,nogoTraj,noneTraj)
%         data=nan(3,3);
%         data(:,1)=1:3;
%         meanData=[mean(noneTraj(8/binSize+1:10/binSize,:,1))',mean(nogoTraj(8/binSize+1:10/binSize,:,1))',mean(goTraj(8/binSize+1:10/binSize,:,1))'];
%         disp(anova1(meanData,[],'off'));
%         data(:,2)=mean(meanData);
%         data(:,3)=std(meanData)./sqrt(size(meanData,1));
%         save('CDPBar.txt','data','-ascii')

        data=nan(size(goTraj,2),6);
        data(:,[1 3 5])=[mean(noneTraj(6/binSize+1:10/binSize,:,1))',mean(nogoTraj(6/binSize+1:10/binSize,:,1))',mean(goTraj(6/binSize+1:10/binSize,:,1))'];
        data(:,[2 4 6])=[mean(sNoneCD(:,:,end))',mean(sNogoCD(:,:,end))',mean(sGoCD(:,:,end))'];
%         disp(anova1(meanData,[],'off'));
%         data(:,2)=mean(meanData);
%         data(:,3)=std(meanData)./sqrt(size(meanData,1));
        save('CDPBar.txt','data','-ascii')
        barData=data;


%         pause;
        
    end


        function plotOdorEdge(delay)
            yspan=ylim();
            if delay==8
                xx=[1,2,4,5.5,10,11]./binSize;
            elseif delay==13
                xx=[1,2,6,7.5,15,16]./binSize;
            end
            for curX=1:length(xx)
                line([xx(curX),xx(curX)],yspan,'LineStyle','-','LineWidth',0.5,'Color',[0.75,0.75,0.75]);
            end
        end
    
    
    function [xtick,xlabel]=getXTick(delay)
%             xtick=(0:10:delay*10+30)/obj.binSize;
%             xtick=(5:10:delay*10+30)/obj.binSize;
%               xtick=[0.5,1.5,3,4.75,7.75,10.5]/binSize;
                xtick=[2,6,10]./binSize;
            switch delay
                case 4
                    xlabel={'','0','','','','','5',''};
                case 5
                    xlabel={'','0','','','','','','6',''};
                case 8
%                     xlabel={'','0','','','','','5','','','','','10'};
%                       xlabel={'B','S','E','D','L','T'};
                        xlabel=([0,4,8]);
                case 13
                    xlabel={'','0','','','','','5','','','','','10','','','','',''};
            end
        end  
end

