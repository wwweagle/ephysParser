function selectivityChangeUnit(none,nogo,go)
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
    barD=[mean(noneR(:,1)),mean(noneR(:,2));
        mean(nogoR(:,1)),mean(nogoR(:,2));
        mean(goR(:,1)),mean(goR(:,2));
        0,0;
        mean(noneR(:,3)),mean(noneR(:,4));
        mean(nogoR(:,3)),mean(nogoR(:,4));
        mean(goR(:,3)),mean(goR(:,4));
        zeros(10,2)];

    
    
    b=bar(barD,'stacked');
    b(1).FaceColor='k';
    b(2).FaceColor='w';
    errorbar(1:size(barD,1),barD(:,1),std([noneR(:,1),nogoR(:,1),goR(:,1),zeros(resample,1),noneR(:,3),nogoR(:,3),goR(:,3),zeros(resample,size(barD,1)-7)])./sqrt(resample),'.k');
    errorbar(1:size(barD,1),sum(barD,2),std([noneR(:,2),nogoR(:,2),goR(:,2),zeros(resample,1),noneR(:,4),nogoR(:,4),goR(:,4),zeros(resample,size(barD,1)-7)])./sqrt(resample),'.k');
    xlim([0,8]);
    ylim([0,0.8]);
    set(gca,'XTick',1:7,'XTickLabel',{'No','Nogo','Go','','No','Nogo','Go'},'XTickLabelRotation',45,'FontSize',10,'FontName','Helvetica','YTick',0:0.2:0.8,'YTickLabel',0:0.1:0.4);
    text([2,6],[-0.2,-0.2],{'Early delay','Late delay'},'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
    text([2,6],[0.7,0.7],{['p=',num2str(pEarly)],['p=',num2str(pLate)]},'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
    ylabel('Ratio of selectivity change');
    legend({'PF to BN','BN to PF'});
    
    savefig(f,'selectivityChange.fig');
    function out=getOne(data)
        b1=@(data,delayStart,countStart,countStop,startWith) bootOne(data,delayStart,countStart, countStop,startWith);
        out=nan(resample,4);
        out(:,1)=bootstrp(resample,b1,data,2,3,4,1);
        out(:,2)=bootstrp(resample,b1,data,2,3,4,-1);
        out(:,3)=bootstrp(resample,b1,data,2,6,9,1);
        out(:,4)=bootstrp(resample,b1,data,2,6,9,-1);        
%         out=[sum(sum(data(1:100,3:4)==1))/sum(sum(data(1:100,3:4)~=0)),sum(sum(data(101:end,3:4)==-1))/sum(sum(data(101:end,3:4)~=0));
%             sum(sum(data(1:100,6:9)==1))/sum(sum(data(1:100,6:9)~=0)),sum(sum(data(101:end,6:9)==-1))/sum(sum(data(101:end,6:9)~=0))];
       
    end

    function out=bootOne(data,delayStart,countStart, countStop,startWith)
        total=0;
        changed=0;
        for i=1:size(data,1)
            for j=(delayStart-1)/binSize+1:countStop/binSize
                if data(i,j)==startWith
                    total=total+1;
                    for k=max(j+1,(countStart-1)/binSize+1):countStop/binSize
                        if data(i,k)~=0 && data(i,k)~=startWith
                            changed=changed+1;
                            break;
                        end
                    end
                    break;
                else if data(i,j)~=0
                        break;
                    end
                end
            end
        end
        out=changed/total;
    end
end