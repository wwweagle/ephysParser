function [selStack,p,smp]=sel2wayDNMS(delay,subgrp,displayOff)
binSize=0.5;
switch delay
%     case 8
%         load('sel2wayDNMS8s.mat');
%         dashes=[2.5,4.5,20.5,22.5,24.5,25.5];
%     case 4
%         load('sel2wayDNMS4s.mat');
%         dashes=[2.5,4.5,12.5,14.5,16.5,17.5];
    case 5
        load('sel2wayDNMS5s.mat');
        dashes=[2.5,4.5,14.5,16.5,18.5,19.5];
    case 12
        f4=load('sel2wayDNMS4s.mat');
        f8=load('sel2wayDNMS8s.mat');
        selA=[f4.selA;f8.selA];
        selB=[f4.selB;f8.selB];
        selMatchA=[f4.selMatchA;f8.selMatchA];
        selMatchB=[f4.selMatchB;f8.selMatchB];
        selTestA=[f4.selTestA;f8.selTestA];
        selTestB=[f4.selTestB;f8.selTestB];
        selMatchAError=[f4.selMatchAError;f8.selMatchAError];
        selMatchBError=[f4.selMatchBError;f8.selMatchBError];
        dashes=[12.5,14.5,16.5,17.5];
        delay=4;
end

currSU=0;
for f=1:length(selA)
    SUCount=size(selA{f},1);
    for SU=1:SUCount
        for bin=1:(delay+8)/binSize
%             fprintf('%d, %d, %d, %d\n',f,SU,SUCount,bin);
            sample(SU+currSU,bin)=ranksum(flatten(selA{f},SU,bin+1/binSize),flatten(selB{f},SU,bin+1/binSize));
            match(SU+currSU,bin)=ranksum(flatten(selMatchA{f},SU,bin+1/binSize),flatten(selMatchB{f},SU,bin+1/binSize));
            test(SU+currSU,bin)=ranksum(flatten(selTestA{f},SU,bin+1/binSize),flatten(selTestB{f},SU,bin+1/binSize));
        end
    end
    currSU=currSU+SUCount;
end
currSU=0;
for f=1:length(selMatchAError)
    SUCount=size(selMatchAError{f},1);
    for SU=1:SUCount
        for bin=1:(12)/binSize
            matchError(SU+currSU,bin)=ranksum(flatten(selMatchAError{f},SU,bin+1/binSize),flatten(selMatchBError{f},SU,bin+1/binSize));
        end
    end
    currSU=currSU+SUCount;
    
end



% s=combine8_13(sample,s13)<0.05;
% d=(combine8_13(distractor,d13)<0.05)*2;
if exist('subgrp','var') && ~isempty(subgrp)
    smp=double(sample(subgrp,:)<0.05);
    tst=(double(test(subgrp,:))<0.05)*2;
    mch=(double(match(subgrp,:))<0.05)*4;
else
    smp=double(sample<0.05);
    tst=(double(test)<0.05)*2;
    mch=(double(match)<0.05)*4;
    mchE=(double(matchError)<0.05)*8;
end
smp=smp+tst+mch;
% selStack=[sum(sel==1)',sum(sel==3)',sum(sel==2)']./size(sel,1);
% selStack=[sum(smp==1)]./size(smp,1);
selStack=[sum(smp==1)',sum(smp==2)',sum(smp==3)',sum(smp==4)',sum(smp==5)',sum(smp==6)',sum(smp==7)']./size(smp,1);
% selStack=[sum(mch==4)'./size(mch,1)];
if exist('displayOff','var')  && displayOff
    figure('Color','w','Position',[100,100,350,250],'Visible','off');
else
    figure('Color','w','Position',[100,100,350,250]);
end
subplot('Position',[0.15,0.15,0.8,0.55]);
bh=bar(selStack,'stacked');
colors={[0,1,1],...
    [1,0,1],...
    [0,0,1],...
    [1,1,0],...
    [0,1,0],...
    [1,0,0],...
    [0,0,0]};
for i=1:7
    bh(i).FaceColor=colors{i};
end


% bh=bar(selStack,1,'hist');

% ph=plot(selStack,'LineWidth',2);
% bh(1).FaceColor='k';
% bh(2).FaceColor='w';
% bh(1).FaceColor='k';
% xlim([0,(delay+5)/binSize+0.5]);
xlim([0,(delay+6)/binSize+0.5]);
% set(gca,'XTick',[2.5,4.5,12.5,14.5,16.5,17.5],'TickDir','out','XTickLabel',[]);%,'YTick',0:0.4:0.8);
ylim([0,0.8]);
yspan=ylim();

line(repmat(dashes,2,1),repmat(yspan()',1,length(dashes)),'LineStyle',':','Color','k');
box off;
set(gca,'XTick',[2.5,12.5,22.5],'XTickLabel',[0,5,10],'TickDir','out');%,'YTick',0:0.4:0.8);
xlabel('Time (s)');
ylim(yspan);
% legend({'Sample','Mixed','Match/Non-match'});
% legend({'Sample'});
legend({'Sample','Test','Sample & Test','Match - NonMatch','Sample & Match','Test & Match','Sample, Test & Match'});
% legend({'Correct trials','Incorrect trials'});
% p=chi2(mergeBin(mch),mergeBin(mchE));
p=chi2base(mch==4);
% disp(p);

    function out=mergeBin(in)
        out=reshape(in,[],size(in,2)/(1/binSize));
    end

    function out=chi2(in1,in2)
        out=nan(1,size(in1,2));
%         NN=size(in,1);
        binTemplate=[ones(size(in1,1),1);ones(size(in2,1),1)*2];
        for i=1:size(in1,2)
%             [~,~,out(i-1)]=crosstab(binTemplate,[in(:,1)==1 | in(:,1)==3;in(:,i)==1 | in(:,1)==3]);
            [~,~,out(i)]=crosstab(binTemplate,[in1(:,i)==0;in2(:,i)==0]);
        end
    end



   function out=chi2base(in)
       t=mergeBin(in);
        out=nan(1,size(t,2)-1);
        for i=2:size(t,2)
            binTemplate=[ones(size(t,1),1);ones(size(t,1),1)*2];
            [~,~,out(i)]=crosstab(binTemplate,[t(:,1)==1;t(:,i)==1]);
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

