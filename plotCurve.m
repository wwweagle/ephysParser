classdef plotCurve < handle
    properties
        binSize=0.5;
        per100=false;
        half=false;
    end
    methods (Access=private)
        function plotOdorEdge(obj,delay)
            if delay==8
%                 xx=[1,2,4,5.5,10,11]./obj.binSize;
                xx=[1,2,10,11]./obj.binSize;
            elseif delay==13
                xx=[1,2,6,7.5,15,16]./obj.binSize;
            else
                xx=[1,2,6,7]./obj.binSize;
            
                
            end
            for curX=1:length(xx)
                line([xx(curX),xx(curX)],ylim(),'LineStyle',':','LineWidth',0.5,'Color','k');
            end
        end
        
        function [pf1,pf2,bn1,bn2]=getSampleBins(obj,samples,delay,repeat)
            start=1/obj.binSize+1;
            stop=(delay+4)/obj.binSize;
            delta=(delay+5)/obj.binSize;
            SUCount=size(samples,1);
            if obj.per100 && SUCount>100
                selectedSU=randperm(SUCount,100);
            elseif obj.half
                selectedSU=randperm(SUCount,round(SUCount/2));
            else
                selectedSU=1:SUCount;
            end
            pf1=samples(selectedSU,start:stop,repeat)';
            pf2=samples(selectedSU,start+delta:stop+delta,repeat)';
            bn1=samples(selectedSU,start+delta*2:stop+delta*2,repeat)';
            bn2=samples(selectedSU,start+delta*3:stop+delta*3,repeat)';
        end
        
        function [pf1s,pf2s,bn1s,bn2s]=getScoreBins(obj,score,delay,pcs)
            delta=(delay+3)/obj.binSize;
            pf1s=score(1:delta,pcs);
            pf2s=score(delta+1:delta*2,pcs);
            bn1s=score(delta*2+1:delta*3,pcs);
            bn2s=score(delta*3+1:delta*4,pcs);
        end
        
        function labels=getLabels(obj,delay)
            switch delay
                case 4
                    labels={'','0','','','','','5',''};
                case 5
                    labels={'','0','','','','','','6',''};
                case 8
                    labels={'','0','','','','','5','','','','','10'};
                case 13
                    labels={'','0','','','','','5','','','','','10','','','','',''};
                otherwise
                    labels={'','0','','','','','5','','','','','10'};
                    
            end
        end
    end
    
    
    methods
        
        
        function [pp, dist,cis]=plotTrajectory(obj,samples,filename,pcs,bonf)
            obj.half=false;
            %             path(path,'I:\behavior\reports\z');
            delay=size(samples,3)/4*obj.binSize-5;
            delta=(delay+3)/obj.binSize;
            samples=permute(samples,[1,3,2]);
            repeats=size(samples,3);
            out=nan(delta,3,repeats);
            h=waitbar(0,'0');
            for repeat=1:repeats
                [pf1,pf2,bn1,bn2]=obj.getSampleBins(samples,delay,repeat);
%                 [~,score,latent]=pca([(pf1+pf2)./2;(bn1+bn2)./2]);
                [~,score,latent]=pca([pf1;pf2;bn1;bn2]);
                [pf1s,pf2s,bn1s,bn2s]=obj.getScoreBins(score,delay,pcs);
                out(:,1,repeat)=sqrt(sum((pf1s-pf2s).^2,2));
                out(:,2,repeat)=sqrt(sum((pf1s-bn2s).^2,2));
                out(:,3,repeat)=sqrt(sum((bn1s-bn2s).^2,2));
                waitbar(repeat/repeats,h,num2str(repeat/repeats*100));
            end
            delete(h);
            dist=permute(out,[3,1,2]);
            %             close all;

            
            
            m=@(mat) mean(mat);
            cis=bootci(100,m,dist);
            ci1=permute(cis(:,:,:,1),[1 3 2]);
            ci2=permute(cis(:,:,:,2),[1 3 2]);
            ci3=permute(cis(:,:,:,3),[1 3 2]);
            
            refBins=1:1/obj.binSize;
