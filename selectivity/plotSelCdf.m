classdef plotSelCdf < handle
    properties
        binW;
        pvalues8;
        pvalues4;
    end
    methods (Static)
        function run(obj)
            obj.binW=0.1;
            obj.pvalues8=plotSelCdf.calcCDF(8);
            obj.pvalues4=plotSelCdf.calcCDF(4);
        end
        function runMore()
            
            [selCdf4,cdfci4,selhist4,selSpan4]=plotSelCdf.furtherProcess(pvalues4,binW);
            [selCdf8,cdfci8,selhist8,selSpan8]=plotSelCdf.furtherProcess(pvalues8,binW);
            
            figure('Color','w','Position',[100,100,350,250]);
            hold on;
            fill([1:length(cdfci4),fliplr(1:length(cdfci4))],[cdfci4(1,:),fliplr(cdfci4(2,:))],[0.8,0.8,1],'EdgeColor','none');
            fill([1:length(cdfci4),fliplr(1:length(cdfci4))],[cdfci8(1,:),fliplr(cdfci8(2,:))],[1,0.8,0.8],'EdgeColor','none');
            plot(selCdf8,'-r','LineWidth',1);
            plot(selCdf4,'-b','LineWidth',1);
            set(gca,'XScale','log','YScale','linear')
            set(gca,'XTick',[0,5,10,50,100],'XTickLabel',[0,0.5,1,5,10]);
            ylim([0,1]);
            xlim([0,110]);
            xlabel('Continous selective period (s)');
            ylabel('Cumulative probability');
        end
        function pvalues=calcCDF(delayLen,binW)
            
            [spkCA,tagA]=allByTypeDNMS('sample','Average2Hz',-2,binW,delayLen+7,true,delayLen,delayLen~=5);
            [spkCB,tagB]=allByTypeDNMS('sample','Average2Hz',-2,binW,delayLen+7,false,delayLen,delayLen~=5);
            
            if (~all(strcmp(tagA(:,1),tagB(:,1)))) || ~isequal(tagA(:,2),tagB(:,2))
                return;
            end
            
            sig=cell(0,0);
            idxBias=1/binW-1;
            parfor winIdx=(1/binW):(delayLen+4).*(1/binW)
                selWin=(winIdx+1):(winIdx+(1/binW))
                sig{winIdx-idxBias}=arrayfun(@(x) SelTools.permTAll(spkCA{x},spkCB{x},selWin),1:length(spkCA),'UniformOutput',false);
            end
            
            pvalues=cell2mat(arrayfun(@(x) cell2mat(sig{1,x}).',1:length(sig),'UniformOutput',false));
        end
        function [selCdf,cdfci,selhist,selSpan]=furtherProcess(pvalues,binW)
            maxs=arrayfun(@(x) max(diff(find([1,diff(pvalues(x,:)),1]))),1:size(pvalues,1))-1;
            selSpan=maxs*binW;
            selCdf=histcounts(selSpan,0:binW:12,'Normalization','cdf');
            selhist=histcounts(selSpan,0:binW:12,'Normalization','probability');
            cdfci=bootci(1000,@(x) histcounts(x,0:binW:12,'Normalization','cdf'),selSpan);
        end
    end
end