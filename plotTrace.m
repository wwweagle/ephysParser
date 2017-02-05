function  ci=plotTrace( Spk,tet,unit )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
traces=Spk(Spk(:,1)==tet & Spk(:,2)==unit,4:end);
tic();
ci=bootci(100,@(x) mean(x),traces);
disp(toc());
len=size(traces,2);
fill([1:len,len:-1:1],[ci(1,:),fliplr(ci(2,:))],[0.8,0.8,0.8],'EdgeColor','none');
hold  on;
plot(mean(traces),'-k','LineWidth',1);

end

