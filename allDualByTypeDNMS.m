function [out,sequence]= allDualByTypeDNMS(type, classify,binStart,binSize,binEnd,isS1,is8s) %type='odor' or 'correct' ; SampleSize=[PFSampleSize1,PFSampleSize2;BNSampleSize1,BNSampleSize2];
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    function genData
        selA=allDualByTypeDNMS('odor','Average2Hz',-2,0.5,9,true,false);
        selB=allDualByTypeDNMS('odor','Average2Hz',-2,0.5,9,false,false);
        selMatchA=allDualByTypeDNMS('match','Average2Hz',-2,0.5,9,true,false);
        selMatchB=allDualByTypeDNMS('match','Average2Hz',-2,0.5,9,false,false);
        selTestA=allDualByTypeDNMS('test','Average2Hz',-2,0.5,9,true,false);
        selTestB=allDualByTypeDNMS('test','Average2Hz',-2,0.5,9,false,false);
    end


path(path,'r:\ZX\Tools\Matlab Offline Files SDK\')
dp=javaclasspath('-dynamic');
if ~ismember('R:\ZX\java\spk2fr\build\classes',dp)
    javaaddpath('R:\ZX\java\spk2fr\build\classes');
    javaaddpath('R:\ZX\java\spk2fr\lib\commons-math3-3.5.jar');
    javaaddpath('R:\ZX\java\spk2fr\lib\jmatio.jar');
    javaaddpath('R:\ZX\java\DualEvtParser\build\classes');
    disp('added');
end

% if exist('onlyWellTrain','var')
%     para=spk2fr.MatPara(onlyWellTrain,0.0015);
% else
%     para=spk2fr.MatPara(2,0.0015);
% end

para=spk2fr.MatPara(1,0.0015);
clear dp;


para.setFormat('WJAllFR');


fl=listF();
if exist('is8s','var') && is8s
    fileList=fl.listDNMS8s();
else
    fileList=fl.listDNMS4s();
end
fuIdx=1;

for fidx=1:size(fileList,1)
    futures(fuIdx)=para.parGetAllFR(fileList(fidx,:),classify, type,binStart,binSize,binEnd,isS1);
    fuIdx=fuIdx+1;
end
h=waitbar(0,'0');
out=cell(length(futures),1);
for fidx=1:length(futures)
    tmp=futures(fidx).get();
    if numel(tmp)>0
        out{fidx}=tmp;
    end
    waitbar(fidx/length(futures),h,[num2str(fidx),'/',num2str(length(futures))]);
end

fprintf('\n');
delete(h);


end
