classdef matrixDecoding < handle
    properties
        binSize=0.5;
        alwaysLeft=false; % PF, Non-match
        alwaysRight=false;% BN, Match
    end
    methods (Access=private)
        function plotOdorEdge(obj,delay)
                xx=[1,2,2+delay,3+delay,4+delay,4.5+delay]./obj.binSize;
                line([xx;xx],repmat(ylim()',1,length(xx)),'LineStyle',':','LineWidth',0.5,'Color','k');
        end
        
        function [pf1,pf2,bn1,bn2,pf1a,bn1a,shuA,shuB]=getSampleBins(obj,correctS,errorS,shuffleS,delay,repeat)
            chunk=(delay+10)/obj.binSize;
            trial=(delay+9)/obj.binSize;
            
            pf1=correctS(:,1/obj.binSize+1:trial,repeat)';
            pf2=errorS(:,chunk+1/obj.binSize+1:chunk+trial,repeat)';
            pf1a=correctS(:,chunk+1/obj.binSize+1:chunk+trial,repeat)';
            bn1=correctS(:,chunk*2+1/obj.binSize+1:chunk*2+trial,repeat)';
            bn2=errorS(:,chunk*3+1/obj.binSize+1:chunk*3+trial,repeat)';
            bn1a=correctS(:,chunk*3+1/obj.binSize+1:chunk*3+trial,repeat)';
            shuA=shuffleS(:,chunk+1/obj.binSize+1:chunk+trial,repeat)';
            shuB=shuffleS(:,chunk*3+1/obj.binSize+1:chunk*3+trial,repeat)';
        end
        
        
        function labels=getLabels(obj,delay)
                    labels={'','0','','','','','5','','','','','10','','','','','15'};
        end
    end
    
    
    methods
        
        function [pb,pl]=plotDecoding(obj,correctS,errorS,shuffleS,delay,bonf)
            if obj.alwaysLeft && obj.alwaysRight
                disp('Fatal: cannot select side!');
                return;
            end
            
            
            if ~exist('bonf','var')
                bonf=1;
            end

            roi=(delay+8)/obj.binSize;
            correctS=permute(correctS,[1,3,2]);
            errorS=permute(errorS,[1,3,2]);
            shuffleS=permute(shuffleS,[1,3,2]);
            repeats=size(correctS,3);
            out=nan(roi,repeats,3);
            h=waitbar(0,'0');
            [pf1,~,~,~]=obj.getSampleBins(correctS,errorS,shuffleS,delay,1);
            bins=size(pf1,1);
            for bin=1:bins
                waitbar(bin/bins,h,sprintf('%d/%d',bin,bins));
                cross_decoded=nan(repeats,1);
                auto_decoded=nan(repeats,1);
                shuffled=nan(repeats,1);
                
                %                 parfor repeat=1:repeats
                for repeat=1:repeats
                    
%                     [pf1,pf2,bn1,bn2,pf1a,bn1a]=obj.getSampleBins(correctS,errorS,delay,repeat);
                    [pf1,pf2,bn1,bn2,pf1a,bn1a,shuA,shuB]=obj.getSampleBins(correctS,errorS,shuffleS,delay,repeat);
                    
                    if obj.alwaysLeft
                        selSide=0;
                    elseif obj.alwaysRight
                        selSide=1;
                    else
                        selSide=rand();
                    end
                    
                    
                    if selSide<0.5 % Use PF Test
                        corrPF=corrcoef(pf2(bin,:),pf1(bin,:));
                        corrBN=corrcoef(pf2(bin,:),bn1(bin,:));
                        
                        autoCorrPF=corrcoef(pf1a(bin,:),pf1(bin,:));
                        autoCorrBN=corrcoef(pf1a(bin,:),bn1(bin,:));
                        
                        cross_decoded(repeat)=corrPF(1,2)>corrBN(1,2);
                        auto_decoded(repeat)=autoCorrPF(1,2)>autoCorrBN(1,2);
                        
                        shufPF=corrcoef(shuA(bin,:),pf1(bin,:));
                        shufBN=corrcoef(shuA(bin,:),bn1(bin,:));
                        shuffled(repeat)=shufPF(1,2)>shufBN(1,2);
                        
                        
                        
                    else % Use BN Test
                        corrPF=corrcoef(bn2(bin,:),pf1(bin,:));
                        corrBN=corrcoef(bn2(bin,:),bn1(bin,:));
                        cross_decoded(repeat)=corrBN(1,2)>corrPF(1,2);
                        
                        autoCorrPF=corrcoef(bn1a(bin,:),pf1(bin,:));
                        autoCorrBN=corrcoef(bn1a(bin,:),bn1(bin,:));
                        auto_decoded(repeat)=autoCorrBN(1,2)>autoCorrPF(1,2);
                        
                        
                        shufPF=corrcoef(shuB(bin,:),pf1(bin,:));
                        shufBN=corrcoef(shuB(bin,:),bn1(bin,:));
                        shuffled(repeat)=shufBN(1,2)>shufPF(1,2);
                    end
                      

                   

                end
                out(bin,:,:)=[cross_decoded,shuffled,auto_decoded];
            end
            delete(h);
            
            %             close all;
%             figure('Color','w','Position',[100,100,350,500]);
            figure('Color','w','Position',[100,100,350,240]);
            subplot('Position',[0.17,0.17,0.8,0.75]);
            hold on
            
            decRec=out(:,:,1)';
            decShuffle=out(:,:,2)';
            decAuto=out(:,:,3)';
            
            m=@(mat) mean(mat);
            ciRec=bootci(100,m,decRec);
            ciShuffle=bootci(100,m,decShuffle);
            ciAuto=bootci(100,m,decAuto);
            
            plotLength=(delay+8)/obj.binSize;
            
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ciRec(1,:)),(fliplr(ciRec(2,:)))],[0.8,0.8,1],'EdgeColor','none');
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ciShuffle(1,:)),(fliplr(ciShuffle(2,:)))],[0.8,0.8,0.8],'EdgeColor','none');
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ciAuto(1,:)),(fliplr(ciAuto(2,:)))],[1,0.8,0.8],'EdgeColor','none');
            
            hRec=plot([1:plotLength]-0.5*obj.binSize,(mean(out(:,:,1),2)),'-b','LineWidth',1);
            hShuffle=plot([1:plotLength]-0.5*obj.binSize,(mean(out(:,:,2),2)),'-k','LineWidth',1);
            hAuto=plot([1:plotLength]-0.5*obj.binSize,(mean(out(:,:,3),2)),'-r','LineWidth',1);
            
            
            
            
