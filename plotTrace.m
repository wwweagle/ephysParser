function  ci=plotTrace( Spk,tet,unit )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
figure('Color','w','Position',[1000,1000,150,50]);
traces=Spk(Spk(:,1)==tet & Spk(:,2)==unit,4:end);
% tic();
% ci=bootci(2,@(x) mean(x),traces);
% disp(toc());
ciData=nan(1000,216);
parfor i=1:1000
    ciData(i,:)=mean(datasample(traces,length(traces),1))
end
ci(1,:)=prctile(ciData,2.5);
ci(2,:)=prctile(ciData,97.5);

len=size(traces,2);
fill([1:len,len:-1:1],[ci(1,:),fliplr(ci(2,:))],[0.8,0.8,0.8],'EdgeColor','none');
hold  on;
plot(mean(traces),'-k','LineWidth',1);

end

