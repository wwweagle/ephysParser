function [out,center]=countPie(in,t)
for i=1:6
    out(i)=sum(in(:,t)==i);
end
out=out+(sum(in(:,t)==i))./6;
center=(sum(in(:,t)==i));