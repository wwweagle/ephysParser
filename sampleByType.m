function out = sampleByType(fileList,type,classify,binStart,binSize,binEnd,sampleSize,repeats,onlyWellTrain) %type='odor' or 'correct' ; SampleSize=[PFSampleSize1,PFSampleSize2;BNSampleSize1,BNSampleSize2];
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% dp=javaclasspath('-dynamic');
% if ~ismember('R:\ZX\java\spk2fr\build\classes',dp)
    javaaddpath('R:\ZX\java\spk2fr\build\classes');
    javaaddpath('R:\ZX\java\spk2fr\lib\commons-math3-3.5.jar');
    javaaddpath('R:\ZX\java\spk2fr\lib\jmatio.jar');
% end

if exist('onlyWellTrain','var')
    para=spk2fr.Para(onlyWellTrain,0.0015);
else
    para=spk2fr.Para(2,0.0015);
end

out=[];

% rf=recordingFiles;

para.setFormat('WJ');

for fidx=1:size(fileList,1)
    %     evts=rf.reconEvts(fileList,fidx);
    %     fprintf('%d, ',fidx);
    %     load(fileList{fidx,3});
    %     spkStruct=load(fileList{fidx,2});
    %     spk=spkStruct.data;
    %     clear spkStruct;
    
    
    currF=strtrim(fileList(fidx,:));
    if exist(currF,'file')==2
        futures(fidx)=para.parGetSampleFR(currF,currF,classify, type,binStart,binSize,binEnd,sampleSize,repeats);
    else
        fprintf('Warining:\nFile %s does not exist',currF)
    end
end
h=waitbar(0,'0');
for fidx=1:length(futures)
    tmp=futures(fidx).get();
%     fprintf('%s\t%d\n',fileList(fidx,:),size(tmp,1));
    if numel(tmp)>0
        %         fprintf('%d, %d\n',fidx, size(tmp,1));
        out=[out;tmp];
    end
    %     ts=cell(s2f.getFiringTimesByOdor(odor));
    % %     out=nan(length(ts),length(edges)-1);
    %     for unit=1:length(ts)
    %         unitTs=cell2mat(cellfun(@cell2mat,ts{unit},'UniformOutput',0));
    % %         fprintf('%f, %f\n',min(unitTs),max(unitTs));
    %         out=[out;histcounts(unitTs,edges)./s2f.getTrialCountByFirstOdor(odor)];
    %     end
    waitbar(fidx/length(fileList),h,[num2str(fidx),'/',num2str(length(fileList))]);
end
fprintf('\n');
delete(h);

