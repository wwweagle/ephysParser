function [sorted,selSide]=plotSelect(data,fileName)


% [sortedGo,sideGo]=plotSelect([selGo;trans13(selGo13)],'GoSelect');
% GoSelect, 15.7100, 35.5500, 38.9900, 29.3200, 17.3600, 20.5700, 35.3600, 23.8700, 18.2100, 21.0000, 16.5400,
% 0.0057, 0.0012, 0.0449, 0.8583, 0.3979, 0.0039, 0.1922, 0.6026, 0.3979, 1.0000,
%
% [sortedNogo,sideNogo]=plotSelect([selNogo;trans13(selNogo13)],'NogoSelect');
% NogoSelect, 11.9400, 26.8500, 33.2900, 32.6000, 17.9700, 17.2600, 30.6100, 18.2600, 15.8700, 17.3600, 10.4500,
% 0.0134, 0.0008, 0.0012, 0.2625, 0.3426, 0.0041, 0.2625, 0.5557, 0.2625, 0.8320,
%
% [sortedNone,sideNone]=plotSelect([selNone;trans13(selNone13)],'NoneSelect');
% NoneSelect, 18.1700, 31.9000, 29.7300, 22.9000, 27.6100, 22.0000, 23.0100, 22.3100, 21.0100, 18.1800, 9.9400,
% 0.0397, 0.0724, 0.4205, 0.1267, 0.5144, 0.4205, 0.5144, 0.6207, 1.0000, 0.1226,


delay=8;
midColor=[0.7,0.9,0.7];
binSize=1;
% binL=size(data,3)/4-2/binSize;
chunkL=size(data,3)/2;
% data(data==0)=realmin;
% h=nan(size(data,1),binL);
% sel=h;
% selec=(data(:,:,6:binL)-data(:,:,(6:binL)+chunkL))./(data(:,:,6:binL)+data(:,:,(6:binL)+chunkL));
data(data==0)=realmin;
baseBin=1:1/binSize;
s1=data(:,:,1/binSize+1:(delay+4)/binSize);
s2=data(:,:,(1/binSize+1:(delay+4)/binSize)+chunkL);
sel=(s1-s2)./(s1+s2);
baseRange=sel(:,:,baseBin);
uBound=mean(baseRange(:))+1.96*std(baseRange(:));
lBound=mean(baseRange(:))-1.96*std(baseRange(:));

% for bin=1:binL
%     for SU=1:size(data,1)
%         [~,p]=ttest(data(SU,:,bin+1/binSize),data(SU,:,bin+1/binSize+chunkL));
%         h(SU,bin)=(~isnan(p)) && p<0.05;
%         sel(SU,bin)=mean(data(SU,:,bin+1/binSize))>mean(data(SU,:,bin+1/binSize+chunkL));
%     end
% end

selSide=zeros(size(sel,1),size(sel,3));
selSide(sel>uBound)=1;
selSide(sel<lBound)=-1;
b1=@bootOne;
bootRepeat=100;
bootMean=nan(bootRepeat,6);


%%%%%%%%%%%%
% segments %
%%%%%%%%%%%%
% col={1,2,3:4,5:6,7:10,11};
% for i=1:6
%     bootMean(:,i)=bootstrp(bootRepeat,b1,selSide,col{i}(1),col{i}(end));
% end
%
% stats=nan(1,5);
% for i=2:6
%     stats(i-1)=ranksum(bootMean(:,1),bootMean(:,i));
% end
%
%
% fprintf('%s, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f\n',fileName,mean(bootMean));
% fprintf('%s, %.3f, %.3f, %.3f, %.3f, %.3f\n',fileName,stats);

% %%%%%%%% %
% each bin %
% %%%%%%%% %
for i=1:delay+3
    bootMean(:,i)=bootstrp(bootRepeat,b1,selSide,i,i);
end
selCol=[repmat('b',size(selSide,1),1);repmat('t',size(selSide,1),1)];

% stats=nan(1,10);
% for i=2:delay+3
%     proportion=abs([selSide(:,1);selSide(:,i)]);
%     [~,~,stats(i-1)]=crosstab(selCol,proportion);
% end

stats=nan(1,10);
for i=2:delay+3
    stats(i-1)=ranksum(bootMean(:,1),bootMean(:,i));
end

save([fileName,'_Stats.txt'],'stats','-ascii');
fprintf('%s, ',fileName);
fprintf('%.4f, ',mean(bootMean));
fprintf('\n');
fprintf('%.4f, ',stats);
fprintf('\n');
fprintf('\n');

mm=mean(bootMean);

save([fileName,'_Stats.txt'],'stats','mm','-ascii');


