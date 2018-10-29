javaaddpath('R:\ZX\java\spk2fr\build\classes');
s2f=spk2fr.multiplesample.Spk2fr();
evtFiles=dir('O:\ZX\**\*Event*');
evtFiles=evtFiles(arrayfun(@(x) ~contains(evtFiles(x).name,'DelayLaser'),1:length(evtFiles)));
isCorrect=@(x) xor(xor(ismember(x(:,3),[3 4 6 7]),ismember(x(:,4),[3 4 6 7])),~x(:,5));
% partialWellTrained=@(x) sum(evts(x:x+39,7))>31;

fs=arrayfun(@(x) [x.folder,'\',x.name],evtFiles,'UniformOutput',false);
miceids=unique(cellfun(@(x) x{1}, regexpi(fs,'\\m\w{3,4}(\d\d)','tokens','once'),'UniformOutput',false));
perf=cell(size(miceids));
for f=1:size(fs,1)
    fstr=load(fs{f});
    odorCount=numel(unique(fstr.OdorID));
    if odorCount<8
        fprintf('Error in file %s\n',fs{f});
        continue;
    end
    evts=s2f.buildTrials(fstr.OdorOnset,fstr.OdorOffset,fstr.OdorID,fstr.Lick,5);
    if length(evts)<50
        continue;
    end
    evts=[evts,isCorrect(evts)];
    partialWellTrained=@(x) sum(evts(x:x+39,7))>31;
    isWellTrained=any(arrayfun(@(x) partialWellTrained(x),1:size(evts,1)-39));
    if ~isWellTrained
        continue;
    end
    perfIdx=find(ismember(miceids,regexpi(fs{f},'\\m\w{3,4}(\d\d)','tokens','once')));
%     perf{f}=arrayfun(@(x) sum(evts(x:x+19,7))*100/20,1:20:size(evts,1)-19);
    perf{perfIdx}=[perf{perfIdx};{arrayfun(@(x) sum(evts(x:x+19,7))*100/20,1:20:size(evts,1)-19),fs{f}}];
end

perfPerMice=cell2mat(arrayfun(@(y) mean(cell2mat(cellfun(@(x) x(1:11),perf{y}(:,1),'UniformOutput',false)),1),find(~cellfun('isempty',perf)),'UniformOutput',false))';

figure('Color','w','Position',[100,100,240,240]);
hold on;
plot(perfPerMice,'-','Color',[0.8,0.8,0.8],'LineWidth',1);
plot(mean(perfPerMice,2),'-k','LineWidth',1.5);
ylabel('Correct Rate (%)');
xlabel('Trials in Session');
xlim([0.5,11]);
set(gca,'XTick',0.5:5:11,'XTickLabel',0:100:200);

% perf=perf(~cellfun('isempty',perf));
% figure();
% hold on;
% cellfun(@(x) plot(x'),perf);


%double[] onset, double[] offset, double[] id, double[] lick, double delayLen

