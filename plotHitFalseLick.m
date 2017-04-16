function [hits,falses]=plotHitFalseLick(fs)
binSize=0.25;
% lf=listF();
% [~,seq4sError]=sampleByType(lf.listDNMS4s,'sampleError','Average2Hz',-2,0.5,12,[30,1;30,1],500,1);
% [~,seq8sError]=sampleByType(lf.listDNMS8s,'sampleError','Average2Hz',-2,0.5,16,[30,1;30,1],500,1);
% fs=[seq4sError(:,1);seq8sError(:,1)];
javaaddpath('R:\ZX\java\assignLick\build\classes');
al=assignlick.AssignLick;
hits=[];
falses=[];
for i=1:length(fs)
    hName=fs{i,1};
    load(['R:\ZX\APC\data\',hName(16:end-8),'.mat'],'TrialInfo','Lick');
    sorted=al.sort(TrialInfo,Lick);
    hits=[hits;meanLickRatio(sorted{1})];
    falses=[falses;meanLickRatio(sorted{2})];
end


    function out=meanLickRatio(lickCell)
        if ~iscell(lickCell)
            out=histcounts(lickCell,-1:binSize:6);
        else
        hists=[];
        for j=1:length(lickCell)
            hists=[hists;histcounts(lickCell{j},-1:binSize:6)];
        end
        out=mean(hists)./binSize;
        end
    end

end
