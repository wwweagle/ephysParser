function [selStack,p,smp]=sel2wayDNMS(delay,subgrp,displayOff,bonf)
binSize=0.5;
if ~exist('bonf','var')
    bonf=1;
end


switch delay
    case 8
        load('sel2wayDNMS8s.mat');
        dashes=[2,4,20,22,24,25];
    case 4
        load('sel2wayDNMS4s.mat');
        dashes=[2,4,12,14,16,17];
    case 5
        load('sel2wayDNMS5s.mat');
        dashes=[2,4,14,16,18,19];
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
        dashes=[12,14,16,17];
        delay=4;
    case -12
        f4=load('sel2wayDNMS4sL.mat');
        f8=load('sel2wayDNMS8sL.mat');
        selA=[f4.selA;f8.selA];
        selB=[f4.selB;f8.selB];
        selMatchA=[f4.selMatchA;f8.selMatchA];
        selMatchB=[f4.selMatchB;f8.selMatchB];
        selTestA=[f4.selTestA;f8.selTestA];
        selTestB=[f4.selTestB;f8.selTestB];
        selLickA=[f4.selLickA;f8.selLickA];
        selLickB=[f4.selLickB;f8.selLickB];
        dashes=[12,14,16,17];
        delay=4;
end

currSU=0;
for f=1:length(selA)
    SUCount=size(selA{f},1);
    for SU=1:SUCount
        for bin=1:(delay+8)/binSize
%             fprintf('%d, %d, %d, %d\n',f,SU,SUCount,bin);
            sample(SU+currSU,bin)=ranksum(flattenTrans(selA{f},SU,bin+1/binSize),flattenTrans(selB{f},SU,bin+1/binSize));
%             match(SU+currSU,bin)=ranksum(flattenTrans(selMatchA{f},SU,bin+1/binSize),flattenTrans(selMatchB{f},SU,bin+1/binSize));
            test(SU+currSU,bin)=ranksum(flattenTrans(selTestA{f},SU,bin+1/binSize),flattenTrans(selTestB{f},SU,bin+1/binSize));
            lick(SU+currSU,bin)=ranksum(flattenTrans(selLickA{f},SU,bin+1/binSize),flattenTrans(selLickB{f},SU,bin+1/binSize));
        end
    end
    currSU=currSU+SUCount;
end
% currSU=0;
% for f=1:length(selMatchAError)
%     SUCount=size(selMatchAError{f},1);
%     for SU=1:SUCount
%         for bin=1:(12)/binSize
%             matchError(SU+currSU,bin)=ranksum(flatten(selMatchAError{f},SU,bin+1/binSize),flatten(selMatchBError{f},SU,bin+1/binSize));
%         end
%     end
%     currSU=currSU+SUCount;
% end
% currSU=0;
% for f=1:length(selMatchAError)
%     SUCount=size(selMatchAError{f},1);
%     for SU=1:SUCount
%         for bin=1:(delay+8)/binSize
%             match2baseNm(SU+currSU,bin)=ranksum(flattenMerge(selMatchAError{f},SU,bin+1/binSize),flattenMerge(selMatchAError{f},SU,11+1/binSize));
%             match2baseMa(SU+currSU,bin)=ranksum(flattenMerge(selMatchBError{f},SU,bin+1/binSize),flattenMerge(selMatchBError{f},SU,11+1/binSize));
%         end
%     end
%     currSU=currSU+SUCount;
% end



% s=combine8_13(sample,s13)<0.05;
% d=(combine8_13(distractor,d13)<0.05)*2;
if exist('subgrp','var') && ~isempty(subgrp)
    smp=double(sample(subgrp,:)<0.05);
    tst=(double(test(subgrp,:))<0.05)*2;
    mch=(double(match(subgrp,:))<0.05)*4;
else
    smp=double(sample<0.05);
    tst=(double(test)<0.05)*2;
%     mch=(double(match)<0.05)*4;
    lck=(double(lick)<0.05)*4;

end
smp=smp+tst+lck;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

