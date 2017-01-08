function convertSPKEVT
javaaddpath('R:\ZX\java\DualEvtParser\build\classes');
fl=listF();
fileList=fl.listSU_EVT();
tetrode = [0, 33;32, 65;64, 97];

for i=1:size(fileList)
    ft=load(fileList{i,1});
    SPKall=ft.SPK;
    
    for grp=1:3
        EVT=recreateTrial(fileList{i,2},grp);
        fprintf('f: %s\nGrp, %d, ', fileList{i},grp)
        if numel(EVT)>100
            SPK=SPKall(SPKall(:,4)>tetrode(grp,1) & SPKall(:,4)<tetrode(grp,2),1:4);
            SPK=SPK(SPK(:,3)>(EVT(1,1)-5) & SPK(:,3)<(EVT(end,1)+30),:);
            fprintf('EVT, %d, SPK, %d',  size(EVT,1), size(SPK,1));
            if size(SPK,1)>1500
                fNLength=length(fileList{i,1});
                saveName=[fileList{i,1}(1:fNLength-6),num2str(grp),'_OpSupp.mat'];
                save(saveName,'SPK','EVT');
            end
        end
        fprintf('\n');
    end
end



    function laserEvts=recreateTrial(fname,grp)
        Tags={'EVT04','EVT09','EVT21'};
        ft=load(fname);
        EVTS=ft.EVTS;
        if (~isfield(EVTS,Tags{grp})) || numel(EVTS.(Tags{grp}))<50
            laserEvts=[];
            return
        else
            if sum(diff(EVTS.(Tags{grp}))>60)>0
                [~,pos]=max(diff(find(diff([EVTS.(Tags{grp});realmax])>60)));
                posMat=find(diff([EVTS.(Tags{grp});realmax])>60);
                laserEvts=EVTS.(Tags{grp})(posMat(pos)+1:posMat(pos+1));
                laserEvts=[laserEvts,laserEvts];
            else
                laserEvts=EVTS.(Tags{grp});
                laserEvts=[laserEvts,laserEvts];
            end
            fprintf('');
        end
        
    end
end