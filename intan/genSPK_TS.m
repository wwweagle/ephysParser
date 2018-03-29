% totalSU=[];
fss=dir('R:\zx\apc\intan\**\*SPK.mat');
fs=string(arrayfun(@(x) [fss(x).folder,'\',fss(x).name],1:length(fss),'UniformOutput',false));

for i=1:length(fs)
    if exist(strcat(erase(fs(i),'.mat'),'_TS.mat'),'file') 
        continue;
    end
    spkFile=load(fs(i));
    if ~isfield(spkFile,'APC')
        continue;
    end
    SPK=spkFile.APC(spkFile.APC(:,2)~=0,1:3);
%     totalSU=[totalSU;currSU];
    save(strcat(erase(fs(i),'.mat'),'_TS.mat'),'SPK');
    disp(strcat(erase(fs(i),'.mat'),'_TS.mat'));
end