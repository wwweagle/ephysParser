function gendPCAFR(none,nogo,go)
binSize=0.5;
% none=sampleDualByType('distrNone','Average2Hz',-2,binSize,11,[100,0;100,0],1,1);
% nogo=sampleDualByType('distrNogo','Average2Hz',-2,binSize,11,[100,0;100,0],1,1);
% go=sampleDualByType('distrGo','Average2Hz',-2,binSize,11,[100,0;100,0],1,1);

byDistr={none,nogo,go};

firingRatesAverage=nan(size(go,1),2,3,10/binSize);


for s=1:2
    for d=1:3
        firingRatesAverage(:,s,d,:)=getBy_S_D(s,d);
    end
end



%% Define parameter grouping

% parameter groupings
% 1 - stimulus
% 2 - decision
% 3 - time
% [1 3] - stimulus/time interaction
% [2 3] - decision/time interaction
% [1 2] - stimulus/decision interaction
% [1 2 3] - rest
% Here we group stimulus with stimulus/time interaction etc. Don't change
% that if you don't know what you are doing

% combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
% margNames = {'Sample', 'Distractor', 'Condition-independent', 'S/D Interaction'};

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}};
margNames = {'Sample', 'Distractor', 'Condition-independent'};
margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% Time events of interest (e.g. stimulus onset/offset, cues etc.)
% They are marked on the plots with vertical lines
time=binSize:binSize:10;
timeEvents = [1,2,4,5.5];



%% Step 3: dPCA without regularization and ignoring noise covariance

% This is the core function.
% W is the decoder, V is the encoder (ordered by explained variance),
% whichMarg is an array that tells you which component comes from which
% marginalization

tic
[W,V,whichMarg] = dpca(firingRatesAverage, 20, ...
    'combinedParams', combinedParams);
toc

explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
    'combinedParams', combinedParams);


dpca_plot_zx(firingRatesAverage, W, V, @dpca_plot_default_zx, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours, ...
    'whichMarg', whichMarg,                 ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'timeMarginalization', 3, ...
    'legendSubplot', 16);
% pause;





    function data=getBy_S_D(s,d)
        data=byDistr{d};
        bins=1/binSize+1:11/binSize;
        half=size(data,3)/2;
        if s==1
            data=data(:,bins);
        else
            data=data(:,bins+half);
        end
    end



end