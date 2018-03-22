function plotImDist()
delayLen=4;
windows={'late'};
% windows={'sample8','delay8','early8','late8'};
for w=1:length(windows)
    tic;
    [Im,ImShuf,sel,selShuf]=plotIm(windows{w},4);
    close all;
%     fh=plotOne(Im,ImShuf,true);
%     savefig(fh,[windows{w},'_Im.fig']);
    fh=plotOne(sel,selShuf,false);
    savefig(fh,[windows{w},'_',num2str(delayLen),'_sel.fig']);
    fprintf('Time cost, %0.3f\n',toc());
end
end

function fh=plotOne(d,dShuf,isIm)
if isIm
    xpos=0.025:0.05:1;
    histR=0:0.05:1;
    xR=[0,1];
    xlbl='Mutual Information';
else
    xpos=-0.95:0.1:1;
    histR=-1:0.1:1;
    xR=[-1,1];
    xlbl='Selectivity';
end
fh=figure('Color','w','Position',[100,100,330,250]);
hold on;
histD=histcounts(d,histR)./length(d);

bh=plot(xpos,histD,'ko','MarkerFaceColor','k');

toCell=@(x) mat2cell(x,size(x,1),ones(size(x,2),1));

shufHist=cell2mat(cellfun(@(x) histcounts(x,histR)./length(d),toCell(dShuf),'UniformOutput',false)');
dCI=bootci(100,@(x) mean(x,1),shufHist);
errorbar(xpos,mean(shufHist),dCI(1,:),dCI(2,:),'or','LineWidth',1);

p=sum(abs(shufHist-mean(shufHist))>=abs(histD-mean(shufHist)))./size(shufHist,1).*size(histD,2);
for i=1:length(xpos)
    if p(i)<0.05
        text(xpos(i),0.8-mod(i,2)*0.5,p2Str(p(i)),'HorizontalAlignment','center');
        text(xpos(i),1-mod(i,2)*0.5,sprintf('%.3f',p(i)),'HorizontalAlignment','center');
    end
end
    
set(gca,'YScale','log');
xlim(xR);
xlabel(xlbl);
ylabel('Ratio of neurons');

end