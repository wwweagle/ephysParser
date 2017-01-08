function convertSPKEVT
javaaddpath('R:\ZX\java\DualEvtParser\build\classes');
dp=dualevtparser.DualEvtParser();
fl=listF();
fileList=fl.listSU_EVT();
tetrode = [0, 33;32, 65;64, 97];

for i=1:size(fileList)
    ft=load(fileList{i,1});
    SPKall=ft.SPK;
    
    for grp=1:3
        [lick,odorEvts]=recreateTrial(fileList{i,2},grp);
        if numel(lick)>100 && numel(odorEvts)>100
            EVT=dp.parse(lick,odorEvts,8);
            SPK=SPKall(SPKall(:,4)>tetrode(grp,1) & SPKall(:,4)<tetrode(grp,2),:);
            SPK=SPK(SPK(:,3)>(EVT(1,2)-5) & SPK(:,3)<(EVT(end,2)+30),:);
            if size(SPK,1)>2000
                SPK=SPK(:,1:4);
                fNLength=length(fileList{i,1});
                saveName=[fileList{i,1}(1:fNLength-6),num2str(grp),'GRP.mat'];
                save(saveName,'SPK','EVT');
            end
        end
    end
end



    function [lick,odorEvts]=recreateTrial(fname,grp)
        Tags={'EVT02','EVT03','EVT01';'EVT07','EVT08','EVT06';'EVT19','EVT20','EVT18'};
        
        % Tags={'EVT19','EVT20','EVT18';'EVT07','EVT08','EVT06';'EVT02','EVT03','EVT01'};
        
        allEvts=cell(1,3);
        
        for evt=1:3
            ft=load(fname);
            EVTS=ft.EVTS;
            if (~isfield(EVTS,Tags{grp,evt})) || numel(EVTS.(Tags{grp,evt}))<50
                lick=[];
                odorEvts=[];
                return
            end
            
            allEvts{evt}=[repmat(evt,numel(EVTS.(Tags{grp,evt})),1),EVTS.(Tags{grp,evt})];
        end
        odorEvts=sortrows([allEvts{1};allEvts{2}],2);
        lick=allEvts{3};
    end
end