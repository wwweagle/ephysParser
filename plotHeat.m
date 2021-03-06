classdef plotHeat < handle
    properties
        binSize=2;
        peri=false;
        delayCorrection=0;
        byOdor=true;
        sortBy='delay';
        importIdx=false;
        idx;
        smooth=false;
    end
    methods (Access=private)
        
        function plotOdorEdge(obj,delay)
            yspan=ylim();
            if delay==8 && obj.peri
                xx=[1,2,4,5.5,10,11]*10/obj.binSize+0.5;
            else
                xx=[1,2,delay+2,delay+3,delay+4,delay+4.5]*10/obj.binSize+0.5;
            end
            
            if obj.peri
                xx=[2,2.5,3,3.5]*10/obj.binSize+0.5;
            end
            arrayfun(@(curX) line([xx(curX),xx(curX)],yspan,'LineStyle','-','LineWidth',0.5,'Color','w'),1:length(xx));
         end
        
        function [pfBins,bnBins]=getBins(obj,type,delay)
            switch type
                case 'delay'
                    pfBins=(30/obj.binSize)+1:(delay*10+30)/obj.binSize;
                case 'trial'
                    pfBins=(10/obj.binSize)+1:(delay+3+obj.delayCorrection+1)*10/obj.binSize;
                case 'sample'
                    pfBins=(20/obj.binSize)+1:30/obj.binSize;
                case 'lateDelay'
                    pfBins=(70/obj.binSize)+1:(delay*10+30)/obj.binSize;
%                 case 'peri'
%                     pfBins=(30/obj.binSize)+1:(delay*10+30)/obj.binSize;
                case 'decision'
                    pfBins=20/obj.binSize+1:40/obj.binSize;
            end
            bnBins=pfBins+(20*(delay+obj.delayCorrection)+100)./obj.binSize;
        end
        
        function [xtick,xlabel]=getXTick(obj,delay)
            xtick=(0:10:delay*10+30+obj.delayCorrection*10)/obj.binSize;
%             xtick=(5:10:delay*10+30)/obj.binSize;
%               xtick=[0.5,1.5,3,4.75,7.75,10.5]*10/obj.binSize+0.5;
            xlabel=cell(1,length(xtick));
            for i=2:5:length(xtick)
                xlabel{i}=num2str(i-2);
            end
            if obj.peri
                xtick=[];
                xlabel={''};
            end
        end     
    end
    
    
    methods
        function plot(obj,samples,periDistr,fileName)
            obj.peri=periDistr;
            if obj.byOdor
                delay=size(samples,3)/4*(obj.binSize/10)-5-obj.delayCorrection;
            else
                delay=size(samples,3)/4*(obj.binSize/10)-5-obj.delayCorrection;
            end
            
%             close all;

            samples=squeeze(samples);
            if ~obj.importIdx
                if strcmp(obj.sortBy,'match')
                    [~,obj.idx]=sort(mean(samples(:,20/obj.binSize+1:30/obj.binSize),2)-mean(samples(:,[20/obj.binSize+1:30/obj.binSize]+size(samples,2)/2),2));
                else
                    [pfbins,bnbins]=obj.getBins(obj.sortBy,delay);
                    [~,obj.idx]=sort(mean(samples(:,pfbins),2)-mean(samples(:,bnbins),2));
                end
            end
            
            samples=samples(obj.idx,:);
            
%             figure('Color','w','Position',[100,100,305,190]);
%             figure('Color','w','Position',[100,100,220,250]);
            figure('Color','w','Position',[100,100,160,235]);
            subplot('Position',[0.11,0.17,0.42,0.70]);
            %             hold on;
            if periDistr
                [pfbins,bnbins]=obj.getBins('delay',delay);
            else
                [pfbins,bnbins]=obj.getBins('trial',delay);
            end
            %%%%%%%%%%%   ORIGINAL     %%%%%%%%%%%%%%%%%
            % imagesc(flip(samples(:,pfbins)),[-3,3]); %
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if obj.smooth
                smt=flip(samples(:,pfbins))';
                for i=1:size(smt,2)
                    smt(:,i)=smooth(smt(:,i));
                end
                smt=smt';
                imagesc(smt,[-3,3]);
            else
                imagesc(flip(samples(:,pfbins)),[-3,3]);
            end
            