%             refBins=5/obj.binSize+1:6/obj.binSize;
            normalRef=permute(mean(mean(dist(:,refBins,:),1),2),[3,1,2])./100;
            
            plotLength=delta;
            %             fill([1:plotLength,plotLength:-1:1],[smooth(ci1(1,:))',smooth(fliplr(ci1(2,:)))']./normalRef(1),[0.8,0.8,1],'EdgeColor','none');
            %             fill([1:plotLength,plotLength:-1:1],[smooth(ci2(1,:))',smooth(fliplr(ci2(2,:)))']./normalRef(2),[1,0.8,0.8],'EdgeColor','none');
            %             fill([1:plotLength,plotLength:-1:1],[smooth(ci3(1,:))',smooth(fliplr(ci3(2,:)))']./normalRef(3),[0.8,0.8,0.8],'EdgeColor','none');
            %
            %             hpp=plot(smooth(mean(dist(:,:,1)))./normalRef(1),'-b','LineWidth',1);
            %             hpb=plot(smooth(mean(dist(:,:,2)))./normalRef(2),'-r','LineWidth',1);
            %             hbb=plot(smooth(mean(dist(:,:,3)))./normalRef(3),'-k','LineWidth',1);
%             figure('Color','w','Position',[100,100,350,500]);
            figure('Color','w','Position',[100,100,350,240]);
            subplot('Position',[0.17,0.17,0.8,0.75]);
            hold on
            
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ci1(1,:)),(fliplr(ci1(2,:)))]./normalRef(1),[0.8,0.8,1],'EdgeColor','none');
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ci2(1,:)),(fliplr(ci2(2,:)))]./normalRef(2),[1,0.8,0.8],'EdgeColor','none');
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ci3(1,:)),(fliplr(ci3(2,:)))]./normalRef(3),[0.8,0.8,0.8],'EdgeColor','none');
            
            hpp=plot((1:plotLength)-0.5*obj.binSize,(mean(dist(:,:,1)))./normalRef(1),'-b','LineWidth',1);
            hpb=plot((1:plotLength)-0.5*obj.binSize,(mean(dist(:,:,2)))./normalRef(2),'-r','LineWidth',1);
            hbb=plot((1:plotLength)-0.5*obj.binSize,(mean(dist(:,:,3)))./normalRef(3),'-k','LineWidth',1);
            %
%             yspan=[50,300];
%             ylim(yspan);
            yspan=ylim();

            set(gca,'XTick',0:1/obj.binSize:plotLength,'XTickLabel',obj.getLabels(delay),'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            tp=nan(delay+3,1);
            if ~exist('bonf','var')
                bonf=1;
            end
            
            for i=1:delay+3
                p=anova1([reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,1)./normalRef(1),100/obj.binSize,1), ...
                    reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,2)./normalRef(2),100/obj.binSize,1), ...
                    reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,3)./normalRef(3),100/obj.binSize,1)],[],'off');
