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
            p=[p;ranksum(bf,aft),licks,sum(bf),sum(aft)];
            fr=[fr;(histcounts(concated,100))./licks/0.02];
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

lateMean=mean(frz(:,size(frz,2)/2+1:end),2);
[~,sIdx]=sort(lateMean);
frz=frz(sIdx,:);
frz=frz';
for i=1:size(frz,2)
    frz(:,i)=smooth(frz(:,i));
end
frz=frz';
frz(frz>2.9 & frz<1000)=2.9;
cmap=colormap('jet');
cmap(end,:)=[1,1,1];
imagesc(frz(1:125,:),[-3 3]);
colormap(cmap);
set(gca,'Ytick',[0,50,100,120],'YTickLabel',[0,50,100,350],'XTick',[0,50,100],'XTickLabel',[-1,0,1],'TickDir','out');
set(gcf,'Color','w','Position',[100,100,320,140]);



end