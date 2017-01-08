function loadTxt(root)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if ~ismember(1,cellfun('isempty',strfind(javaclasspath('-dynamic'),'txt2mat')))
    javaaddpath('R:\ZX\Tools\txt2mat.jar');
end
t2m=txt2mat.Txt2Mat;
count=t2m.listAll(root);
for i=0:count-1
    fname=char(t2m.getName(i));
    if ~(exist(fname,'file')==2)
        SPK=t2m.getData(i);
        if numel(SPK)>1000
            fprintf('Saving %s\n',fname);
            save(char(t2m.getName(i)),'SPK');
        else
            fprintf('\nNull return : %s\n',fname);
        end
    else
        fprintf('File exist : %s\n',fname);
    end
end