%                   p=ranksum([reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,1)./normalRef(1),100/obj.binSize,1);reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,1)./normalRef(1),100/obj.binSize,1)],...
%                     [reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,2)./normalRef(2),100/obj.binSize,1); ...
%                     reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,3)./normalRef(3),100/obj.binSize,1)]);
                text((i-0.5)/obj.binSize,70,p2Str(p*bonf),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
                tp(i)=p;
            end
            
            xlim([0,plotLength]);
            
            obj.plotOdorEdge(delay);
            
%             text(-0.17*plotLength,mean(yspan),'Normalized','HorizontalAlignment','center','Rotation',90,'FontSize',10,'FontName','Helvetica');
%             text(-0.12*plotLength,mean(yspan),'distance (%)','HorizontalAlignment','center','Rotation',90,'FontSize',10,'FontName','Helvetica');
            ylabel('Normalized distance (%)','HorizontalAlignment','center','Rotation',90,'FontSize',10,'FontName','Helvetica');
            %             text(-3,yspan(1)+(yspan(2)-yspan(1))*0.5,'(z-score)','HorizontalAlignment','center','Rotation',90,'FontSize',10,'FontName','Helvetica');

                
            text(3/obj.binSize,yspan(1)+(yspan(2)-yspan(1))*0.95,['n = ',num2str(size(pf1,2))],'HorizontalAlignment','center','VerticalAlignment','top','FontSize',10,'FontName','Helvetica');
            
            
            pp=min([tp(1),tp(end),tp(end-1),tp(end-2)]);
           
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
           obj.half=true; 
           for repeat=1:repeats
                [pf1,pf2,bn1,bn2]=obj.getSampleBins(samples,delay,repeat);
%                 [~,score,latent]=pca([(pf1+pf2)./2;(bn1+bn2)./2]);
                [~,score,latent]=pca([pf1;pf2;bn1;bn2]);
                [pf1s,pf2s,bn1s,bn2s]=obj.getScoreBins(score,delay,pcs);
                out(:,1,repeat)=sqrt(sum((pf1s-pf2s).^2,2));
                out(:,2,repeat)=sqrt(sum((pf1s-bn2s).^2,2));
                out(:,3,repeat)=sqrt(sum((bn1s-bn2s).^2,2));
            end

            dist=permute(out,[3,1,2]);
            %             close all;

            
            
            m=@(mat) mean(mat);
            cis=bootci(100,m,dist);
            ci2=permute(cis(:,:,:,2),[1 3 2]);
           
            normalRef=permute(mean(mean(dist(:,1:1/obj.binSize,:),1),2),[3,1,2])./100;
            
%             fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ci1(1,:)),(fliplr(ci1(2,:)))]./normalRef(1),[0.8,0.8,1],'EdgeColor','none');
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ci2(1,:)),(fliplr(ci2(2,:)))]./normalRef(2),[1,0.8,0.8],'EdgeColor','none');
%             fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ci3(1,:)),(fliplr(ci3(2,:)))]./normalRef(3),[0.8,0.8,0.8],'EdgeColor','none');
            
%             hpp=plot((1:plotLength)-0.5*obj.binSize,(mean(dist(:,:,1)))./normalRef(1),'-b','LineWidth',1);
            hpbh=plot((1:plotLength)-0.5*obj.binSize,(mean(dist(:,:,2)))./normalRef(2),':r','LineWidth',1);
%             hbb=plot((1:plotLength)-0.5*obj.binSize,(mean(dist(:,:,3)))./normalRef(3),'-k','LineWidth',1);

            for i=1:delay+3
                p=anova1([reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,1)./normalRef(1),100/obj.binSize,1), ...
                    reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,2)./normalRef(2),100/obj.binSize,1), ...
                    reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,3)./normalRef(3),100/obj.binSize,1)],[],'off');
%                   p=ranksum([reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,1)./normalRef(1),100/obj.binSize,1);reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,1)./normalRef(1),100/obj.binSize,1)],...
%                     [reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,2)./normalRef(2),100/obj.binSize,1); ...
%                     reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,3)./normalRef(3),100/obj.binSize,1)]);
                text((i-0.5)/obj.binSize,60,p2Str(p*bonf),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
                tp(i)=p;
            end



            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            

            
            if exist('filename','var')
                if numel(regexpi(filename,'byodor'))>0
                    legend([hpb,hpbh, hpp,hbb],{'Sample PF vs. BN','Sample, 1/2 neurons','Within PF','Within BN'},'box','off','FontSize',10,'FontName','Helvetica');
                    %                     pause;
                    obj.writeFile(filename);
                elseif numel(regexpi(filename,'bycorrect'))>0
                    legend([hpb,hpp,hbb],{'Correct vs. incorrect','Within correct','Within incorrect'},'box','off');
                    %                     pause;
                    obj.writeFile(filename);
                end
            end
        end
        
        function subPlot(obj,plotLength,ci1,ci2,ci3,dist,normalRef,delay)
            hold on;
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ci1(1,:)),(fliplr(ci1(2,:)))]./normalRef(1),[0.8,0.8,1],'EdgeColor','none');
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ci2(1,:)),(fliplr(ci2(2,:)))]./normalRef(2),[1,0.8,0.8],'EdgeColor','none');
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ci3(1,:)),(fliplr(ci3(2,:)))]./normalRef(3),[0.8,0.8,0.8],'EdgeColor','none');
            
            hpp=plot((1:plotLength)-0.5*obj.binSize,(mean(dist(:,:,1)))./normalRef(1),'-b','LineWidth',1);
            hpb=plot((1:plotLength)-0.5*obj.binSize,(mean(dist(:,:,2)))./normalRef(2),'-r','LineWidth',1);
            hbb=plot((1:plotLength)-0.5*obj.binSize,(mean(dist(:,:,3)))./normalRef(3),'-k','LineWidth',1);
            %
            yspan=[50,600];
            ylim(yspan);
            set(gca,'XTick',0:1/obj.binSize:plotLength,'XTickLabel',obj.getLabels(delay),'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            tp=nan(delay+3,1);
%             for i=1:delay+3
             for i=1:delay+2
                p=anova1([reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,1)./normalRef(1),100/obj.binSize,1), ...
                    reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,2)./normalRef(2),100/obj.binSize,1), ...
                    reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,3)./normalRef(3),100/obj.binSize,1)],[],'off');
