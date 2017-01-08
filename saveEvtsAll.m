function saveEvtsAll
path(path,'r:\ZX\Tools\Matlab Offline Files SDK\');
lf=listF();
pl2List=lf.listPl2();


evtNames={'EVT02','EVT03','EVT01','EVT04','EVT07','EVT08','EVT06','EVT09','EVT19','EVT20','EVT18','EVT21'};

for i=1:length(pl2List)
    clear('fsave','EVTS');
    EVTS=struct();
    for e=1:length(evtNames)
        tStru=PL2EventTs(pl2List{i},evtNames{e});
        if length(tStru.Ts)>50
            EVTS.(evtNames{e})=tStru.Ts;
        end
    end
    fNLength=length(pl2List{i});
    fsave=[pl2List{i}(1:fNLength-4),'_ALL_EVTS.mat'];
    save(fsave,'EVTS');
end