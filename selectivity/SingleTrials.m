classdef SingleTrials < handle
    methods (Static)
        function AUC=histg(delayLen)
            binW=0.1;
            isS1=true;
            [spkCA,tagA]=allByTypeDNMS('sample','Average2Hz',-2,binW,delayLen+7,isS1,delayLen,true);
            [spkCAE,tagAE]=allByTypeDNMS('sampleError','Average2Hz',-2,binW,delayLen+7,isS1,delayLen,true);
            
            isS1=false;
            [spkCB,tagA]=allByTypeDNMS('sample','Average2Hz',-2,binW,delayLen+7,isS1,delayLen,true);
            [spkCBE,tagAE]=allByTypeDNMS('sampleError','Average2Hz',-2,binW,delayLen+7,isS1,delayLen,true);
            
%             pvalues=plotSelCdf.calcCDF(delayLen,binW);
%             [selCdf,cdfci,selhist,selSpan]=plotSelCdf.furtherProcess(pvalues,binW);
            
%             persistUs=find(selSpan>=2);
            count=cellfun(@(x) size(x,1),spkCA);
            accued=(arrayfun(@(x) sum(count(1:x,1)),1:length(count)));
%             persistUs=[45 118];
            AUC=nan(1,sum(cellfun(@(x) size(x,1),spkCA)));
            for uidx=1:sum(cellfun(@(x) size(x,1),spkCA))%persistUs
                fprintf('D%d, U%d\n',delayLen,uidx);
                try
%                     fh=figure('Color','w');
%                     fh.Position(3:4)=[750,215];
                    
                    fi=find(accued>=uidx,1,'first');
                    if fi>1
                        ui=uidx-accued(fi-1);
                    else 
                        ui=uidx;
                    end
                    
                    frA=squeeze(spkCA{fi}(ui,:,:));
                    frB=squeeze(spkCB{fi}(ui,:,:));
%                     
%                     frAE=squeeze(spkCAE{fi}(ui,:,:));
%                     frBE=squeeze(spkCBE{fi}(ui,:,:));
                    
                    [bA,sbA]=SingleTrials.basestat(frA);
                    [bB,sbB]=SingleTrials.basestat(frB);
%                     delayWin=20+delayLen*10+(-9:10);
                    delayWin=20+delayLen*10+(-29:10);
                    
                    mAZ=(mean(frA(:,delayWin),2)-bA)./sbA;
                    mBZ=(mean(frB(:,delayWin),2)-bB)./sbB;
                    
                    
                    
%                     subplot(1,4,1);
%                     hold on;
%                     cia=bootci(1000,@(x) smooth(mean(x),3),frA);
%                     cib=bootci(1000,@(x) smooth(mean(x),3),frB);
%                     fill([1:length(cia),fliplr(1:length(cia))],[cia(1,:),fliplr(cia(2,:))],[0.8,0.8,1],'EdgeColor','none');
%                     fill([1:length(cib),fliplr(1:length(cib))],[cib(1,:),fliplr(cib(2,:))],[1,0.8,0.8],'EdgeColor','none');
%                     plot(smooth(mean(frA),3),'-b','LineWidth',1.5);
%                     plot(smooth(mean(frB),3),'-r','LineWidth',1.5);
%                     yspan=ylim();
%                     arrayfun(@(x) plot([x,x],yspan,':k'),[20.5,30.5,delayLen*10+30.5,delayLen*10+40.5]);
%                     set(gca,'XTick',20.5:50:120.5,'XTickLabel',0:5:10);
%                     xlabel('Time (s)');
%                     ylim(yspan);
%                     xlim([14.5,delayLen*10+41]);
%                     ylabel(sprintf('FR (Hz) %d-%d',delayLen,uidx));
%                     
%                 catch ME
%                     fprintf('Exception L%d U%d P%d\n',delayLen,uidx,1);
%                     continue;
%                 end
                %             plot(smooth(mean(frAE)),':b');
                %             plot(smooth(mean(frBE)),':r');
                
%                 try
%                     subplot(1,4,2);
%                     hold on;
%                     bins=linspace(min([mAZ(:);mBZ(:)]),max([mAZ(:);mBZ(:)]),10);
%                     cA=histcounts(mAZ,bins,'Normalization','probability');
%                     cB=histcounts(mBZ,bins,'Normalization','probability');
                    
