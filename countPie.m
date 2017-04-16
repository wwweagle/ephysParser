function out=countPie(in,t)

out=nan(1,8);
target=[1,3,2,6,4,5,7];

for i=1:7
    out(i)=sum(in(:,t)==target(i));
end

out(8)=sum(in(:,t)==0);
label=cell(1,8);
for i=1:8
    label{i}=sprintf('%.1f%%',out(i)*100/size(in,1));
end
out(out==0)=0.00001;

figure('Color','w','Position',[100,100,170,170]);
ph=pie(out,label);

c={'r','k','y','k','g','k','c','k','b','k','m','k','w','k',[0.2,0.2,0.2],'k'};

for i=1:2:length(ph)
    ph(i).FaceColor=c{i};
    ph(i).EdgeColor='none';
end

ph(13).EdgeColor='k';


for i=2:2:length(ph)
    ph(i).FontName='Helvetica';
    ph(i).FontSize=10;
end

ph(13).EdgeColor='k';

savefig(gcf,['Pie',num2str(t),'.fig']);
convertFigs(['Pie',num2str(t)]);

end