%             yspan=ylim();
%             set(gca,'YTick',0.25:0.25:1,'YTickLabel',{'25','50','75','100'},'XTick',0:1/obj.binSize:plotLength,'XTickLabel',obj.getLabels(delay),'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            set(gca,'YTick',0.25:0.25:1,'XTick',0:1/obj.binSize:plotLength,'XTickLabel',obj.getLabels(delay),'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            
            
            
            for i=1:delay+8
                [pCrossShuf,~,statsBetween]=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
                [pAutoShuf,~,statsAuto]=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,3),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
                [pCrossAuto,~,statsCross]=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,3),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1));
                text((i-0.5)./obj.binSize,min(ylim())+0.05*diff(ylim()),p2Str(pCrossShuf*bonf),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica','Color','b');
                text((i-0.5)./obj.binSize,min(ylim())+0.15*diff(ylim()),p2Str(pAutoShuf*bonf),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica','Color','r');
                text((i-0.5)./obj.binSize,min(ylim())+0.25*diff(ylim()),p2Str(pCrossAuto*bonf),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica','Color','k');
                fprintf('cross Decoding\tBetween correct and error trials %ds\tWilcoxon rank-sum, Bonferroni correction adjusted\t\t%d\tnumber of neurons\t\tshadow is 95%% confidence interval from bootstrapping\t\tp = %.2e\t\tW = %.3f\n',i-7,size(correctS,1),pCrossAuto*bonf,statsCross.ranksum);
                fprintf('cross Decoding\tBetween correct and shuffled trials %ds\tWilcoxon rank-sum, Bonferroni correction adjusted\t\t%d\tnumber of neurons\t\tshadow is 95%% confidence interval from bootstrapping\t\tp = %.2e\t\tW = %.3f\n',i-7,size(correctS,1),pAutoShuf*bonf,statsAuto.ranksum);
                fprintf('cross Decoding\tBetween error and shuffled trials %ds\tWilcoxon rank-sum, Bonferroni correction adjusted\t\t%d\tnumber of neurons\t\tshadow is 95%% confidence interval from bootstrapping\t\tp = %.2e\t\tW = %.3f\n',i-7,size(correctS,1),pCrossShuf*bonf,statsBetween.ranksum);
                
                
                
            end
            
%             xlim([0,plotLength]);
%             ylim([0.25,1]);
            
            obj.plotOdorEdge(delay);
            
            legend([hAuto, hShuffle,hRec],{'Correct trials test','Shuffled Data','Incorrect trials test'},'box','off','FontSize',10,'FontName','Helvetica');
            ylabel('Decoding accuracy','FontName','Helvetica','FontSize',10);
            xlabel('Time (s)','FontName','Helvetica','FontSize',10);
            if delay==8
                xlim([0,16.5]/obj.binSize);
            end
            text(3/obj.binSize,1,['n = ',num2str(size(correctS,1))],'HorizontalAlignment','center','VerticalAlignment','top','FontSize',10,'FontName','Helvetica');
            
%             i=1;
%             pb=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1),...
%                 reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
%             i=(delay+2);
            i=7;
            p32=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,3),repeats/obj.binSize,1),...
                 reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
            p21=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
            p31=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,3),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1));
            
