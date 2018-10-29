delayLen=8;
welltrainOnly=true;
[spkCA,tagA]=allByTypeDNMS('sample','Average2Hz',-2,0.1,delayLen+7,true,delayLen,delayLen~=5);
[spkCB,tagB]=allByTypeDNMS('sample','Average2Hz',-2,0.1,delayLen+7,false,delayLen,delayLen~=5);


if (~all(strcmp(tagA(:,1),tagB(:,1)))) || ~isequal(tagA(:,2),tagB(:,2))
    return;
end

alpha=0.05;

binCount=size(spkCA{1},3);
parfor winIdx=1:binCount-1
    mWindow=winIdx:winIdx+1;
    sig{winIdx}=arrayfun(@(x) permTAll(spkCA{x},spkCB{x},mWindow),1:length(spkCA),'UniformOutput',false);
end
ci=cellfun(@(x) bootci(1000,@(y) mean(y<alpha),cell2mat(x)),sig,'UniformOutput',false);
figure('Color','w','Position',[100,100,315,210]);
hold on;
fill([1:length(ci),length(ci):-1:1],[cellfun(@(x) max(x),ci),fliplr(cellfun(@(x) min(x),ci))],[1,0.8,0.8],'EdgeColor','none');
mm=cellfun(@(x) mean(cell2mat(x)<alpha),sig);
plot(mm,'-r','LineWidth',1);
arrayfun(@(x) plot([x,x],[0,1],':k','LineWidth',1),([0,1,delayLen+1,delayLen+2]*10+20));
nSU=sum(cellfun(@(x) numel(x),sig{11}));
for i=21:10:delayLen*10+41
    X1=[zeros(8*nSU,1);ones(10*nSU,1)];
    X2=[cell2mat(arrayfun(@(y) cell2mat(cellfun(@(x) (x<0.05),sig{y},'UniformOutput',false)),1:8,'UniformOutput',false)),...
        cell2mat(arrayfun(@(y) cell2mat(cellfun(@(x) (x<0.05),sig{y},'UniformOutput',false)),i:i+9,'UniformOutput',false))];
    [~,~,p]=crosstab(X1,X2);
    text(i+4,0.025,p2str(p.*11),'HorizontalAlignment','center','FontSize',10);%bonferrini
end

ax=gca;
ax.XTick=[0,5,10]*10+20+0.5;
ax.XTickLabel=[0 5 10];
ax.FontSize=10;



xlabel('Time (s)');
ylabel('Fraction of selective neurons');
xlim([11,50+delayLen*10]);
ylim([0,0.6])
print('-depsc','-painters','-r0',sprintf('sel_fraction_%d.eps',delayLen));

function out=permTAll(A,B,window)
out=nan(1,size(A,1));
flat=@(x) x(:);
for i=1:size(A,1)
    if all(flat(A(i,:,window))==0) && all(flat(B(i,:,window))==0)
        out(i)=1;
    else
        out(i)=permTest(flat(A(i,:,window)),flat(B(i,:,window)));
    end
end
end



function out=permTest(A,B)
    currDelta=abs(mean(A(:))-mean(B(:)));
    permed=nan(1,1000);
    for i=1:1000
        [AA,BB]=permSample(A,B);
        permed(i)=abs(mean(AA)-mean(BB));
    end
    out=mean(permed>=currDelta);
end

function [newA,newB]=permSample(A,B)
pool=[A(:);B(:)];
pool=pool(randperm(length(pool)));
newA=pool(1:numel(A));
newB=pool((numel(A)+1):end);
end

function out=p2str(p)
if p<0.001
    out='***';
elseif p<0.01
    out='**';
elseif p<0.05
    out='*';
else
    out='N.S.';
end
end

