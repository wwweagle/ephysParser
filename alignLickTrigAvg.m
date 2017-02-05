function [p,fr,frz]=alignLickTrigAvg(keyIdx,lickTrigAvg,windowCenter)

suIdx=1;
% windowCenter=0;
p=[];
fr=[];
frz=[];
for i=1:size(keyIdx,1)
    fname=strtrim(keyIdx{i,1});
    equf=-1;
    for j=1:size(lickTrigAvg,1)
        if fname==strtrim(lickTrigAvg{j,1})
            equf=j;
            break;
        end
    end
    if equf<0
        break;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%
    %%%  File is found   %%%
    %%%%%%%%%%%%%%%%%%%%%%%%
    for k=1:size(keyIdx{i,2},1)
        tet=keyIdx{i,2}(k,:);
        equsu=-1;
        for l=1:size(lickTrigAvg{j,2})
            if isequal(tet, lickTrigAvg{j,2}(l,:))
                equsu=l;
                break;
            end
        end
        if equsu<0
            break;
        end
        %%%%%%%%%%%%%%%%%%%
        %%% su is found %%%
        %%%%%%%%%%%%%%%%%%%
%         befLick=lickTrigAvg{j,3}(l,:,1);
%         aftLick=lickTrigAvg{j,3}(l,:,2);
%         if isequal(sort(befLick),sort(aftLick))
%             p=[p;1,size(befLick,2),sum(befLick,2),sum(aftLick,2)];
%         else
%             p=[p;ranksum(double(befLick),double(aftLick)),size(befLick,2),sum(befLick,2),sum(aftLick,2)];
%         end


            licks=size(lickTrigAvg{j,3}{l,1},1);
            concated=[];
            bf=[];
            aft=[];
            base=[];
            if strcmpi('r',windowCenter)
                for m=1:licks
                    windowCenter=rand-0.5;
                    if ~isempty(lickTrigAvg{j,3}{l,1})
                        concated=[concated,lickTrigAvg{j,3}{l,1}{m,1}];
                        bf=[bf;sum(lickTrigAvg{j,3}{l,1}{m,1}>=(-0.25+windowCenter) & lickTrigAvg{j,3}{l,1}{m,1}<windowCenter)];
                        aft=[aft;sum(lickTrigAvg{j,3}{l,1}{m,1}>=windowCenter & lickTrigAvg{j,3}{l,1}{m,1}<(0.25+windowCenter))];
                        base=[base;length(lickTrigAvg{j,3}{l,1}{m,1})/2];%sum(lickTrigAvg{j,3}{l,1}{m,1}<0)];
                    else
                        bf=[bf;0];
                        aft=[aft;0];
                        base=[base;0];
                    end
                end
            else
                for m=1:licks
                    if ~isempty(lickTrigAvg{j,3}{l,1})
                        concated=[concated,lickTrigAvg{j,3}{l,1}{m,1}];
                        bf=[bf;sum(lickTrigAvg{j,3}{l,1}{m,1}>=(-0.25+windowCenter) & lickTrigAvg{j,3}{l,1}{m,1}<windowCenter)];
                        aft=[aft;sum(lickTrigAvg{j,3}{l,1}{m,1}>=windowCenter & lickTrigAvg{j,3}{l,1}{m,1}<(0.25+windowCenter))];
                        base=[base;length(lickTrigAvg{j,3}{l,1}{m,1})/2];%sum(lickTrigAvg{j,3}{l,1}{m,1}<0)];
                    else
                        bf=[bf;0];
                        aft=[aft;0];
                        base=[base;0];
                    end
                end
            end
            p=[p;ranksum(bf,aft),licks,sum(bf),sum(aft)];
            fr=[fr;(histcounts(concated,102))./licks/0.02];
            mm=mean(base);
            ss=std(base);
%             disp(ss);
            if(mm==0 && ss==0)
                frz=[frz;ones(1,size(fr,2))*65535];
            else
                frz=[frz;(fr(end,:)-mean(base))./std(base)];
            end
    end
end

% lateMean=mean(frz(:,size(frz,2)/2+1:end),2);
% [~,sIdx]=sort(lateMean);
% frz=frz(sIdx,:);
% frz=frz';
% for i=1:size(frz,2)
%     frz(:,i)=smooth(frz(:,i));
% end
% frz=frz';
% frz(frz>2.9 & frz<1000)=2.9;
% cmap=colormap('jet');
% cmap(end,:)=[1,1,1];
% imagesc(frz(1:125,:),[-3 3]);
% colormap(cmap);
% set(gca,'Ytick',[0,50,100,120],'YTickLabel',[0,50,100,350],'XTick',[0,50,100],'XTickLabel',[-1,0,1],'TickDir','out');

figure('Color','w','Position',[100,100,350,80]);
% fr=fr';
% for i=1:size(fr,2)
%     fr(:,i)=smooth(fr(:,i));
% end
% fr=fr';
% plot(fr','Color',[0.8 0.8 0.8])
fr=fr(:,2:end-1);
shuf=fr(:,randperm(size(fr,2)));
hold on
% sem=std(fr)./size(fr,1);
ci=bootci(100,@(x) mean(x),fr);
ciShuf=bootci(100,@(x) mean(x),shuf);
bootShuf=bootstrp(10000,@(x) mean(x),fr);
bootP=nan(1,10);
for i=1:10
    sM=mean(mean(bootShuf(i*10-9:i*10)));
    dM=abs(mean(mean(fr(:,i*10-9:i*10)))-sM);
    bootP(i)=sum(abs(mean(bootShuf(:,i*10-9:i*10),2)-sM)>=dM)./10000;
end
disp('BootP');
disp(bootP);


fill([1:size(fr,2),size(fr,2):-1:1],[ciShuf(2,:),fliplr(ciShuf(1,:))],[0.8,0.8,0.8],'EdgeColor','none');
fill([1:size(fr,2),size(fr,2):-1:1],[ci(2,:),fliplr(ci(1,:))],[1,0.8,0.8],'EdgeColor','none');
ph=plot(mean(fr)','-r','LineWidth',1);
sh=plot(mean(shuf)','-k','LineWidth',1);
% line([45,45],[0,4],'LineStyle',':','Color','k','LineWidth',1);
% line([55,55],[0,4],'LineStyle',':','Color','k','LineWidth',1);
% line([45,55],[4,4],'LineStyle',':','Color','k','LineWidth',1);
% line([45,55],[0,0],'LineStyle',':','Color','k','LineWidth',1);
set(gca,'XTick',[0:10:100],'XTickLabel',[-1:0.1:1],'TickDir','in','box','off');
xlim([0,100])
legend([ph,sh],{'Average firing rate','Shuffle'},'box','off');

% figure('Color','w','Position',[100,100,100,140]);
% fill([1:21,21:-1:1],[mean(fr(:,40:60))-sem(40:60),fliplr(mean(fr(:,40:60))+sem(40:60))],[0.8,0.8,0.8],'EdgeColor','none');
% plot(mean(fr(:,40:60))','-r','LineWidth',1);
% ylim([0,4]);
% xlim([1,21]);
% set(gca,'XTick',5:5:15,'XTickLabel',-0.1:0.1:0.1,'box','off');


end