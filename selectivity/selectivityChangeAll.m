function selectivityChangeAll(none,nogo,go)
binSize=1;
resample=100;
    
    goR=getOne(go);
    nogoR=getOne(nogo);
    noneR=getOne(none);
    
    pEarly=anova1([sum(noneR(:,1:2),2),sum(nogoR(:,1:2),2),sum(goR(:,1:2),2)],[],'off');
    pLate=anova1([sum(noneR(:,3:4),2),sum(nogoR(:,3:4),2),sum(goR(:,3:4),2)],[],'off');
    
    fprintf('pEarly, %f, pLate, %f\n',pEarly,pLate);
    
    f=figure('Color','w','Position',[100,100,170,260]);
    
    subplot('Position',[0.2,0.25,0.7,0.75]);
    hold on;
    barD=[mean(noneR(:,1)),mean(noneR(:,2)),mean(noneR(:,3)),mean(noneR(:,4));
        mean(nogoR(:,1)),mean(nogoR(:,2)),mean(nogoR(:,3)),mean(nogoR(:,4));
        mean(goR(:,1)),mean(goR(:,2)),mean(goR(:,3)),mean(goR(:,4));
        0,0,0,0;
        mean(noneR(:,5)),mean(noneR(:,6)),mean(noneR(:,7)),mean(noneR(:,8));
        mean(nogoR(:,5)),mean(nogoR(:,6)),mean(nogoR(:,7)),mean(nogoR(:,8));
        mean(goR(:,5)),mean(goR(:,6)),mean(goR(:,7)),mean(goR(:,8));
        zeros(10,4)];

    
    
    b=bar(barD(:,1:3),'stacked');
    b(1).FaceColor='k';
    b(2).FaceColor='w';
    b(3).FaceColor='g';
    b(4).FaceColor='b';
%     errorbar(1:size(barD,1),barD(:,1),std([noneR(:,1),nogoR(:,1),goR(:,1),zeros(resample,1),noneR(:,3),nogoR(:,3),goR(:,3),zeros(resample,size(barD,1)-7)])./sqrt(resample),'.k');
%     errorbar(1:size(barD,1),sum(barD,2),std([noneR(:,2),nogoR(:,2),goR(:,2),zeros(resample,1),noneR(:,4),nogoR(:,4),goR(:,4),zeros(resample,size(barD,1)-7)])./sqrt(resample),'.k');
    xlim([0,8]);
%     ylim([0,0.8]);
    set(gca,'XTick',1:7,'XTickLabel',{'No','Nogo','Go','','No','Nogo','Go'},'XTickLabelRotation',45,'FontSize',10,'FontName','Helvetica','YTick',0:0.2:1,'YTickLabel',0:20:100);
    text([2,6],[-0.2,-0.2],{'Early delay','Late delay'},'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
    text([2,6],[0.7,0.7],{['p=',num2str(pEarly)],['p=',num2str(pLate)]},'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
    ylabel('Ratio of selectivity change');
    legend({'out','switch','new','stable'});
    
    savefig(f,'selectivityChange.fig');
    function out=getOne(data)
        b1=@(data,countStart,countStop) bootOne(data,countStart, countStop);
        out=nan(resample,8);
        out(:,1:4)=bootstrp(resample,b1,data,3,4);
        out(:,5:8)=bootstrp(resample,b1,data,6,9);
        
        
%         out=[sum(sum(data(1:100,3:4)==1))/sum(sum(data(1:100,3:4)~=0)),sum(sum(data(101:end,3:4)==-1))/sum(sum(data(101:end,3:4)~=0));
%             sum(sum(data(1:100,6:9)==1))/sum(sum(data(1:100,6:9)~=0)),sum(sum(data(101:end,6:9)==-1))/sum(sum(data(101:end,6:9)~=0))];
       
    end

    function out=bootOne(data,countStart, countStop)
        stable=0;
        outed=0;
        added=0;
        switched=0;
        for i=1:size(data,1)
            for j=(countStart-1)/binSize+1:countStop/binSize
                if data(i,j-1)==data(i,j) % && data(i,j)~=0
                    stable=stable+1;
                elseif data(i,j-1)~=0
                    if data(i,j)==0
                        outed=outed+1;
                    elseif data(i,j)==-data(i,j-1);
                        switched=switched+1;
                    end
                elseif data(i,j-1)==0 && data(i,j)~=0
                    added=added+1;
                end
            end
        end
       out=[outed,switched,added,stable]./sum([outed,switched,added,stable]);
    end
end