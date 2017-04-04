classdef listF < handle
    properties
        root='H:\ZX\APC\RecordingAug16\';
    end
    methods
        function f=listByWildCard(obj,suff,root)
            if ~exist('root','var')
                root=obj.root;
            end
%             cd(root);
            all=ls(root);
            all=[repmat(root,size(all,1),1),all];
            f=[];
            for i=1:size(all,1)
                if all(i,length(strtrim(all(i,:))))~='.' && exist(strtrim(all(i,:)),'file')==7
                    ft=ls([strtrim(all(i,:)),'\',suff]);
                    ft=[repmat([strtrim(all(i,:)),'\'],size(ft,1),1),ft];
                    f=char(f,ft);
                end
            end
            f=f(isletter(f(:,1)),:);
        end
        
        function ff=listPl2(obj)
            f=obj.listByWildCard('Dual*.pl2');
            ni=1;
            ff=cell(0,2);
            for i=1:size(f,1)
                if isempty(strfind(f(i,:),'_WF'))
                    len=strfind(f(i,:),'.pl2');
                    if exist([f(i,1:len-1),'_SU.mat'],'file')==2
                        ff{ni,1}=strtrim(f(i,:));
                        ff{ni,2}=[f(i,1:len-1),'_SU.mat'];
                        ni=ni+1;
                    end
                end
            end
        end
        
        function ff=listSU_EVT(obj)
            f=obj.listByWildCard('*_SU.mat','r:\ZX\APC\RecordingAug16\');
            ni=1;
            ff=cell(0,2);
            for i=1:size(f,1)
%                 if isempty(strfind(f(i,:),'_WF'))
                    len=strfind(f(i,:),'_SU.mat');
                    if exist([f(i,1:len-1),'_ALL_EVTS.mat'],'file')==2
                        ff{ni,1}=strtrim(f(i,:));
                        ff{ni,2}=[f(i,1:len-1),'_ALL_EVTS.mat'];
                        ni=ni+1;
                    else
                        fprintf('No matching EVT files:\n%s\n',f(i,:));
                    end
%                 end
            end
            fprintf('%d SU files, %d EVT files.\n',size(f,1),size(ff,1));
        end
        
        function ff=listSU_EVT_WJ(obj)
            
            f=obj.listByWildCard('*_Spk.mat','R:\ZX\APC\WJ\');
            ni=1;
            ff=cell(0,2);
            for i=1:size(f,1)
%                 if isempty(strfind(f(i,:),'_WF'))
                    len=strfind(f(i,:),'_Spk.mat');
                    if exist([f(i,1:len-1),'_Event.mat'],'file')==2
                        ff{ni,1}=strtrim(f(i,:));
                        ff{ni,2}=[f(i,1:len-1),'_Event.mat'];
                        ni=ni+1;
                    else
                        fprintf('No matching EVT files:\n%s\n',f(i,:));
                    end
%                 end
            end
            fprintf('%d SU files, %d EVT files.\n',size(f,1),size(ff,1));
        end
        
        function ff=listTrialF(obj)
            f=obj.listByWildCard('*GRP.mat');
            ni=1;
            ff=cell(0,1);
            for i=1:size(f,1)
                        ff{ni,1}=strtrim(f(i,:));
                        ni=ni+1;
            end
            fprintf('%d trial files, %d trial files.\n',size(f,1),size(ff,1));
        end
        
        function ff=listTrialFWJ(obj)
            f=obj.listByWildCard('*GRP.mat','H:\ZX\APC\WJ\');
            ni=1;
            ff=cell(0,1);
            for i=1:size(f,1)
                        ff{ni,1}=strtrim(f(i,:));
                        ni=ni+1;
            end
            fprintf('%d trial files, %d trial files.\n',size(f,1),size(ff,1));
        end
        
        function ff=listOpSupp(obj,ramp)
            if exist('ramp','var') && ramp
                f=obj.listByWildCard('*OpSupp.mat','H:\ZX\APC\OpSupp\Ramp\');
            else
                f=obj.listByWildCard('*OpSupp.mat','H:\ZX\APC\OpSupp\Step\');
            end
            ni=1;
            ff=cell(0,1);
            for i=1:size(f,1)
                        ff{ni,1}=strtrim(f(i,:));
                        ni=ni+1;
            end
            fprintf('%d trial files, %d trial files.\n',size(f,1),size(ff,1));
        end
        
        function ff=listDNMS8s(obj)
            root='H:\ZX\APC\DNMS\DNMS 8s\';

            all=ls([root,'*.mat']);
            all=[repmat(root,size(all,1),1),all];
            ff=all;
        end
        
        function ff=listDNMS4s(obj)
            root='H:\ZX\APC\DNMS\DMNS 4s\';

            all=ls([root,'*.mat']);
            all=[repmat(root,size(all,1),1),all];
            ff=all;
        end
        
        function ff=listDNMSNaive5s(obj)
            root='H:\ZX\APC\DNMS\Naive 5s\';

            all=ls([root,'*.mat']);
            all=[repmat(root,size(all,1),1),all];
            ff=all;
            

            root='H:\ZX\APC\DNMS\Naive 5s_2016\';

            all=ls([root,'*.mat']);
            all=[repmat(root,size(all,1),1),all];
            ff=char(ff,all);
            
        end
    end
    
end