selStack=[sum(smp==1)',sum(smp==2)',sum(smp==3)',sum(smp==4)',sum(smp==5)',sum(smp==6)',sum(smp==7)']./size(smp,1);
% selStack=[sum(mch==4)'./size(mch,1)];
if exist('displayOff','var')  && displayOff
    figure('Color','w','Position',[100,100,350,250],'Visible','off');
else
    figure('Color','w','Position',[100,100,350,250]);
end
subplot('Position',[0.15,0.15,0.8,0.55]);
hold on;
plotData=(lck>=4);
plotData2=(smp==4);

bootmean=bootstrp(100,@(x) sum(x)./size(x,1),plotData);
bootmean2=bootstrp(100,@(x) sum(x)./size(x,1),plotData2);

% ci=bootci(100,@(x) sum(x)./size(plotData,1),plotData);
% ci2=bootci(100,@(x) sum(x)./size(plotData,1),plotData2);
% fill([binSize/2:binSize:size(plotData2,2)*binSize,size(plotData2,2)*binSize-binSize/2:-binSize:0],[ci2(1,:),fliplr(ci2(2,:))],[0.8,0.8,0.8],'EdgeColor','none')
% fill([binSize/2:binSize:size(plotData,2)*binSize,size(plotData,2)*binSize-binSize/2:-binSize:0],[ci(1,:),fliplr(ci(2,:))],[0.8,0.8,0.8],'EdgeColor','none')
for i=1:size(bootmean,2)
    bias=rand(100,1)*0.8-0.4;
    plot((i+bias-0.5)*binSize,bootmean(:,i),'Marker','o','LineStyle','none','MarkerFaceColor',[0.8,0.8,0.8],'MarkerEdgeColor','none','MarkerSize',2);
    bias2=rand(100,1)*0.8-0.4;
    plot((i+bias2-0.5)*binSize,bootmean2(:,i),'Marker','o','LineStyle','none','MarkerFaceColor',[1,0.8,0.8],'MarkerEdgeColor','none','MarkerSize',2);
    
end
plot(binSize/2:binSize:size(plotData,2)*binSize,sum(plotData)./size(plotData,1),'k-','LineWidth',1);
plot(binSize/2:binSize:size(plotData2,2)*binSize,sum(plotData2)./size(plotData2,1),'r-','LineWidth',1);
xlim([0,(delay+6)/binSize+0.5].*binSize);
% ylim([0,0.8]);
yspan=ylim();

line(repmat(dashes,2,1).*binSize,repmat([yspan(1);1],1,length(dashes)),'LineStyle',':','Color','k','LineWidth',1);
box off;
set(gca,'XTick',[2,12,22].*binSize,'XTickLabel',[0,5,10],'TickDir','out','XMinorTick','on');%,'YTick',0:0.4:0.8);
xlabel('Time (s)');
% ylim(yspan);
% legend({'Sample','Test','Sample & Test','Match - NonMatch','Sample & Match','Test & Match','Sample, Test & Match'});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% chisq %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p=chi2base(smp >4 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    function out=mergeBin(in)
        out=reshape(in,[],size(in,2)/(1/binSize));
    end

    function out=chi2(in1,in2)
        out=nan(1,size(in1,2));
%         NN=size(in,1);
        binTemplate=[ones(size(in1,1),1);ones(size(in2,1),1)*2];
        for i=1:size(in1,2)
%             [~,~,out(i-1)]=bn(binTemplate,[in(:,1)==1 | in(:,1)==3;in(:,i)==1 | in(:,1)==3]);
            [~,~,out(i)]=crosstab(binTemplate,[in1(:,i)==0;in2(:,i)==0]);
        end
    end



   function out=chi2base(in)
       t=mergeBin(in);
        out=nan(1,size(t,2)-1);
        for j=2:size(t,2)
            binTemplate=[ones(size(t,1),1);ones(size(t,1),1)*2];
            [~,chi2,out(j)]=crosstab(binTemplate,[t(:,1)==1;t(:,j)==1]);
            out(j)=out(j).*bonf;
            fprintf('selective neurons\tchoice %ds\tChi-square, Bonferroni correction adjusted\t\t%d\tnumber of neurons\t\t\t\tp = %.2e\t\tChiSq(%d) = %.3f\n',j-2,size(binTemplate,1)./4,out(j),1,chi2);
        end
    end

    function out=flatten(data,SU,bin)
        if iscell(data)
            out=shiftdim(data{SU}(:,bin));
        else
            out=shiftdim(data(SU,:,bin));
        end
    end

    function out=flattenTrans(data,SU,bin)
        if iscell(data)
            if size(data{SU},2)>28 && bin>6 && delay==4
                out=shiftdim(data{SU}(:,bin+8));
            else
                out=shiftdim(data{SU}(:,bin+8));
            end
        else
            if sum(~isnan(data(SU,1,:)))>28 && bin>6 && delay==4
                out=shiftdim(data(SU,:,bin+8));
            else
                out=shiftdim(data(SU,:,bin));
            end
            
        end
    end



    function out=flattenMerge(data,SU,bin)
        if mod(bin,1/binSize)==1
            if iscell(data)
                out=sum(shiftdim(data{SU}(:,bin:bin+(1/binSize-1))),2);
            else
                out=sum(shiftdim(data(SU,:,bin:bin+(1/binSize-1))),2);
            end
        else
            if iscell(data)
                out=zeros(size(shiftdim(data{SU}(:,bin))));
            else
                out=zeros(size(shiftdim(data(SU,:,bin))));
            end
        end
    end
    


    function out=combine8_13(d8,d13)
        subD13=d13(:,[1:2/binSize,4/binSize+1:13/binSize]);
        out=[d8;subD13];
    end

end

