function plotQual
javaaddpath('R:\ZX\java\spk2fr\build\classes');
javaaddpath('R:\ZX\java\spk2fr\lib\jmatio.jar');
javaaddpath('R:\ZX\java\spk2fr\lib\commons-math3-3.5.jar');
javaaddpath('R:\ZX\java\DualEvtParser\build\classes');
s2f=spk2fr.Spk2fr;
s2f.setRefracRatio(0.0015);
s2f.setLeastFR('Average2Hz');
%
% ll=spk2fr.MatFile.buildFileList('R:/ZX/','Spk.mat');
% fsSpk=cell(ll.toArray());
% ll=spk2fr.MatFile.buildFileList('R:/ZX/','_Ana.mat');
% fsSpk2=cell(ll.toArray());
% ll=spk2fr.MatFile.buildFileList('R:/ZX/','data in Trial.mat');
% fsSpk3=cell(ll.toArray());
%
% waveFS=[fsSpk;fsSpk2;fsSpk3];
load('waveFS.mat');
FAAll=[];
SNRAll=[];
for delayLen=4:4:8
    [spkCA,tagA]=allByTypeDNMS('sampleall','Average2Hz',-2,0.5,13,true,delayLen,true);
    fs=tagA(:,1);
    
    for fidx=1:length(fs)
        disp(fidx);
        assignin('base','fidx',fidx);
        fnTrunk=regexpi(fs{fidx},'(?<=\\)(M|Pir)\d+.*Day\d+','match','once');
        wavef=waveFS{contains(waveFS,fnTrunk)};
        clear Spk SPK
        load(fs{fidx});
        if exist('Spk','var')
            fstr=load(wavef,'Spk');
            spkWave=fstr.Spk;
        else
            Spk=SPK;
            TrialInfo=EVT;
            fstr=load(wavef,'SPK');
            spkWave=fstr.SPK;
        end
        TrialInfo=spk2fr.MatFile.wellTrainedTrials(TrialInfo,true);
        %     if size(TrialInfo,1)<50 || size(Spk,1)<500
        %         continue;
        %     end
        
        ts=s2f.getTS(TrialInfo,Spk,'wjdnms',false,true);
        criteria=s2f.getCriteria();
        %     if isempty(ts)
        %         continue;
        %     end
        %     keys2=s2f.getKeyIdx();
        keys=tagA{fidx,2};
        
        for SUIdx=1:size(keys,1)
            wave=spkWave(spkWave(:,1)==keys(SUIdx,1) & spkWave(:,2)==keys(SUIdx,2), 4:end);
            mm=mean(wave);
            tetBound=1:size(wave,2)/4:size(wave,2);
            for i=1:4
                trode=mm(tetBound(i):(tetBound(i)+length(mm)/4-1));
                dfmm(i)=max(trode)-min(trode);
            end
            [~,maxIdx]=max(dfmm);
            noise=std(mean(wave(:,tetBound(maxIdx):(tetBound(maxIdx)+4)),2));
            SNR=dfmm(maxIdx)./noise;
            SNRAll=[SNRAll,SNR];
            FA=criteria(SUIdx,2);
            FAAll=[FAAll,FA];

            
            
%             if FA>0.0015
%                 pause();
%             end
%             df=diff([cell2mat(ts{SUIdx}{1});cell2mat(ts{SUIdx}{2})]);
%             df=df(df>=0 & df <=0.02);
%             counts=histcounts(df,0:0.001:0.020);
%             fh=figure('Color','w','Position',[100,100,120,120]);
%             subplot('Position',[0.25,0.2,0.7,0.6]);
%             hold on;
%             bh=bar([-20:-1,1:20],[fliplr(counts),counts],1,'FaceColor','k','EdgeColor','k');
%             fill([-2 -2 2 2],[0,max(ylim()),max(ylim()),0],[1,0.8,0.8],'EdgeColor','none');
%             uistack(bh,'top');
%             ax2=axes(fh,'Position',[0 0 1 1],'Visible','off');
%             text(ax2,0.25,0.95,sprintf('%.4f',FA),'HorizontalAlignment','center');
%             text(ax2,0.75,0.95,sprintf('%.2f',SNR),'HorizontalAlignment','center');
%             print('-depsc','-painters',sprintf('SUQual_D%d_F%d_SU%d_FA%.4f_SNR%.2f.eps',delayLen,fidx,SUIdx,FA,SNR));
%             print('-dpng','-painters',sprintf('SUQual_D%d_F%d_SU%d_FA%.4f_SNR%.2f.png',delayLen,fidx,SUIdx,FA,SNR));
%             close(fh);
        end
    end
end
plotScatter(FAAll,SNRAll);
end

function plotScatter(FAAll,SNRAll)
FA=FAAll;
SNR=SNRAll;
% d4fs=struct2cell(dir('*D4*.eps'))';
% d8fs=struct2cell(dir('*D8*.eps'))';
% fs=[d4fs(:,1);d8fs(:,1)];
% FA=cellfun(@(x) str2double(x),regexp(fs,'(?<=FA)0.\d{4}','match','once'));
% SNR=cellfun(@(x) str2double(x),regexp(fs,'(?<=SNR)\d+.\d{2}','match','once'));
figure('Color','w','Position',[100,100,315,300]);
hold on;
plot(FAAll,SNRAll,'k.');
xlim([-0.0002,0.0017]);
xlabel('False alarm rate (FA)');
ylabel('Signal to noise ratio (SNR)');
end