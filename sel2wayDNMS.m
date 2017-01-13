function selStack=sel2wayDNMS(delay)
binSize=0.5;
switch delay
    case 8
        load('sel2wayDNMS8s.mat');
        dashes=[2.5,4.5,20.5,22.5,24.5,25.5];
    case 4
        load('sel2wayDNMS8s.mat');
        dashes=[2.5,4.5,12.5,14.5,16.5,17.5];
end

currSU=0;
for f=1:length(selA)
    SUCount=size(selA{f},1);
    for SU=1:SUCount
        for bin=1:(delay+5)/binSize
            sample(SU+currSU,bin)=ranksum(flatten(selA{f},SU,bin+1/binSize),flatten(selB{f},SU,bin+1/binSize));
            match(SU+currSU,bin)=ranksum(flatten(selMatchA{f},SU,bin+1/binSize),flatten(selMatchB{f},SU,bin+1/binSize));
            test(SU+currSU,bin)=ranksum(flatten(selTestA{f},SU,bin+1/binSize),flatten(selTestB{f},SU,bin+1/binSize));
        end
    end
    currSU=currSU+SUCount;
end

% currSU=0;
% for f=1:length(selGo13A)
%     SUCount=size(selGo13A{f},1);
%     for SU=1:SUCount
%         for bin=1:16/binSize
%             s13(SU+currSU,bin)=ranksum([flatten(selGo13A{f},SU,bin+1/binSize);flatten(selNogo13A{f},SU,bin+1/binSize)],[flatten(selGo13B{f},SU,bin+1/binSize);flatten(selNogo13B{f},SU,bin+1/binSize)]);
%             d13(SU+currSU,bin)=ranksum([flatten(selGo13A{f},SU,bin+1/binSize);flatten(selGo13B{f},SU,bin+1/binSize)],[flatten(selNogo13A{f},SU,bin+1/binSize);flatten(selNogo13B{f},SU,bin+1/binSize)]);
%         end
%     end
%     currSU=currSU+SUCount;
% end


%     figure();
%     sSel=(sample<0.05);
%     dSel=(distractor<0.05)*2;
%     sel8=sSel+dSel;
%     selStack=[sum(sel8==1)',sum(sel8==3)',sum(sel8==2)']./size(sSel,1);
%     bar(selStack,'stacked');
% 
%     figure();
%     sSel13=(s13<0.05);
%     dSel13=(d13<0.05)*2;
%     sel13=sSel13+dSel13;
%     selStack=[sum(sel13==1)',sum(sel13==3)',sum(sel13==2)']./size(sSel,1);
%     bar(selStack,'stacked');

% s=combine8_13(sample,s13)<0.05;
% d=(combine8_13(distractor,d13)<0.05)*2;
smp=double(sample<0.05);
tst=(double(test)<0.05)*2;
mch=(double(match)<0.05)*4;

% smp=smp+tst;
% selStack=[sum(sel==1)',sum(sel==3)',sum(sel==2)']./size(sel,1);
selStack=[sum(smp==1)]./size(smp,1);
% selStack=[sum(smp==1)',sum(smp==2)',sum(smp==3)',sum(smp==4)',sum(smp==5)',sum(smp==6)',sum(smp==7)']./size(smp,1);
figure('Color','w','Position',[100,100,350,250]);
subplot('Position',[0.15,0.15,0.8,0.55]);
bh=bar(selStack,'stacked');
% ph=plot(selStack,'LineWidth',2);
% bh(1).FaceColor='w';
% bh(2).FaceColor=[0.8,0.8,0.8];
bh(1).FaceColor='k';
% xlim([0,(delay+5)/binSize+0.5]);
xlim([0,(delay+3)/binSize+0.5]);
% set(gca,'XTick',[2.5,4.5,12.5,14.5,16.5,17.5],'TickDir','out','XTickLabel',[]);%,'YTick',0:0.4:0.8);
yspan=ylim();
line(repmat(dashes,2,1),repmat(yspan()',1,length(dashes)),'LineStyle',':','Color','k');
box off;
set(gca,'XTick',[2.5,12.5,22.5],'XTickLabel',[0,5,10],'TickDir','out');%,'YTick',0:0.4:0.8);
xlabel('Time (s)');
ylim(yspan);
% legend({'Sample','Mixed','Match/Non-match'});
% legend({'Sample'});
% legend({'Sample','Test','Sample & Test','Match - NonMatch','Sample & Match','Test & Match','Sample, Test & Match'});
disp(chi2(mergeBin(smp)));

    function out=mergeBin(in)
%         out=nan(size(in,1),size(in,2)/(1/binSize));
%         n=1/binSize;
%         for i=1:n:size(in,2)
%             out(:,(i+1)/2)=sum(in(:,[i,i+1]),2);
%         end
out=reshape(in,[],size(in,2)/(1/binSize));
    end

    function out=chi2(in)
        out=nan(1,size(in,2)-1);
        NN=size(in,1);
        binTemplate=[ones(NN,1);ones(NN,1)*2];
        for i=2:size(in,2)
%             [~,~,out(i-1)]=crosstab(binTemplate,[in(:,1)==1 | in(:,1)==3;in(:,i)==1 | in(:,1)==3]);
            [~,~,out(i-1)]=crosstab(binTemplate,[in(:,1);in(:,i)]);
        end
    end

    function out=flatten(data,SU,bin)
        if iscell(data)
            out=shiftdim(data{SU}(:,bin));
        else
            out=shiftdim(data(SU,:,bin));
        end
        
    end

%     function out=combine8_13(d8,d13)
%         subD13=d13(:,[1:2/binSize,4/binSize+1:13/binSize]);
%         out=[d8;subD13];
%     end

end