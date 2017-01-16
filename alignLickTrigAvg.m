function [p,fr]=alignLickTrigAvg(keyIdx,lickTrigAvg)

suIdx=1;
p=[];
fr=[];
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
            for m=1:licks
                if ~isempty(lickTrigAvg{j,3}{l,1})
                    concated=[concated,lickTrigAvg{j,3}{l,1}{m,1}];
                    bf=[bf;sum(lickTrigAvg{j,3}{l,1}{m,1}>-0.25 & lickTrigAvg{j,3}{l,1}{m,1}<0)];
                    aft=[aft;sum(lickTrigAvg{j,3}{l,1}{m,1}>0 & lickTrigAvg{j,3}{l,1}{m,1}<0.25)];
                else
                    bf=[bf;0];
                    aft=[aft;0];
                end
            end
            p=[p;ranksum(bf,aft)];
            fr=[fr;(histcounts(concated,100))./licks/0.02];
    end
end
end