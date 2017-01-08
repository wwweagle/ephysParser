function barDynamic(none,go,nogo,dnms)

dataset={dnms,none,go,nogo};

booted=nan(8*size(go,2),4);
stats=nan(2,10);
for grp=1:4
    booted(:,grp)=calcOne(dataset{grp});
    stats(2,grp*2+1)=mean(booted(:,grp));
    stats(2,grp*2+2)=std(booted(:,grp))/sqrt(size(booted(:,grp),1));
end

stats(2,2)=anova1(booted,[],'off');
save('dyn_stats.txt','stats','-ascii');

    function out=calcOne(data)
        out=reshape(sum(data(3:10,:,2:3),3),size(data,2)*8,1)./reshape(sum(data(3:10,:,2:4),3),size(data,2)*8,1);
    end
        
end