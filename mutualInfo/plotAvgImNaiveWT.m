load('im5sDNMSNaiveMI.mat', 'Im')
im5mat=cell2mat(Im(:,2));
shuf5mat=cell2mat(cellfun(@(x) mean(x),imShufAll,'UniformOutput',false));
% shuf5mat=cell2mat(cellfun(@(x) x(1,:),imShufAll,'UniformOutput',false));
% % Im5s=Im;
load('im8sDNMS.mat')
im8mat=cell2mat(Im(:,2));



figure('Color','w','Position',[100,100,220,220]);
hold on;
ci5s=bootci(1000,@(x) mean(x),im5mat);
ci8s=bootci(1000,@(x) mean(x),im8mat);
ciShuf=bootci(1000,@(x) mean(x),shuf5mat);
plotIdx=12:100;

fill([plotIdx,fliplr(plotIdx)],[ci5s(1,plotIdx),fliplr(ci5s(2,plotIdx))],[1,0.8,0.8],'EdgeColor','none');
fill([plotIdx,fliplr(plotIdx)],[ci8s(1,plotIdx),fliplr(ci8s(2,plotIdx))],[0.8,0.8,1],'EdgeColor','none');
fill([plotIdx,fliplr(plotIdx)],[ciShuf(1,plotIdx),fliplr(ciShuf(2,plotIdx))],[0.8,0.8,0.8],'EdgeColor','none');
plot(plotIdx,mean(im8mat(:,plotIdx)),'-b','LineWidth',1);
plot(plotIdx,mean(im5mat(:,plotIdx)),'-r','LineWidth',1)
plot(plotIdx,mean(shuf5mat(:,plotIdx)),'-k','LineWidth',1)
arrayfun(@(x) plot([x,x],[0,0.15],':k'),[20,30,80,90]);
xlim([11,100]);
ylim([0,0.13]);
set(gca,'XTick',20:50:100,'XTickLabel',0:5:10);
xlabel('Time (s)');
ylabel('Average MI');

p=nan(2,max(plotIdx));
for i=plotIdx
    p(1,i)=permTest(im8mat(:,i),shuf5mat(:,i));
    p(2,i)=permTest(im5mat(:,i),shuf5mat(:,i));
end

for i=plotIdx(1:end-1)
   if max(p(1,i:i+1))<0.001
       plot([i,i+1],[0.004,0.004],'b-','LineWidth',1);
   end
   if max(p(2,i:i+1))<0.001
       plot([i,i+1],[0.002,0.002],'r-','LineWidth',1);
   end
end



function prob=permTest(A,B)
rpt=1000;
currD=mean(A(:))-mean(B(:));
permMat=nan(1,rpt);
for i=1:rpt
    pool=[A(:);B(:)];
    pool=pool(randperm(numel(pool)));
    newA=pool(1:numel(A));
    newB=pool(numel(A)+1:numel(pool));
    newD=mean(newA(:))-mean(newB(:));
    if (abs(newD)>=abs(currD))
        permMat(i)=1;
    else
        permMat(i)=0;
    end
end
prob=mean(permMat);

end