% h(isnan(h))=0;
f=figure('Position',[100,100,170,260],'Color','w');
% f=figure('Position',[100,100,325,220],'Color','w');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position',[0.14,0.1,0.83,0.25]);
hold on;
stackBar=[sum(selSide==1)'./size(data,1),sum(selSide==-1)'./size(data,1),sum(selSide==0)'/size(data,1)];
% b=bar(stackBar,1,'stacked','EdgeColor','none');
b=bar(stackBar(2/binSize+1:(delay+2)/binSize,:),1,'stacked','EdgeColor','none');
b(1).FaceColor='b';
b(2).FaceColor='r';
b(3).FaceColor=midColor;
% xlim([0,delay+3]/binSize+0.5);
xlim([0,delay]/binSize+0.5);
ylim([0,0.15]);
%  ylim([0,0.5]);
% xy=([1,2,4,5.5,10,11])./binSize+0.5;
xy=([2,2.5,3,3.5])./binSize+0.5;
for i=1:length(xy)
    line([xy(i),xy(i)],ylim(),'LineStyle','-','LineWidth',0.5,'Color','w');
end

[xtick,xticklbl]=getXTick(delay);

% set(gca,'XTick',xtick+0.5,'XTickLabel',xticklbl,'YTick',0:0.05:0.15,'TickDir','in','box','on','FontSize',10,'FontName','Helvetica','LineWidth',0.5);

set(gca,'XTick',xtick+0.5,'XTickLabel',xticklbl,'YTick',0:0.05:0.15,'TickDir','in','box','on','FontSize',10,'FontName','Helvetica','LineWidth',0.5);

% xlabel('Time (s)','FontSize',10,'FontName','Helvetica');
% ylabel('Ratio','FontSize',10,'FontName','Helvetica');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position',[0.14,0.37,0.83,0.62]);
javaaddpath('R:\ZX\java\sortSelectivity\build\classes');
st=sortselectivity.SortSelectivity;
sorted=st.sort(selSide,1/binSize+1,(delay+3)/binSize,false);
cm=[1,0,0;0.79,0.87,0.8;0,0,1];
if size(sorted,1)>300
    %     imagesc(sorted([1:60,end-60:end],:));
    sorted=sorted([1:60,end-60:end],2/binSize+1:(delay+2)/binSize);
    imagesc(sorted);
    set(gca,'XTick',[],'YTick',[25,50,60,300-219,325-219],'YTickLabel',[25,50,0,300,325]);
    xlim([0.5,delay+0.5]);
else
    imagesc(sorted);
    set(gca,'XTick',[]);
end
colormap(cm);
% colormap('jet');

% xy=([1,2,4,5.5,10,11])./binSize+0.5;
xy=([2,2.5,3,3.5])./binSize+0.5;
for i=1:length(xy)
    line([xy(i),xy(i)],ylim(),'LineStyle','-','LineWidth',0.5,'Color','w');
end

% ylabel('Single Unit #','FontSize',10,'FontName','Helvetica');

savefig(f,[fileName,'.fig']);
% pause;




    function [xtick,xlabel]=getXTick(delay)
        %             xtick=(0:10:delay*10+30)/obj.binSize;
        %             xtick=(5:10:delay*10+30)/obj.binSize;
        %               xtick=[0.5,1.5,3,4.75,7.75,10.5]/binSize;
        xtick=[0,5]/binSize;
        switch delay
            case 4
                xlabel={'','0','','','','','5',''};
            case 5
                xlabel={'','0','','','','','','6',''};
            case 8
                %                     xlabel={'','0','','','','','5','','','','','10'};
                %                       xlabel={'B','S','E','D','L','T'};
                xlabel=[0,5];
            case 13
                xlabel={'','0','','','','','5','','','','','10','','','','',''};
        end
    end

    function out=bootOne(data,columnS,columnE)
        out=sum(sum(data(:,columnS:columnE)~=0))/(columnE-columnS+1);
    end

end
% % % 


% GoSelect, 16.2100, 34.9400, 41.0600, 23.4400, 16.4000, 20.0600, 35.5300, 23.9500, 19.6800, 19.5600, 16.0600,
% 0.0186, 0.0005, 0.0706, 0.0330, 0.2100, 0.0021, 0.2202, 0.0805, 0.2544, 0.0172,
%
% NogoSelect, 11.6800, 26.7200, 27.9500, 32.7400, 18.7300, 16.6000, 29.7400, 18.0400, 15.0300, 14.9500, 10.7300,
% 0.0391, 0.0331, 0.0028, 0.5338, 0.0196, 0.0093, 0.5098, 0.0996, 0.3291, 0.9304,
%
% NoneSelect, 17.3800, 32.4000, 32.2900, 24.3600, 27.2400, 21.8600, 22.8400, 22.7500, 21.8900, 17.0000, 10.1900,
% 0.0997, 0.0997, 0.4427, 0.3116, 0.6865, 0.5694, 0.7764, 0.5089, 0.9703, 0.0388,