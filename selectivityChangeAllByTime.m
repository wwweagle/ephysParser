function barD=selectivityChangeAllByTime(data,fileName)
binSize=1;
resample=1;
%     
%     goR=getOne(go);
%     nogoR=getOne(nogo);
%     noneR=getOne(none);
%     
%     pEarly=anova1([sum(noneR(:,1:2),2),sum(nogoR(:,1:2),2),sum(goR(:,1:2),2)],[],'off');
%     pLate=anova1([sum(noneR(:,3:4),2),sum(nogoR(:,3:4),2),sum(goR(:,3:4),2)],[],'off');
%     
%     fprintf('pEarly, %f, pLate, %f\n',pEarly,pLate);
%     
%     f=figure('Color','w','Position',[100,100,170,260]);
%     
%     subplot('Position',[0.2,0.25,0.7,0.75]);
%     hold on;
%     barD=[mean(noneR(:,1)),mean(noneR(:,2)),mean(noneR(:,3)),mean(noneR(:,4));
%         mean(nogoR(:,1)),mean(nogoR(:,2)),mean(nogoR(:,3)),mean(nogoR(:,4));
%         mean(goR(:,1)),mean(goR(:,2)),mean(goR(:,3)),mean(goR(:,4));
%         0,0,0,0;
%         mean(noneR(:,5)),mean(noneR(:,6)),mean(noneR(:,7)),mean(noneR(:,8));
%         mean(nogoR(:,5)),mean(nogoR(:,6)),mean(nogoR(:,7)),mean(nogoR(:,8));
%         mean(goR(:,5)),mean(goR(:,6)),mean(goR(:,7)),mean(goR(:,8));
%         zeros(10,4)];
% 
%     
%     
%     b=bar(barD(:,1:3),'stacked');
%     b(1).FaceColor='k';
%     b(2).FaceColor='w';
%     b(3).FaceColor='g';
%     b(4).FaceColor='b';
% %     errorbar(1:size(barD,1),barD(:,1),std([noneR(:,1),nogoR(:,1),goR(:,1),zeros(resample,1),noneR(:,3),nogoR(:,3),goR(:,3),zeros(resample,size(barD,1)-7)])./sqrt(resample),'.k');
% %     errorbar(1:size(barD,1),sum(barD,2),std([noneR(:,2),nogoR(:,2),goR(:,2),zeros(resample,1),noneR(:,4),nogoR(:,4),goR(:,4),zeros(resample,size(barD,1)-7)])./sqrt(resample),'.k');
%     xlim([0,8]);
% %     ylim([0,0.8]);
%     set(gca,'XTick',1:7,'XTickLabel',{'No','Nogo','Go','','No','Nogo','Go'},'XTickLabelRotation',45,'FontSize',10,'FontName','Helvetica','YTick',0:0.2:1,'YTickLabel',0:20:100);
%     text([2,6],[-0.2,-0.2],{'Early delay','Late delay'},'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
%     text([2,6],[0.7,0.7],{['p=',num2str(pEarly)],['p=',num2str(pLate)]},'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
%     ylabel('Ratio of selectivity change');
%     legend({'out','switch','new','stable'});
%     
%     savefig(f,'selectivityChange.fig');
% %     function out=getOne(data)
% %         b1=@(data,countStart,countStop) bootOne(data,countStart, countStop);
% %         out=nan(resample,8);
% %         out(:,1:4)=bootstrp(resample,b1,data,3,4);
% % 
% %         
% %         
% % %         out=[sum(sum(data(1:100,3:4)==1))/sum(sum(data(1:100,3:4)~=0)),sum(sum(data(101:end,3:4)==-1))/sum(sum(data(101:end,3:4)~=0));
% % %             sum(sum(data(1:100,6:9)==1))/sum(sum(data(1:100,6:9)~=0)),sum(sum(data(101:end,6:9)==-1))/sum(sum(data(101:end,6:9)~=0))];
% %        
% %     end
% 
f=figure('Color','w','Position',[100 100 355 160]);
hold on;
barD=nan(size(data,2),resample,5);
bootfun=@(data,col) stackOne(data,col);
for k=1:size(data,2)
    barD(k,:,:)=bootstrp(resample,bootfun,data,k);
end

b=bar(permute(mean(barD(:,:,[4 3 2]),2),[1 3 2])./size(data,1),1,'stacked','EdgeColor','none');
b(1).FaceColor=[0,1,3]/5;
b(2).FaceColor=[3,0,1]/5;
b(3).FaceColor=[1,3,0]/5;
bar(-permute(mean(barD(:,:,1),2),[1 3 2])./size(data,1),1,'FaceColor','k','EdgeColor','none');
% legend({'Stable selectivity','Aquired selectivity','Switched selectivity','Lost selectivity'});

% xy=([1,2,4,5.5,10,11])./binSize+0.5;
xy=([1,2,10,11])./binSize+0.5;
for i=1:length(xy)
    line([xy(i),xy(i)],ylim(),'LineStyle','-','LineWidth',0.5,'Color','w');
end

[xtick,xticklbl]=getXTick(8);
xlim([0.5,11.5]);
ylim([-0.2,0.7]);
set(gca,'XTick',1.5:3:11.5,'XTickLabel',0:3:12,'YTick',-0.5:0.2:0.5,'TickDir','in','box','on','FontSize',10,'FontName','Helvetica','LineWidth',0.5,'box','off');
ylabel('Ratio of selective units');
pause();
savefig(f,[fileName,'_SelectivityVSTime.fig']);

    function [xtick,xlabel]=getXTick(delay)
%             xtick=(0:10:delay*10+30)/obj.binSize;
%             xtick=(5:10:delay*10+30)/obj.binSize;
              xtick=[0.5,1.5,3,4.75,7.75,10.5]/binSize;
            switch delay
                case 4
                    xlabel={'','0','','','','','5',''};
                case 5
                    xlabel={'','0','','','','','','6',''};
                case 8
%                     xlabel={'','0','','','','','5','','','','','10'};
                      xlabel={'B','S','E','D','L','T'};
                case 13
                    xlabel={'','0','','','','','5','','','','','10','','','','',''};
            end
    end 


    function out=stackOne(data,col)

        
        stableSel=0;
        stableNonSel=0;
        losted=0;
        added=0;
        switched=0;
        if col==1
            added=sum(sum(data(:,col)~=0));
            out=[losted,switched,added,stableSel,stableNonSel];
            return;
        end
        for i=1:size(data,1)
            if data(i,col-1)==data(i,col)
                if  data(i,col)~=0
                    stableSel=stableSel+1;
                else
                    stableNonSel=stableNonSel+1;
                end
            elseif data(i,col)==0
                losted=losted+1;
            elseif data(i,col)==-data(i,col-1)
                switched=switched+1;
            else
                added=added+1;
            end
        end
       out=[losted,switched,added,stableSel,stableNonSel];
    end
end