%             i=7;
            
            pb=max([p32,p21,p31]).*bonf;
            pl=p31.*bonf;
%             disp([pb,pl]);


%             xlim([10,24.5]);
            

        end
        
        function plotMerged(obj,correctS,errorS,delay,filename)
            counter=0;
            pb=0;
            while pb<0.05 && counter<100
                [pb,~]=obj.plotDecoding(correctS,errorS,delay,filename);
                if pb<0.05
                    close gcf
                    disp(pb);
                end
                counter=counter+1;
            end
                
        end
        
        function plotAveragedDecoding(obj,correctS,errorS,shuffleS,delay,bonf)
          
            if ~exist('bonf','var')
                bonf=1;
            end

            roi=(delay+8)/obj.binSize;
            correctS=permute(correctS,[1,3,2]);
            errorS=permute(errorS,[1,3,2]);
            shuffleS=permute(shuffleS,[1,3,2]);
            repeats=size(correctS,3);
            out=nan(roi,repeats,3);
            h=waitbar(0,'0');
            [pf1,~,~,~]=obj.getSampleBins(correctS,errorS,shuffleS,delay,1);
            bins=size(pf1,1);
            for bin=1:bins
                waitbar(bin/bins,h,sprintf('%d/%d',bin,bins));
                cross_decoded=nan(repeats,1);
                auto_decoded=nan(repeats,1);
                shuffled=nan(repeats,1);
                
                %                 parfor repeat=1:repeats
                for repeat=1:repeats
                    
%                     [pf1,pf2,bn1,bn2,pf1a,bn1a]=obj.getSampleBins(correctS,errorS,delay,repeat);
                    [pf1,pf2,bn1,bn2,pf1a,bn1a,shuA,shuB]=obj.getSampleBins(correctS,errorS,shuffleS,delay,repeat);
                    
                    if obj.alwaysLeft
                        selSide=0;
                    elseif obj.alwaysRight
                        selSide=1;
                    else
                        selSide=rand();
                    end
                    
                    
                    if selSide<0.5 % Use PF Test
                        corrPF=corrcoef(pf2(bin,:),pf1(bin,:));
                        corrBN=corrcoef(pf2(bin,:),bn1(bin,:));
                        
                        autoCorrPF=corrcoef(pf1a(bin,:),pf1(bin,:));
                        autoCorrBN=corrcoef(pf1a(bin,:),bn1(bin,:));
                        
                        cross_decoded(repeat)=corrPF(1,2)>corrBN(1,2);
                        auto_decoded(repeat)=autoCorrPF(1,2)>autoCorrBN(1,2);
                        
                        shufPF=corrcoef(shuA(bin,:),pf1(bin,:));
                        shufBN=corrcoef(shuA(bin,:),bn1(bin,:));
                        shuffled(repeat)=shufPF(1,2)>shufBN(1,2);
                        
                        
                        
                    else % Use BN Test
                        corrPF=corrcoef(bn2(bin,:),pf1(bin,:));
                        corrBN=corrcoef(bn2(bin,:),bn1(bin,:));
                        cross_decoded(repeat)=corrBN(1,2)>corrPF(1,2);
                        
                        autoCorrPF=corrcoef(bn1a(bin,:),pf1(bin,:));
                        autoCorrBN=corrcoef(bn1a(bin,:),bn1(bin,:));
                        auto_decoded(repeat)=autoCorrBN(1,2)>autoCorrPF(1,2);
                        
                        
                        shufPF=corrcoef(shuB(bin,:),pf1(bin,:));
                        shufBN=corrcoef(shuB(bin,:),bn1(bin,:));
                        shuffled(repeat)=shufBN(1,2)>shufPF(1,2);
                    end
                      

                   

                end
                out(bin,:,:)=[cross_decoded,shuffled,auto_decoded];
            end
            delete(h);
            
            %             close all;
