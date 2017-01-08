function f=listOpSupp()
all=ls();
f=[];
for i=3:size(all,1)
    if exist(strtrim(all(i,:)),'file')==7
        cd(strtrim(all(i,:)));
        ft=ls('*OpGenSession.mat');
        ft=[repmat([pwd(),'\'],size(ft,1),1),ft];
        f=strvcat(f,ft);
        cd('..');
    end
end