%             imagesc(flip(samples([1:110,end-110:end],pfbins)),[-3,3]);
%             set(gca,'YTick',[50,100,110,250-119,300-119],'YTickLabel',[50,100,0,250,300]);
            
            [xtick,xtickLabel]=obj.getXTick(delay);
            set(gca,'YTick',[],'XTick',xtick+0.5,'XTickLabel',xtickLabel,'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            ylim([-1,158]);
            
            obj.plotOdorEdge(delay);
            colormap('jet');

            xspan=xlim();
            
%             yspan=ylim();
%             dy=diff(yspan)*0.01;
%             fill([10/obj.binSize+0.5,20/obj.binSize,20/obj.binSize,10/obj.binSize],[110*dy,110*dy,120*dy,120*dy],'r','EdgeColor','none');
%             ylim(yspan);
%             if strcmpi(type,'odor')
%                 text(size(pfbins,2)/2,size(samples,1)*-0.09,'PF as sample','HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
%             elseif strcmpi(type,'correct')
%                 text(35,size(samples,1)*-0.05,'Correct trials','HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
%             end
            
%             text(-diff(xlim)*0.45,size(samples,1)/2,'Cell No.','Rotation',90,'VerticalAlignment','middle','HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');

            
            
            subplot('Position',[0.56,0.17,0.42,0.70]);
            %%%%%%%%%%%   ORIGINAL     %%%%%%%%%%%%%%%%%
            % imagesc(flip(samples(:,bnbins)),[-3,3]); %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if obj.smooth
                smt=flip(samples(:,bnbins))';
                for i=1:size(smt,2)
                    smt(:,i)=smooth(smt(:,i));
                end
                smt=smt';
                imagesc(smt,[-3,3]);
            else
                imagesc(flip(samples(:,bnbins)),[-3,3]);
            end
            
            set(gca,'YTick',[],'XTick',xtick+0.5,'XTickLabel',xtickLabel,'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            obj.plotOdorEdge(delay);
            ylim([-1,158]);
            colormap('jet');
            
%             if strcmpi(type,'odor')
%                 text(size(bnbins,2)/2,size(samples,1)*-0.09,'BN as sample','HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
%             elseif strcmpi(type,'correct')
%                 text(35,size(samples,1)*-0.05,'Incorrect trials','HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
%             end
            text(size(bnbins,2)*1.6,size(samples,1)/2,'Normalized Firing Rate','Rotation',270,'VerticalAlignment','middle','HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
            
%             text(xtick(end)*-0.3,size(samples,1)*1.2,'Time(s)','FontSize',10,'FontName','Helvetica');
            obj.writeFile(fileName);
        end
        
        function curve=genCurve(obj,samples)
            if obj.byOdor
                delay=size(samples,3)/4*(obj.binSize/10)-5-obj.delayCorrection;
            else
                delay=size(samples,3)/4*(obj.binSize/10)-5-obj.delayCorrection;
            end
            
            samples=squeeze(samples);
            preResp=(delay+4)*10/obj.binSize+1:(delay+5)*10/obj.binSize;
            preResp=[preResp,preResp+size(samples,2)/2];
            if ~obj.importIdx
                if strcmp(obj.sortBy,'match')
                    [~,obj.idx]=sort(mean(samples(:,20/obj.binSize+1:40/obj.binSize),2));
                elseif strcmp(obj.sortBy,'matchCurve')

                    [~,obj.idx]=sort(mean(samples(:,preResp),2));
                else
                    [pfbins,bnbins]=obj.getBins(obj.sortBy,delay);
                    [~,obj.idx]=sort(mean(samples(:,pfbins),2)-mean(samples(:,bnbins),2));
                end
            end
            
            samples=samples(obj.idx,:);
            curve=mean(samples(:,preResp),2);
            
        end


        function writeFile(obj,fileName)
                set(gcf,'PaperPositionMode','auto');
                savefig([fileName,'.fig']);
                disp('file saved');
        end
    end
end