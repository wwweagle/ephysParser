    function plotOne(delayBoot,movedBoot,sampleBoot,shuffleBoot,fname)
    
        figure('Color','w','Position',[100,100,330,225]);
        hold on;
        len=size(delayBoot,1);
        
        fillOne(delayBoot,'r');
%         fillOne(movedBoot,'k');
%         fillOne(sampleBoot,'b');
        fillOne(shuffleBoot,'k');

        
        dh=plot(mean(delayBoot,2),'-r');
%         mh=plot(mean(movedBoot,2),'-k');
%         sh=plot(mean(sampleBoot,2),'-b');
        fh=plot(mean(shuffleBoot,2),'-k');
        
%         bootRange=1:size(delayBoot,2)/2;
%         if measure>3
%             bootRange=bootRange + size(delayBoot,2)/2;
%         end
            
%         p=nan(4,len);
        p=nan(1,len);
        for i=1:len
%             p(1,i)=genChi2P(delayBoot(i,:),movedBoot(i,:));
            p(i)=genChi2P(delayBoot(i,:),shuffleBoot(i,:)).*len;
%             p(3,i)=genChi2P(movedBoot(i,:),shuffleBoot(i,:));
%             p(4,i)=genChi2P(sampleBoot(i,:),shuffleBoot(i,:));
              text(i,1,p2Str(p(i),'short'),'FontSize',10,'HorizontalAlignment','center')
        end
        save([fname,'_p.txt'],'p','-ascii');
%         legend([dh,mh,sh],{'Averaged delay','Moving window','Averaged sample'},'FontSize',10);
        
        set(gca,'XTick',0:len/10:len,'XTickLabel',0:10:100,'FontSize',12,'YTick',[0.5,1]);
        xlim([0,len+1]);
        ylim([0.4,1]);
        xlabel('% neurons (highest Im last)','FontSize',12);
        ylabel('Decoding accuracy','FontSize',12);
        savefig([fname,'.fig']);
        set(gcf,'PaperPositionMode','auto');
        print('-painters','-depsc',[fname,'.eps']);
        
        
        
        function p=genChi2P(A, B)
            aa=[zeros(size(A)),ones(size(B))];
            bb=[A,B];
            [~,~,p]=crosstab(aa,bb);
        end
    
        function fillOne(X,color)
            ci=bootci(500,@(x) mean(x),X');
            fill([1:len,len:-1:1],[ci(1,:),fliplr(ci(2,:))],color,'EdgeColor','none','FaceAlpha',0.15);
        end
    end