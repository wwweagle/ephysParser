function [out,sequence] = allMutiEveryTrialDNMS(type, classify,binStart,binSize,binEnd,isS1,delayLen,welltrained) %SampleSize=[PFSampleSize1,PFSampleSize2;BNSampleSize1,BNSampleSize2];
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%     function genData
%         selA=allByTypeDNMS('sample','Average2Hz',-2,0.5,12,true,false);
%         selB=allByTypeDNMS('sample','Average2Hz',-2,0.5,12,false,false);
%         selMatchA=allByTypeDNMS('match','Average2Hz',-2,0.5,12,true,false);
%         selMatchB=allByTypeDNMS('match','Average2Hz',-2,0.5,12,false,false);
%         selTestA=allByTypeDNMS('test','Average2Hz',-2,0.5,12,true,false);
%         selTestB=allByTypeDNMS('test','Average2Hz',-2,0.5,12,false,false);
%            
%         [selMatchAError,seqA]=allByTypeDNMS('matchError','Average2Hz',-2,0.5,12,true,false);
%         [selMatchBError,seqB]=allByTypeDNMS('matchError','Average2Hz',-2,0.5,12,false,false);
%         inA=ismember(cell2mat(seqB(:,1)),cell2mat(seqA(:,1)),'rows');
%         selMatchBError=selMatchBError(inA,:);
%     end


seqIdx=1;
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

para=spk2fr.MatPara(welltrained,0.0015);% 1, welltrained only, 0, non-well trained only, 2, all
clear dp;


para.setFormat('WJAllFR');


fl=listF();
if exist('delayLen','var') && ismember(delayLen,[4,5,8])
    switch delayLen
        case 8
            fileList=fl.listDNMS8s();
        case 5
            fileList=fl.listDNMSNaive5s();
        otherwise
        fileList=fl.listDNMS4s();
    end
end
fuIdx=1;

if size(fileList,1)>0
    for fidx=1:size(fileList,1)
        futures(fuIdx)=para.parGetAllFR(fileList(fidx,:),classify, type,binStart,binSize,binEnd,isS1);
        fuIdx=fuIdx+1;
    end
    h=waitbar(0,'0');
  
    out=cell(0,0);
    sequence=cell(0,0);
    for fidx=1:length(futures)
        combo=futures(fidx).get();
        if ~isempty(combo)
        tmp=combo.getFRData();
            if numel(tmp)>0
                out{seqIdx,1}=tmp;
                sequence{seqIdx,1}=strtrim(fileList(fidx,:));
                sequence{seqIdx,2}=combo.getKeyIdx();
                seqIdx=seqIdx+1;
            end
        end
        waitbar(fidx/length(futures),h,[num2str(fidx),'/',num2str(length(futures))]);
    end

    fprintf('\n');
    delete(h);
end

end