%             figure('Color','w','Position',[100,100,350,500]);
            figure('Color','w','Position',[100,100,350,240]);
            subplot('Position',[0.17,0.17,0.8,0.75]);
            hold on
            
            decRec=out(:,:,1)';
            decShuffle=out(:,:,2)';
            decAuto=out(:,:,3)';
            
            m=@(mat) mean(mat);
            ciRec=bootci(100,m,decRec);
            ciShuffle=bootci(100,m,decShuffle);
            ciAuto=bootci(100,m,decAuto);
            
            plotLength=(delay+8)/obj.binSize;
            
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ciRec(1,:)),(fliplr(ciRec(2,:)))],[0.8,0.8,1],'EdgeColor','none');
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ciShuffle(1,:)),(fliplr(ciShuffle(2,:)))],[0.8,0.8,0.8],'EdgeColor','none');
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ciAuto(1,:)),(fliplr(ciAuto(2,:)))],[1,0.8,0.8],'EdgeColor','none');
            
            hRec=plot([1:plotLength]-0.5*obj.binSize,(mean(out(:,:,1),2)),'-b','LineWidth',1);
            hShuffle=plot([1:plotLength]-0.5*obj.binSize,(mean(out(:,:,2),2)),'-k','LineWidth',1);
            hAuto=plot([1:plotLength]-0.5*obj.binSize,(mean(out(:,:,3),2)),'-r','LineWidth',1);
            
            
            
            
%             yspan=ylim();
%             set(gca,'YTick',0.25:0.25:1,'YTickLabel',{'25','50','75','100'},'XTick',0:1/obj.binSize:plotLength,'XTickLabel',obj.getLabels(delay),'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            set(gca,'YTick',0.25:0.25:1,'XTick',0:1/obj.binSize:plotLength,'XTickLabel',obj.getLabels(delay),'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            
            
            
            for i=1:delay+8
                [pCrossShuf,~,statsBetween]=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
                [pAutoShuf,~,statsAuto]=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,3),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
                [pCrossAuto,~,statsCross]=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,3),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1));
                text((i-0.5)./obj.binSize,min(ylim())+0.05*diff(ylim()),p2Str(pCrossShuf*bonf),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica','Color','b');
                text((i-0.5)./obj.binSize,min(ylim())+0.15*diff(ylim()),p2Str(pAutoShuf*bonf),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica','Color','r');
                text((i-0.5)./obj.binSize,min(ylim())+0.25*diff(ylim()),p2Str(pCrossAuto*bonf),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica','Color','k');
                fprintf('cross Decoding\tBetween correct and error trials %ds\tWilcoxon rank-sum, Bonferroni correction adjusted\t\t%d\tnumber of neurons\t\tshadow is 95%% confidence interval from bootstrapping\t\tp = %.2e\t\tW = %.3f\n',i-7,size(correctS,1),pCrossAuto*bonf,statsCross.ranksum);
                fprintf('cross Decoding\tBetween correct and shuffled trials %ds\tWilcoxon rank-sum, Bonferroni correction adjusted\t\t%d\tnumber of neurons\t\tshadow is 95%% confidence interval from bootstrapping\t\tp = %.2e\t\tW = %.3f\n',i-7,size(correctS,1),pAutoShuf*bonf,statsAuto.ranksum);
                fprintf('cross Decoding\tBetween error and shuffled trials %ds\tWilcoxon rank-sum, Bonferroni correction adjusted\t\t%d\tnumber of neurons\t\tshadow is 95%% confidence interval from bootstrapping\t\tp = %.2e\t\tW = %.3f\n',i-7,size(correctS,1),pCrossShuf*bonf,statsBetween.ranksum);
                
                
                
            end
            
%             xlim([0,plotLength]);
%             ylim([0.25,1]);
            
            obj.plotOdorEdge(delay);
            
            legend([hAuto, hShuffle,hRec],{'Correct trials test','Shuffled Data','Incorrect trials test'},'box','off','FontSize',10,'FontName','Helvetica');
            ylabel('Decoding accuracy','FontName','Helvetica','FontSize',10);
            xlabel('Time (s)','FontName','Helvetica','FontSize',10);
            if delay==8
                xlim([0,16.5]/obj.binSize);
            end
            text(3/obj.binSize,1,['n = ',num2str(size(correctS,1))],'HorizontalAlignment','center','VerticalAlignment','top','FontSize',10,'FontName','Helvetica');
            
%             i=1;
%             pb=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1),...
%                 reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
%             i=(delay+2);
            i=7;
            p32=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,3),repeats/obj.binSize,1),...
                 reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
            p21=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
            p31=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,3),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1));
            
%             i=7;
            
            pb=max([p32,p21,p31]).*bonf;
            pl=p31.*bonf;

            
        end

        
% 
%         function writeFile(obj,fileName)
%                 set(gcf,'PaperPositionMode','auto');
%                 savefig([fileName,'.fig']);
%         end
    end
end