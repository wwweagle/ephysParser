% totalSU=[];
for i=3:length(fs)
    spkFile=load(fs(i));
    if ~isfield(spkFile,'APC')
        continue;
    end
    SPK=unique(spkFile.APC(spkFile.APC(:,2)~=0,1:3),'rows');
%     totalSU=[totalSU;currSU];
    save(strcat(erase(fs(i),'.mat'),'_TS.mat'),'SPK');
    disp(strcat(erase(fs(i),'.mat'),'_TS.mat'));
end