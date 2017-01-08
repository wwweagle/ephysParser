function convertSPKEVTWJ
javaaddpath('R:\ZX\java\DualEvtParser\build\classes');
dp=dualevtparser.DualEvtParser();
fl=listF();
fileList=fl.listSU_EVT_WJ();
% tetrode = [0, 33;32, 65;64, 97];

for i=1:size(fileList)
    fprintf('%d in file list\n',i);
    ft=load(fileList{i,1});
    SPK=ft.data;
    
    [lick,odorEvts]=recreateTrial(fileList{i,2});
    if numel(lick)>100 && numel(odorEvts)>100
        EVT=dp.parse(lick,odorEvts,13);
        SPK=SPK(SPK(:,3)>(EVT(1,2)-5) & SPK(:,3)<(EVT(end,2)+30),:);
        if numel(EVT)<200 || size(SPK,1 )<2000
            fprintf('error parsing file :%s\n',fileList{i,1});
        else
            SPK=[SPK(:,1:3),SPK(:,1)];
            fNLength=length(fileList{i,1});
            saveName=[fileList{i,1}(1:fNLength-7),'GRP.mat'];
            save(saveName,'SPK','EVT');
            
        end
    end
end



    function [lick,odorEvts]=recreateTrial(fname)
        Tags={'Odor1','Odor2','Lick'};
        allEvts=cell(1,3);

        for evt=1:3
            ft=load(fname);
            if (~isfield(ft,Tags{evt})) || numel(ft.(Tags{evt}))<50
                lick=[];
                odorEvts=[];
                return
            end
            allEvts{evt}=[repmat(evt,numel(ft.(Tags{evt})),1),ft.(Tags{evt})];
        end
        odorEvts=sortrows([allEvts{1};allEvts{2}],2);
        lick=allEvts{3};
    end
end