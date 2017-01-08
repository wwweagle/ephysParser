function selStack=sel2wayNG()
binSize=0.5;
load('sel2way.mat','binSize','selGoA','selGoB','selNogoA','selNogoB','selGo13A','selGo13B','selNogo13A','selNogo13B');

currSU=0;
for f=1:length(selGoA)
    SUCount=size(selGoA{f},1);
    for SU=1:SUCount
        for bin=1:11/binSize
            sample(SU+currSU,bin)=ranksum([flatten(selGoA{f},SU,bin+1/binSize);flatten(selNogoA{f},SU,bin+1/binSize)],[flatten(selGoB{f},SU,bin+1/binSize);flatten(selNogoB{f},SU,bin+1/binSize)]);
            distractor(SU+currSU,bin)=ranksum([flatten(selGoA{f},SU,bin+1/binSize);flatten(selGoB{f},SU,bin+1/binSize)],[flatten(selNogoA{f},SU,bin+1/binSize);flatten(selNogoB{f},SU,bin+1/binSize)]);
        end
    end
    currSU=currSU+SUCount;
end

currSU=0;
for f=1:length(selGo13A)
    SUCount=size(selGo13A{f},1);
    for SU=1:SUCount
        for bin=1:16/binSize
            s13(SU+currSU,bin)=ranksum([flatten(selGo13A{f},SU,bin+1/binSize);flatten(selNogo13A{f},SU,bin+1/binSize)],[flatten(selGo13B{f},SU,bin+1/binSize);flatten(selNogo13B{f},SU,bin+1/binSize)]);
            d13(SU+currSU,bin)=ranksum([flatten(selGo13A{f},SU,bin+1/binSize);flatten(selGo13B{f},SU,bin+1/binSize)],[flatten(selNogo13A{f},SU,bin+1/binSize);flatten(selNogo13B{f},SU,bin+1/binSize)]);
        end
    end
    currSU=currSU+SUCount;
end


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

s=combine8_13(sample,s13)<0.05;
d=(combine8_13(distractor,d13)<0.05)*2;
sel=double(s);
% sel(sel==2)=0;
% sel=s;
selStack=[sum(sel==1)',sum(sel==3)',sum(sel==2)']./size(sel,1);
figure('Color','w','Position',[100,100,480,200]);
bh=bar(selStack,'stacked');
bh(1).FaceColor='w';
bh(2).FaceColor=[0.8,0.8,0.8];
bh(3).FaceColor='k';
xlim([0,22.5]);
set(gca,'XTick',[2.5,8.5,18.5],'XTickLabel',{'','',''},'YTick',0:0.4:0.8);
legend({'Sample','Mixed','Distractor'});
disp(chi2(mergeBin(sel)));

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

    function out=combine8_13(d8,d13)
        subD13=d13(:,[1:2/binSize,4/binSize+1:13/binSize]);
        out=[d8;subD13];
    end

end