function [performance,false]=perf
missThres=10;
fl=listF();
fileList=fl.listTrialF();
fileList=[fileList;fl.listTrialFWJ];
performance=nan(size(fileList,1),3);
false=nan(size(fileList,1),3);
for fidx=1:size(fileList,1)
    ft=load(fileList{fidx},'EVT');
    EVT=ft.EVT;
    for i=1:size(EVT,1)-missThres
        if sum(EVT(i:i+missThres,7))==0
            EVT=EVT(1:i,:);
            break;
        end
    end
    performance(fidx,:)=[getTypePerf(EVT,0),getTypePerf(EVT,2),getTypePerf(EVT,1)].*100;
    false(fidx,:)=[getTypeFalse(EVT,0),getTypeFalse(EVT,2),getTypeFalse(EVT,1)].*100;
end

perfD=nan(3,4);
perfD(:,1)=1:3;
perfD(:,2)=nanmean(performance,1);
perfD(:,3)=(nanstd(performance))./sqrt(sum(~isnan(performance)));
perfD(:,4)=[anova1(performance,[],'off'),NaN,NaN];
save('perfData.txt','perfD','-ascii')


falseD=nan(3,3);
falseD(:,1)=1:3;
falseD(:,2)=nanmean(false,1);
falseD(:,3)=(nanstd(false))./sqrt(sum(~isnan(false)));
falseD(:,4)=[anova1(false,[],'off'),NaN,NaN];
save('falseData.txt','falseD','-ascii')

% figure('Position',[100 100 300 400],'Color','w');
% hold on;
% fcolor=[1,1,1;0.75,0.75,0.75;0,0,0];
% 
% for i=1:3
%     h(i)=bar(i,nanmean(out(:,i)),'FaceColor',fcolor(i,:),'EdgeColor','k','lineWidth',1);
% end
% errorbar(1:9,[nanmean(out(:,1)),nanmean(out(:,2)),nanmean(out(:,3)),4:9],...
%     [nanstd(out(:,1))/sqrt(sum(~isnan(out(:,1)))), nanstd(out(:,2))/sqrt(sum(~isnan(out(:,2)))),nanstd(out(:,3))/sqrt(sum(~isnan(out(:,3)))),4:9],'.k','LineWidth',1);
% xlim([0,3.8]);
% ylim([0.6,0.95]);
%     


    function typePerf=getTypePerf(evt,type)
        selected=evt(evt(:,3)==type,:);
        correct=sum([selected(:,1)==selected(:,5) & selected(:,7)==0;selected(:,1)~=selected(:,5) & selected(:,7)==1]);
        if size(selected,1)>5
            typePerf=correct./size(selected,1);
        else
            typePerf=NaN;
        end
    end


    function typeFalse=getTypeFalse(evt,type)
        selected=evt(evt(:,3)==type & evt(:,1)==evt(:,5),:);
        ff=sum(selected(:,7)==1);
        if size(selected,1)>5
            typeFalse=ff./size(selected,1);
        else
            typeFalse=NaN;
        end
    end

end