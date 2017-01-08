function [out,sequence]= sampleDualByType(type,classify,binStart,binSize,binEnd,sampleSize,repeats,onlyWellTrain,WJ) %type='odor' or 'correct' ; SampleSize=[PFSampleSize1,PFSampleSize2;BNSampleSize1,BNSampleSize2];
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
path(path,'r:\ZX\Tools\Matlab Offline Files SDK\')
dp=javaclasspath('-dynamic');
if ~ismember('R:\ZX\java\spk2fr\build\classes',dp)
    javaaddpath('R:\ZX\java\spk2fr\build\classes');
    javaaddpath('R:\ZX\java\spk2fr\lib\commons-math3-3.5.jar');
    javaaddpath('R:\ZX\java\spk2fr\lib\jmatio.jar');
    javaaddpath('R:\ZX\java\DualEvtParser\build\classes');
    disp('added');
end

if exist('onlyWellTrain','var')
    para=spk2fr.MatPara(onlyWellTrain,0.0015);
else
    para=spk2fr.MatPara(2,0.0015);
end

clear dp;


para.setFormat('Dual');

out=[];
fl=listF();
if exist('WJ','var') && strcmp(WJ,'WJ')
    fileList=fl.listTrialFWJ();
else
    fileList=fl.listTrialF();
end
fuIdx=1;

for fidx=1:size(fileList,1)
    futures(fuIdx)=para.parGetSampleFR(fileList{fidx},classify, type,binStart,binSize,binEnd,sampleSize,repeats);
    fuIdx=fuIdx+1;
end
h=waitbar(0,'0');
for fidx=1:length(futures)
    tmp=futures(fidx).get();
    if numel(tmp)>0
        out=[out;tmp];
    end
    waitbar(fidx/length(futures),h,[num2str(fidx),'/',num2str(length(futures))]);
end

fprintf('\n');
delete(h);


end
