classdef plotHeat < handle
    properties
        binSize=2;
        peri=false;
        delayCorrection=0;
    end
    methods (Access=private)
        
        function plotOdorEdge(obj,delay)
            yspan=ylim();
            if delay==8 && obj.peri
                xx=[1,2,4,5.5,10,11]*10/obj.binSize+0.5;
            elseif delay==8
                xx=[1,2,10,11]*10/obj.binSize+0.5;
            elseif delay==13
                xx=[1,2,6,7.5,15,16]*10/obj.binSize+0.5;
            elseif delay==5
                xx=[1,2,7,8]*10/obj.binSize+0.5;
            elseif delay==4
                xx=[1,2,6,7]*10/obj.binSize+0.5;
            end
            
            if obj.peri
                xx=[2,2.5,3,3.5]*10/obj.binSize+0.5;
            end
            for curX=1:length(xx)
                line([xx(curX),xx(curX)],yspan,'LineStyle','-','LineWidth',0.5,'Color','w');
            end
 
        end
        
        function [pfBins,bnBins]=getBins(obj,type,delay)
            switch type
                case 'delay'
                    pfBins=(30/obj.binSize)+1:(delay*10+30)/obj.binSize;
                case 'trial'
                    pfBins=(10/obj.binSize)+1:((delay+obj.delayCorrection)*10+40)/obj.binSize;
                case 'sample'
                    pfBins=(20/obj.binSize)+1:30/obj.binSize;
                case 'lateDelay'
                    pfBins=(70/obj.binSize)+1:(delay*10+30)/obj.binSize;
%                 case 'peri'
%                     pfBins=(30/obj.binSize)+1:(delay*10+30)/obj.binSize;
            end
            bnBins=pfBins+(20*(delay+obj.delayCorrection)+100)./obj.binSize;
        end
        
        function [xtick,xlabel]=getXTick(obj,delay)
            xtick=(0:10:delay*10+30)/obj.binSize;
%             xtick=(5:10:delay*10+30)/obj.binSize;
%               xtick=[0.5,1.5,3,4.75,7.75,10.5]*10/obj.binSize+0.5;
            switch delay
                case 4
                    xlabel={'','0','','','','','5',''};
                case 5
                    xlabel={'','0','','','','','5','',''};
                case 8
                    xlabel={'','0','','','','','5','','','','','10'};
%                       xlabel={'B','S','E','D','L','T'};
                case 13
                    xlabel={'','0','','','','','5','','','','','10','','','','',''};
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
            delay=size(samples,3)/4*(obj.binSize/10)-5-obj.delayCorrection;
            
%             close all;

            samples=permute(samples,[1,3,2]);
            [pfbins,bnbins]=obj.getBins('delay',delay);
            samples(:,1)=mean(samples(:,pfbins),2)-mean(samples(:,bnbins),2);
            samples=sortrows(samples,1);

%             figure('Color','w','Position',[100,100,305,190]);
%             figure('Color','w','Position',[100,100,220,250]);
            figure('Color','w','Position',[100,100,285,235]);
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
            
            imagesc(flip(samples(:,pfbins)),[-3,3]);
            
%             imagesc(flip(samples([1:110,end-110:end],pfbins)),[-3,3]);
%             set(gca,'YTick',[50,100,110,250-119,300-119],'YTickLabel',[50,100,0,250,300]);
            
            [xtick,xtickLabel]=obj.getXTick(delay);
            set(gca,'XTick',xtick,'XTickLabel',xtickLabel,'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            
            
            obj.plotOdorEdge(delay);
            colormap('jet');

            xspan=xlim();
            
%             yspan=ylim();
%             dy=diff(yspan)*0.01;
%             fill([10/obj.binSize+0.5,20/obj.binSize,20/obj.binSize,10/obj.binSize],[110*dy,110*dy,120*dy,120*dy],'r','EdgeColor','none');
%             ylim(yspan);
%             if strcmpi(type,'odor')
                text(size(pfbins,2)/2,size(samples,1)*-0.09,'PF as sample','HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
%             elseif strcmpi(type,'correct')
%                 text(35,size(samples,1)*-0.05,'Correct trials','HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
%             end
            
%             text(-diff(xlim)*0.45,size(samples,1)/2,'Cell No.','Rotation',90,'VerticalAlignment','middle','HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');

            
            
            subplot('Position',[0.56,0.17,0.42,0.70]);
            %%%%%%%%%%%   ORIGINAL     %%%%%%%%%%%%%%%%%
            % imagesc(flip(samples(:,bnbins)),[-3,3]); %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            imagesc(flip(samples([1:110,end-110:end],bnbins)),[-3,3]); 
            
            set(gca,'YTick',[],'XTick',xtick,'XTickLabel',xtickLabel,'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            obj.plotOdorEdge(delay);
            colormap('jet');

            
            
            
%             if strcmpi(type,'odor')
                text(size(bnbins,2)/2,size(samples,1)*-0.09,'BN as sample','HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
%             elseif strcmpi(type,'correct')
%                 text(35,size(samples,1)*-0.05,'Incorrect trials','HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
%             end
            text(size(bnbins,2)*1.6,size(samples,1)/2,'Normalized Firing Rate','Rotation',270,'VerticalAlignment','middle','HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
            
%             text(xtick(end)*-0.3,size(samples,1)*1.2,'Time(s)','FontSize',10,'FontName','Helvetica');
            obj.writeFile(fileName);
        end

        function writeFile(obj,fileName)
                set(gcf,'PaperPositionMode','auto');
                savefig([fileName,'.fig']);
        end
    end
end