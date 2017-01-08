classdef saveEvt4 < handle
    methods
        function save(obj)
            fl=ls('*.pl2');
            flwf=ls('*WF*');
            fl=mat2cell(fl(~ismember(fl,flwf,'rows'),:),size(fl,1)-size(flwf,1),1);
            for i=1:length(fl)
                if exist(fl{i},'file')==2
                    fnLen=size(fl{i},2);
                    fnNew=[fl{i}(1:fnLen-3),'_EVT21.mat'];
                    if ~(exist(fnNew,'file')==2)
                        EVT21=PL2EventTs(fl{i},'EVT21');
                        if numel(EVT21.Ts)>50
                            Evt21=EVT21.Ts;
                            save([fl{i}(1:fnLen-3),'_EVT21.mat'],'Evt21');
                        end
                    end
                end
            end
        end
    end
end