%                     xpos=bins(1:end-1)+diff(bins(1:2));
%                     dpos=diff(xpos(1:2));
%                     bar(xpos-dpos*0.225,cA,0.45,'EdgeColor','none','FaceColor','b');
%                     bar(xpos+dpos*0.225,cB,0.45,'EdgeColor','none','FaceColor','r');
%                     xlabel('FR Z-score');
%                     ylabel(sprintf('Probability %dT',numel([mAZ(:);mBZ(:)])));
                    
%                 catch ME
%                     fprintf('Exception L%d U%d P%d\n',delayLen,uidx,2);
%                 end
%                 
%                 try
%                     subplot(1,4,3);
%                     hold on;
%                     mAEZ=(mean(frAE(:,delayWin),2)-bA)./sbA;
%                     mBEZ=(mean(frBE(:,delayWin),2)-bB)./sbB;
%                     
%                     cAEZ=histcounts(mAEZ,bins,'Normalization','probability');
%                     cBEZ=histcounts(mBEZ,bins,'Normalization','probability');
%                     
%                     xpos=bins(1:end-1)+diff(bins(1:2));
%                     dpos=diff(xpos(1:2));
%                     bar(xpos-dpos*0.225,cAEZ,0.45,'EdgeColor','none','FaceColor','b');
%                     bar(xpos+dpos*0.225,cBEZ,0.45,'EdgeColor','none','FaceColor','r');
%                     xlabel('FR Z-score');
%                     ylabel(sprintf('Probability %dT ',numel([mAEZ(:);mBEZ(:)])));
                    
%                 catch ME
%                     fprintf('Exception L%d U%d P%d\n',delayLen,uidx,3);
%                 end
                
%                 try
                    labels=[repmat({'S1'},size(mAZ));repmat({'S2'},size(mBZ))];
                    scores=[mAZ;mBZ];
                    if mean(mAZ)>mean(mBZ)
                        pos='S1';
                    else
                        pos='S2';
                    end
                    
                    [ax,ay,~,auc]=perfcurve(labels,scores,pos);
%                     labelse=[repmat({'S1'},size(mAEZ));repmat({'S2'},size(mBEZ))];
%                     scorese=[mAEZ;mBEZ];
%                     if numel(labelse)<15
%                         continue;
%                     end
                    
%                     [aex,aey,~,auce]=perfcurve(labelse,scorese,pos);
% %                     subplot(1,4,4);
% %                     hold on;
% %                     fill([(ax(:,1));flipud(ax(:,1))],[(ay(:,2));flipud(ay(:,3))],[0.8,0.8,1],'EdgeColor','none','FaceAlpha',0.5);
% %                     fill([(aex(:,1));flipud(aex(:,1))],[(aey(:,2));flipud(aey(:,3))],[1,0.8,0.8],'EdgeColor','none','FaceAlpha',0.5);
%                     plot(ax(:,1),ay(:,1),'-b','LineWidth',1.5);text(0.33,0.66,num2str(auc(1)));
%                     plot(aex(:,1),aey(:,1),'-r','LineWidth',1.5);text(0.66,0.33,num2str(auce(1)));
%                     xlabel('False rate');
%                     ylabel('True rate');
                    AUC(uidx)=auc;
                catch ME
                    fprintf('Exception L%d U%d P%d\n',delayLen,uidx,4);
                end
                if exist('fh','var') && exist('auc','var')
                    if auc(1)>0.75
                        print(fh,'-dpng',sprintf('std%du%d.png',delayLen,uidx));
                        savefig(fh,sprintf('std%du%d.fig',delayLen,uidx))
                    end
                end
                close all
                
                
            end
        end
        
        
        function run()
            
            
            close all;
            figure();
            hold on;
            plot(smooth(mean(frA)),'-b','LineWidth',2);
            plot(smooth(mean(frB)),'-r');
            plot(smooth(mean(frAE)),':b');
            plot(smooth(mean(frBE)),':r');
            
            smt=cell2mat(arrayfun(@(x) smooth(frA(x,:),5),1:size(frA,1),'UniformOutput',false));
            
        end
        
        function [mm,stdd]=basestat(fr)
            frb=mean(fr(:,12:19),2);
            mm=mean(frb);
            stdd=std(frb);
        end
    end
end