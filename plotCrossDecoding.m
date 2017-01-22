classdef plotCrossDecoding < handle
    properties
        binSize=0.5;
    end
    methods (Access=private)
        function plotOdorEdge(obj,delay)
                xx=[1,2,3,3.5]./obj.binSize;
                line([xx;xx],repmat(ylim()',1,4),'LineStyle',':','LineWidth',0.5,'Color','k');
        end
        
        function [pf1,pf2,bn1,bn2]=getSampleBins(obj,correctS,errorS,delay,repeat)
            chunk=(delay+4)/obj.binSize;
            trial=(delay+3)/obj.binSize;
            
            pf1=correctS(:,1:trial,repeat)';
            pf2=errorS(:,chunk+1:chunk+trial,repeat)';
            bn1=correctS(:,chunk*2+1:chunk*2+trial,repeat)';
            bn2=errorS(:,chunk*3+1:chunk*3+trial,repeat)';
        end
        
        
        function labels=getLabels(obj,delay)
                    labels={'','0','','','','','5',''};
        end
    end
    
    
    methods
        
        function [pb,pl]=plotDecoding(obj,correctS,errorS,filename)
%             delay=size(correctS,3)/4*obj.binSize-5;
            delay=4;
            delta=(delay+3)/obj.binSize;
            correctS=permute(correctS,[1,3,2]);
            errorS=permute(errorS,[1,3,2]);
            repeats=size(correctS,3);
            out=nan(delta,repeats,2);
            h=waitbar(0,'0');
            [pf1,~,~,~]=obj.getSampleBins(correctS,errorS,delay,1);
            bins=size(pf1,1);
            for bin=1:bins
                waitbar(bin/bins,h,sprintf('%d/%d',bin,bins));
                decoded=nan(repeats,1);
                shuffled=nan(repeats,1);
                %                 parfor repeat=1:repeats
                for repeat=1:repeats
                    
                    [pf1,pf2,bn1,bn2]=obj.getSampleBins(correctS,errorS,delay,repeat);
                    
                    if rand<0.5 % Use PF Test
                        corrPF=corrcoef(pf2(bin,:),pf1(bin,:));
                        corrBN=corrcoef(pf2(bin,:),bn1(bin,:));
                        decoded(repeat)=corrPF(1,2)>corrBN(1,2);
                        
                    else % Use BN Test
                        corrPF=corrcoef(bn2(bin,:),pf1(bin,:));
                        corrBN=corrcoef(bn2(bin,:),bn1(bin,:));
                        decoded(repeat)=corrBN(1,2)>corrPF(1,2);
                    end
                    
                    shuffled(repeat)=randsample([decoded(repeat),~decoded(repeat)],1);
                end
                out(bin,:,:)=[decoded,shuffled];
            end
            delete(h);
            
            %             close all;
%             figure('Color','w','Position',[100,100,350,500]);
            figure('Color','w','Position',[100,100,350,240]);
            subplot('Position',[0.17,0.17,0.8,0.75]);
            hold on
            
            decRec=out(:,:,1)';
            decShuffle=out(:,:,2)';
            
            m=@(mat) mean(mat);
            ciRec=bootci(100,m,decRec);
            ciShuffle=bootci(100,m,decShuffle);
            
            
            plotLength=(delay+3)/obj.binSize;
            
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ciRec(1,:)),(fliplr(ciRec(2,:)))],[1,0.8,0.8],'EdgeColor','none');
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ciShuffle(1,:)),(fliplr(ciShuffle(2,:)))],[0.8,0.8,0.8],'EdgeColor','none');
            
            hRec=plot([1:plotLength]-0.5*obj.binSize,(mean(out(:,:,1),2)),'-r','LineWidth',1);
            hShuffle=plot([1:plotLength]-0.5*obj.binSize,(mean(out(:,:,2),2)),'-k','LineWidth',1);
            
            
            
            
%             yspan=ylim();
%             set(gca,'YTick',0.25:0.25:1,'YTickLabel',{'25','50','75','100'},'XTick',0:1/obj.binSize:plotLength,'XTickLabel',obj.getLabels(delay),'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            set(gca,'YTick',0.25:0.25:1,'XTick',0:1/obj.binSize:plotLength,'XTickLabel',obj.getLabels(delay),'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            for i=1:delay+3
                p=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
                text((i-0.5)./obj.binSize,0.3,p2Str(p),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
            end
            
%             xlim([0,plotLength]);
%             ylim([0.25,1]);
            
            obj.plotOdorEdge(delay);
            
            legend([hRec, hShuffle],{'Recording Data','Shuffled Data'},'box','off','FontSize',10,'FontName','Helvetica');
            ylabel('Decoding accuracy (%)','FontName','Helvetica','FontSize',10);
            xlabel('Time since test onset (s)','FontName','Helvetica','FontSize',10);

            text(3/obj.binSize,1,['n = ',num2str(size(correctS,1))],'HorizontalAlignment','center','VerticalAlignment','top','FontSize',10,'FontName','Helvetica');
            
            i=1;
            pb=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
            i=(delay+3);
            pl=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));

            
            
            
            if exist('filename','var')
                %                                         pause;
                obj.writeFile(filename);
            end
        end
        

        function writeFile(obj,fileName)
                set(gcf,'PaperPositionMode','auto');
                savefig([fileName,'.fig']);
        end
    end
end