%                   p=ranksum([reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,1)./normalRef(1),100/obj.binSize,1);reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,1)./normalRef(1),100/obj.binSize,1)],...
%                     [reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,2)./normalRef(2),100/obj.binSize,1); ...
%                     reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,3)./normalRef(3),100/obj.binSize,1)]);
                text((i-0.5)/obj.binSize,70,p2Str(p),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
                tp(i)=p;
            end
            
            xlim([0,plotLength]);
            
            obj.plotOdorEdge(delay);
            legend([hpb,hpp,hbb],{'PF-BN','PF-PF','BN-BN'},'FontSize',12,'Location','none','Position',[0.66,0.88,0.1,0.1]);
            
%             text(-0.17*plotLength,mean(yspan),'Normalized','HorizontalAlignment','center','Rotation',90,'FontSize',10,'FontName','Helvetica');
%             text(-0.12*plotLength,mean(yspan),'distance (%)','HorizontalAlignment','center','Rotation',90,'FontSize',10,'FontName','Helvetica');
            
%             text(-3,yspan(1)+(yspan(2)-yspan(1))*0.5,'(z-score)','HorizontalAlignment','center','Rotation',90,'FontSize',10,'FontName','Helvetica');
%             text(3/obj.binSize,yspan(1)+(yspan(2)-yspan(1))*0.95,['n = ',num2str(size(samples,1))],'HorizontalAlignment','center','VerticalAlignment','top','FontSize',10,'FontName','Helvetica');
            
            
%             pp=min([tp(1),tp(end),tp(end-1),tp(end-2)]);
        end
        
        
        function [pp, dist,cis]=genTraj(obj,samples)
            delay=size(samples,3)/4*obj.binSize-5;
            samples=permute(samples,[1,3,2]);
            repeats=size(samples,3);
            out=nan((delay+3)/obj.binSize,3,repeats);
            
            for repeat=1:repeats
                [pf1,pf2,bn1,bn2]=obj.getSampleBins(samples,delay,repeat);
                [~,score,~]=pca([pf1;pf2;bn1;bn2]);
                [pf1s,pf2s,bn1s,bn2s]=obj.getScoreBins(score,delay);
                out(:,1,repeat)=sqrt(sum((pf1s-pf2s).^2,2));
                out(:,2,repeat)=sqrt(sum((pf1s-bn1s).^2,2));
                out(:,3,repeat)=sqrt(sum((bn1s-bn2s).^2,2));
                
            end
            
            dist=permute(out,[3,1,2]);
            normalRef=permute(mean(mean(dist(:,1:5,:),1),2),[3,1,2])./100;
            m=@(mat) mean(mat);
            cis=bootci(100,m,dist);
            
            tp=nan(delay+3,1);
            for i=1:delay+3
                p=anova1([reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,1)./normalRef(1),100/obj.binSize,1),...
                    reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,2)./normalRef(2),100/obj.binSize,1),...
                    reshape(dist(:,(i-1)/obj.binSize+1:i/obj.binSize,3)./normalRef(3),100/obj.binSize,1)],[],'off');
                text((i-0.5)/obj.binSize,20,p2Str(p),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
                tp(i)=p;
            end
            pp=min([tp(end),tp(end-1),tp(end-2)]);
            
        end
        
        
        function [pb,pl]=plotDecoding(obj,samples,filename)
            delay=size(samples,3)/4*obj.binSize-5;
            delta=(delay+3)/obj.binSize;
            samples=permute(samples,[1,3,2]);
            repeats=size(samples,3);
            out=nan(delta,repeats,2);
            h=waitbar(0,'0');
            [pf1,~,~,~]=obj.getSampleBins(samples,delay,1);
            bins=size(pf1,1);
            for bin=1:bins
                waitbar(bin/bins,h,sprintf('%d/%d',bin,bins));
                decoded=nan(repeats,1);
                shuffled=nan(repeats,1);
                %                 parfor repeat=1:repeats
                for repeat=1:repeats
                    
                    [pf1,pf2,bn1,bn2]=obj.getSampleBins(samples,delay,repeat);
                    
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
            
            xlim([0,plotLength]);
            ylim([0.25,1]);
            
            obj.plotOdorEdge(delay);
            
            legend([hRec, hShuffle],{'Recording Data','Shuffled Data'},'box','off','FontSize',10,'FontName','Helvetica');
            ylabel('Decoding Accuracy','HorizontalAlignment','center','Rotation',90,'FontSize',10,'FontName','Helvetica');
            text(3/obj.binSize,1,['n = ',num2str(size(samples,1))],'HorizontalAlignment','center','VerticalAlignment','top','FontSize',10,'FontName','Helvetica');
            
            %             pp=min([ranksum(reshape(out(5-4:5,:,1),repeats*5,1),reshape(out(5-4:5,:,2),repeats*5,1)),...
            %                 ranksum(reshape(out((delay+3)*5-4:(delay+3)*5,:,1),repeats*5,1),reshape(out((delay+3)*5-4:(delay+3)*5,:,2),repeats*5,1))]);
            i=1;
            pb=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
            i=(delay+3);
            pl=ranksum(reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,1),repeats/obj.binSize,1),...
                reshape(out((i-1)/obj.binSize+1:i/obj.binSize,:,2),repeats/obj.binSize,1));
            
            %             pp=ranksum(reshape(out(5-4:5,:,1),repeats*5,1),reshape(out(5-4:5,:,2),repeats*5,1));
            %
            
            
            
            if exist('filename','var')
                %                                         pause;
                obj.writeFile(filename);
            end
        end
        
        
        function plotCorrectVIncorrect(obj,trajectoryA,trajectoryB)
            % load file4s;
            % trajectoryA=sampleByType(file4s,'correctZA','Average2Hz',-2,0.2,7,[1,0;1,0],100,1);
            % trajectoryB=sampleByType(file4s,'correctZB','Average2Hz',-2,0.2,7,[1,0;1,0],100,1);
            
            
            
            trialLength=size(trajectoryA,3)/4;
            plotLength=trialLength-10;
            
            distT=nan(plotLength,100);
            
            delay=(trialLength-1)*obj.binSize;
            
            for rpt=1:100
                for bin=1/obj.binSize:1/obj.binSize+plotLength
                    distT(bin-1/obj.binSize,rpt)=sqrt(sum((trajectoryA(:,rpt,bin)-trajectoryB(:,rpt,bin)).^2));
                end
            end
            
            distF=nan(7/obj.binSize,100);
            for rpt=1:100
                for bin=1/obj.binSize+1+2*trialLength:1/obj.binSize+plotLength+2*trialLength
                    distF(bin-1/obj.binSize-2*trialLength,rpt)=sqrt(sum((trajectoryA(:,rpt,bin)-trajectoryB(:,rpt,bin)).^2));
                end
            end
            
            %             close all;
            figure('Color','w','Position',[100,100,350,500]);
            subplot('Position',[0.17,0.17,0.8,0.75]);
            hold on
            
            %             normT=mean(reshape(distT(1:5,:),500,1))/100;
            %             normF=mean(reshape(distF(1:5,:),500,1))/100;
            
            %             normT=1;
            %             normF=1;
            %
            cit=bootci(100,@mean,distT');
            cif=bootci(100,@mean,distF');
            
            fill([1:plotLength,plotLength:-1:1],[cif(1,:),fliplr(cif(2,:))]./normF,[0.8,0.8,0.8],'EdgeColor','none');
            fill([1:plotLength,plotLength:-1:1],[cit(1,:),fliplr(cit(2,:))]./normT,[1,0.8,0.8],'EdgeColor','none');
            
            hf=plot(mean(distF,2)./normF,'-k');
            ht=plot(mean(distT,2)./normT,'-r');
            
            for i=1:plotLength/5
                p=ranksum(reshape(distT((i-1)/obj.binSize+1:i/obj.binSize,:),100/obj.binSize,1)./normT,reshape(distF((i-1)/obj.binSize+1:i/obj.binSize,:),100/obj.binSize,1)./normF);
                text((i-0.5)/obj.binSize,80,p2Str(p),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
                %                 fprintf('%f,',p);
            end
            
            yspan=ylim();
            xlim([1,plotLength]);
            ylim([75,yspan(2)]);
            
            obj.plotOdorEdge(delay);
            set(gca,'XTick',0:5:plotLength,'XTickLabel',obj.getLabels(delay),'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            legend([ht, hf],{'Correct','Incorrect'},'box','off','FontSize',10,'FontName','Helvetica');
            text(3/obj.binSize,yspan(2),['n = ',num2str(size(trajectoryA,1))],'HorizontalAlignment','center','VerticalAlignment','top','FontSize',10,'FontName','Helvetica');
%             yspan=ylim();
            ylabel('Normalized','HorizontalAlignment','center','Rotation',90,'FontSize',10,'FontName','Helvetica');

            
        end
        
        function plotCorrectVIncorrectPC(obj,trajectoryA,trajectoryB)
            % load file4s;
            % trajectoryA=sampleByType(file4s,'correctZA','Average2Hz',-2,0.2,7,[1,0;1,0],100,1);
            % trajectoryB=sampleByType(file4s,'correctZB','Average2Hz',-2,0.2,7,[1,0;1,0],100,1);
            
            
            
            trialLength=size(trajectoryA,3)/4;
            plotLength=trialLength--2/obj.binSize;
            
            %             distT=nan(plotLength,100);
            repeats=size(trajectoryA,2);
            
            delay=(trialLength-1)*obj.binSize;
            
            out=nan(delay*5+15,3,repeats);
            
            
            
            for repeat=1:repeats
                pfc=trajectoryA(:,repeat,6:5+plotLength);
                bnc=trajectoryB(:,repeat,6:5+plotLength);
                pfi=trajectoryA(:,repeat,6+trialLength*2:5+plotLength+trialLength*2);
                bni=trajectoryB(:,repeat,6+trialLength*2:5+plotLength+trialLength*2);
                [~,score,~]=pca(permute(cat(3,pfc,bnc,pfi,bni),[1,3,2])');
                [pfc,bnc,pfi,bni]=obj.getScoreBins(score,delay);
                out(:,1,repeat)=sqrt(sum((pfc-bnc).^2,2));
                out(:,2,repeat)=sqrt(sum((pfi-bni).^2,2));
            end
            
            dist=permute(out,[3,1,2]);
            
            %             close all;
            figure('Color','w','Position',[100,100,350,500]);
            subplot('Position',[0.17,0.17,0.8,0.75]);
            hold on
            
            
            normalRef=permute(mean(mean(dist(:,1:5,:),1),2),[3,1,2])./100;
            %             normalRef=[1,1,1];
            
            
            m=@(mat) mean(mat);
            cis=bootci(100,m,dist);
            cic=permute(cis(:,:,:,1),[1 3 2]);
            cif=permute(cis(:,:,:,2),[1 3 2]);
            
            
            plotLength=delay*5+15;
            fill([1:plotLength,plotLength:-1:1],[cic(1,:),fliplr(cic(2,:))]./normalRef(1),[1,0.8,0.8],'EdgeColor','none');
            fill([1:plotLength,plotLength:-1:1],[cif(1,:),fliplr(cif(2,:))]./normalRef(2),[0.8,0.8,0.8],'EdgeColor','none');
            
            
            hc=plot(mean(dist(:,:,1))./normalRef(1),'-r');
            hi=plot(mean(dist(:,:,2))./normalRef(2),'-k');
            
            yspan=ylim();
            set(gca,'XTick',0:5:plotLength,'XTickLabel',obj.getLabels(delay),'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            tp=nan(delay+3,1);
            for i=1:delay+3
                p=ranksum(reshape(dist(:,i*5-4:i*5,1)./normalRef(1),500,1),reshape(dist(:,i*5-4:i*5,2)./normalRef(2),500,1));
                text(i*5-2.5,70,p2Str(p),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
                tp(i)=p;
            end
            
            xlim([1,plotLength]);
            
            obj.plotOdorEdge(delay);
            
            
            set(gca,'XTick',0:5:plotLength,'XTickLabel',obj.getLabels(delay),'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            legend([hc, hi],{'Correct','Incorrect'},'box','off','FontSize',10,'FontName','Helvetica');
            text(15,yspan(2),['n = ',num2str(size(trajectoryA,1))],'HorizontalAlignment','center','VerticalAlignment','top','FontSize',10,'FontName','Helvetica');
            yspan=ylim();
            ylim([60,250]);
            yspan=ylim();
            text(-0.17*plotLength,mean(yspan),'Normalized','HorizontalAlignment','center','Rotation',90,'FontSize',10,'FontName','Helvetica');
            text(-0.12*plotLength,mean(yspan),'PF-BN distance (%)','HorizontalAlignment','center','Rotation',90,'FontSize',10,'FontName','Helvetica');
            
        end
        
        
        function writeFile(obj,fileName)
%             towrite=questdlg('Save File ?','Save File');
%             if strcmpi(towrite,'yes')
                set(gcf,'PaperPositionMode','auto');
                savefig([fileName,'.fig']);
%             end
        end
        
        
        function out=plotDecodMat(obj,samples,filename)
            delay=size(samples,3)/4*obj.binSize-5;
            delta=(delay+3)*obj.binSize;
            samples=permute(samples,[1,3,2]);
            repeats=size(samples,3);
            out=nan(delta,delta,repeats);
            %             h=waitbar(0,'0');
            [pf1,~,~,~]=obj.getSampleBins(samples,delay,1);
            bins=size(pf1,1);
            parfor horiBin=1:bins
                for vertBin=1:bins
                    %                     waitbar(((horiBin-1)*bins+vertBin)/(bins*bins),h,sprintf('%d/%d',((horiBin-1)*bins+vertBin),bins*bins));
                    decoded=nan(repeats,1);
                    for repeat=1:repeats
                        [pf1,pf2,bn1,bn2]=obj.getSampleBins(samples,delay,repeat);
                        
                        if rand<0.5 % Use PF Test
                            corrPF=corrcoef(pf2(horiBin,:),pf1(vertBin,:));
                            corrBN=corrcoef(pf2(horiBin,:),bn1(vertBin,:));
                            decoded(repeat)=corrPF(1,2)>corrBN(1,2);
                            
                        else % Use BN Test
                            corrPF=corrcoef(bn2(horiBin,:),pf1(vertBin,:));
                            corrBN=corrcoef(bn2(horiBin,:),bn1(vertBin,:));
                            decoded(repeat)=corrBN(1,2)>corrPF(1,2);
                        end
                    end
                    
                    out(horiBin,vertBin,:)=decoded;
                end
            end
%             close all;
            figure('Color','w','Position',[100,100,410,300]);
            hold on
            mout=mean(out,3);
            imagesc(mout,[0.4,0.7]);
            colormap('jet');
            colorbar;
            xspan=[0.5,11/obj.binSize+0.5];
            yspan=[0.5,11/obj.binSize+0.5];
            xlim(xspan);
            ylim(yspan);
            
            xy=[1,2,4,5.5,10,11]./obj.binSize;
            for i=1:length(xy)
                line([xy(i),xy(i)],yspan,'LineStyle',':','LineWidth',0.5,'Color','w');
                line(xspan,[xy(i),xy(i)],'LineStyle',':','LineWidth',0.5,'Color','w');
            end
            
             set(gca,'XTick',0:1/obj.binSize:11/obj.binSize,'XTickLabel',{'','0','','','','','5','','','','','10'},'YTick',0:1/obj.binSize:11/obj.binSize,'YTickLabel',{'','0','','','','','5','','','','','10'},'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            xlabel('Sample time (s)','FontName','Helvetica','FontSize',10);
            ylabel('Template time (s)','FontName','Helvetica','FontSize',10);

            if exist('filename','var')
                obj.writeFile(filename);
            end
        end
    end
end