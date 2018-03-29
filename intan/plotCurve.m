classdef plotCurve < handle
    properties
        binSize=0.5;
        per100=false;
        half=false;
        dualPlot=false;
        plotRegion='delay';
        plotDualTest=false;
        decodeCategories=false;
    end
    methods (Access=private)
        function plotOdorEdge(obj,delay)
            if delay==13
                xx=[1,2,6,7.5,15,16]./obj.binSize+0.5;
            elseif obj.plotDualTest
                xx=[1,2,2+delay,3+delay,4.5+delay,5.5+delay]./obj.binSize+0.5;
            else
                xx=[1,2,2+delay,3+delay]./obj.binSize+0.5;
            end
            arrayfun(@(curX) line([xx(curX),xx(curX)],ylim(),'LineStyle',':','LineWidth',0.5,'Color','k'),1:length(xx));
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
        
        function [expTemplate,expTest,shufTemplate]=getMultiSampleBins(obj,samples,delay,repeat)
            samples=samples(randperm(length(samples)));
            if strcmpi(obj.plotRegion,'test')
                start=1/obj.binSize+1;
                stop=(delay+9)/obj.binSize;
                delta=(delay+10)/obj.binSize;
            else
                start=1/obj.binSize+1;
                stop=(delay+4)/obj.binSize;
                delta=(delay+5)/obj.binSize;
            end
            SUCount=size(samples{1},1);
            if obj.per100 && SUCount>100
                selectedSU=randperm(SUCount,100);
            elseif obj.half
                selectedSU=randperm(SUCount,round(SUCount/2));
            else
                selectedSU=1:SUCount;
            end
            
            expTemplate=samples{1}(selectedSU,start:stop,repeat)';
            expTest=samples{1}(selectedSU,start+delta:stop+delta,repeat)';
            
            shufTemplate=cell(length(samples)-1,1);
            for i=2:length(samples)
                shufTemplate{i-1}=samples{i}(selectedSU,start:stop,repeat)';
            end
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
                    labels={'','0','','','','','5','','','','','10','','','','',''};
                case 5
                    labels={'','0','','','','','5','','','','','10','','','','',''};
                case 8
                    labels={'','0','','','','','5','','','','','10','','','','',''};
                case 13
                    labels={'','0','','','','','5','','','','','10','','','','',''};
                otherwise
                    labels={'','0','','','','','5','','','','','10'};
                    
            end
        end
    end
    
    methods
        
        
                
        %% Plot Decoding
        function out=plotDecoding(obj,samples,filename,type,type2,toClose)
            addpath('R:\ZX\APC\RecordingAug16');
            if iscell(samples)
                if strcmpi(obj.plotRegion,'test')
                    delay=size(samples{1},3)/2*obj.binSize-10;
                    delta=(delay+8)/obj.binSize;
                else
                    delay=size(samples{1},3)/2*obj.binSize-5;
                    delta=(delay+3)/obj.binSize;
                end
                
                for i=1:length(samples)
                    samples{i}=permute(samples{i},[1,3,2]);
                end
                repeats=size(samples{1},3);
                out=nan(delta,repeats,2);
                h=waitbar(0,'0');
                [tempSamp,~,~]=obj.getMultiSampleBins(samples,delay,1);
                bins=size(tempSamp,1);
                for bin=1:bins
                    futures(bin)=parfeval(@obj.typeDec,2,type,samples, delay, repeats,bin);
                end
                for bin=1:bins
                    waitbar(bin/bins,h,sprintf('%d/%d',bin,bins));
                    [decoded,shuffled]=fetchOutputs(futures(bin));
                    out(bin,:,:)=[decoded,shuffled];
                end
            else
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
                    [decoded,shuffled]=obj.typeDec(type,samples, delay, repeats,bin);
                    out(bin,:,:)=[decoded,shuffled];
                end
                if exist('type2','var')
                    out2=nan(delta,repeats,2);
                    [pf1,~,~,~]=obj.getSampleBins(samples,delay,1);
                    bins=size(pf1,1);
                    for bin=1:bins
                        waitbar(bin/bins,h,sprintf('%d/%d',bin,bins));
                        [decoded,shuffled]=obj.typeDec(type2,samples, delay, repeats,bin);
                        out2(bin,:,:)=[decoded,shuffled];
                    end
                end
                
            end
            delete(h);
            %% Figure
            fh=figure('Color','w','Position',[100,100,350,240]);
            subplot('Position',[0.17,0.17,0.8,0.75]);
            hold on
            
            decRec=out(:,:,1)';
            decShuffle=out(:,:,2)';
            
            m=@(mat) mean(mat);
            ciRec=bootci(100,m,decRec);
            ciShuffle=bootci(100,m,decShuffle);
            if strcmpi(obj.plotRegion,'test')
                plotLength=(delay+8)/obj.binSize;
            else
                plotLength=(delay+3)/obj.binSize;
            end
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ciRec(1,:)),(fliplr(ciRec(2,:)))],[1,0.8,0.8],'EdgeColor','none');
            fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ciShuffle(1,:)),(fliplr(ciShuffle(2,:)))],[0.8,0.8,0.8],'EdgeColor','none');
            
            hRec=plot([1:plotLength]-0.5*obj.binSize,(mean(out(:,:,1),2)),'-r','LineWidth',1);
            hShuffle=plot([1:plotLength]-0.5*obj.binSize,(mean(out(:,:,2),2)),'-k','LineWidth',1);
            
            if exist('type2','var') && ~isempty(type2)
                decRec=out2(:,:,1)';
                ciRec=bootci(100,m,decRec);
                fill([1:plotLength,plotLength:-1:1]-0.5*obj.binSize,[(ciRec(1,:)),(fliplr(ciRec(2,:)))],[0.8,0.8,1],'EdgeColor','none');
                hRec2=plot([1:plotLength]-0.5*obj.binSize,(mean(out2(:,:,1),2)),'-b','LineWidth',1);
                
                for i=1:delay+2
                    p1s=obj.chiSq(out,1,out,2,i,repeats).*(delay+2).*3;
                    p2s=obj.chiSq(out2,1,out2,2,i,repeats).*(delay+2).*3;
                    p12=obj.chiSq(out,1,out2,1,i,repeats).*(delay+2).*3;
                    text((i-0.5)./obj.binSize,0.25,p2Str(p1s),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica','Color','r');
                    text((i-0.5)./obj.binSize,0.2,p2Str(p2s),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica','Color','b');
                    text((i-0.5)./obj.binSize,0.15,p2Str(p12),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica','Color','k');
                end
                
                legend([hRec, hRec2, hShuffle],{'Data 1','Data 2','Shuffled Data'},'box','off','FontSize',10,'FontName','Helvetica');
            else
                for i=1:delay+7
                    p=obj.chiSq(out,1,out,2,i,repeats).*(delay+7);
                    text((i-0.5)./obj.binSize+0.5,0.42,p2Str(p),'HorizontalAlignment','center','FontSize',10,'FontName','Helvetica');
                end
                legend([hRec, hShuffle],{'Recording Data','Shuffled Data'},'box','off','FontSize',10,'FontName','Helvetica','AutoUpdate','off');
            end
            
            set(gca,'YTick',0.0:0.2:1,'XTick',0:1/obj.binSize:plotLength,'XTickLabel',obj.getLabels(delay),'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');
            
            xlim([0,plotLength-1/obj.binSize]);
            if exist('type','var') && strcmpi(type,'multi')
                ylim([0.4,1]);
                nCount=num2str(size(samples{1},1));
            else
                ylim([0.25,1]);
                nCount=num2str(size(samples,1));
            end
            
            obj.plotOdorEdge(delay);
            
            xlabel('Time (s)','FontSize',10,'FontName','Helvetica');
            ylabel('Decoding Accuracy','HorizontalAlignment','center','Rotation',90,'FontSize',10,'FontName','Helvetica');
            text(4/obj.binSize,1,['n = ',nCount],'HorizontalAlignment','center','VerticalAlignment','top','FontSize',10,'FontName','Helvetica');
            
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
                obj.writeFile(filename);
            end
            
            if exist('toClose','var') && toClose
                close(fh);
            end
            
        end
        
        function p=chiSq(obj,data1,pos1,data2,pos2,i,repeats)
            A=[zeros(repeats/obj.binSize,1);ones(repeats/obj.binSize,1)];
            B=[reshape(data1((i-1)/obj.binSize+1:i/obj.binSize,:,pos1),repeats/obj.binSize,1);
                reshape(data2((i-1)/obj.binSize+1:i/obj.binSize,:,pos2),repeats/obj.binSize,1)];
            [~,~,p]=crosstab(A,B);
            %
            %             p=ranksum(reshape(data((i-1)/obj.binSize+1:i/obj.binSize,:,pos),repeats/obj.binSize,1),...
            %                 reshape(data((i-1)/obj.binSize+1:i/obj.binSize,:,pos),repeats/obj.binSize,1)).*(delay+2).*3;
        end
        
        function [decoded,shuffled]=typeDec(obj,type,samples,delay,repeats,bin)
            decoded=nan(repeats,1);
            shuffled=nan(repeats,1);
            for repeat=1:repeats
                if exist('type','var') && strcmpi(type,'multi')
                    [expTemplate,expTest,shufTemplate]=obj.getMultiSampleBins(samples,delay,repeat);
                    
                    if obj.decodeCategories
                        withInTemplate=mean([shufTemplate{1}(bin,:);shufTemplate{2}(bin,:)]);
                        shufs=randperm(3)+2;
                        betweenTemplate=mean([shufTemplate{shufs(1)}(bin,:);shufTemplate{shufs(2)}(bin,:)]);
                        getCorr=@(x) x(1,2);
                        if getCorr(corrcoef(expTest(bin,:),withInTemplate))>getCorr(corrcoef(expTest(bin,:),betweenTemplate))
                            decoded(repeat)=1;
                        elseif getCorr(corrcoef(expTest(bin,:),withInTemplate))==getCorr(corrcoef(expTest(bin,:),betweenTemplate))
                            decoded(repeat)=randi(2)-1;
                        else
                            decoded(repeat)=0;
                        end
                        shufs=randperm(5);
                        withInTemplate=mean([shufTemplate{shufs(1)}(bin,:);shufTemplate{shufs(2)}(bin,:)]);
                        betweenTemplate=mean([shufTemplate{shufs(3)}(bin,:);shufTemplate{shufs(4)}(bin,:)]);
                        if getCorr(corrcoef(expTest(bin,:),withInTemplate))>getCorr(corrcoef(expTest(bin,:),betweenTemplate))
                            shuffled(repeat)=1;
                        elseif getCorr(corrcoef(expTest(bin,:),withInTemplate))==getCorr(corrcoef(expTest(bin,:),betweenTemplate))
                            shuffled(repeat)=randi(2)-1;
                        else
                            shuffled(repeat)=0;
                        end
                        
                        
                    else
                        corrExp=corrcoef(expTest(bin,:),expTemplate(bin,:));
                        corrShuf=nan(length(shufTemplate),1);
                        
                        for i=1:length(shufTemplate)
                            corrS=corrcoef(expTest(bin,:),shufTemplate{i}(bin,:));
                            corrShuf(i)=corrS(1,2);
                        end
                        if corrExp(1,2)>max(corrShuf)
                            decoded(repeat)=1;
                        elseif corrExp(1,2)==max(corrShuf)
                            decoded(repeat)=randi(2)-1;
                        else
                            decoded(repeat)=0;
                        end
                        
                        shufCorr=randsample([corrExp(1,2);corrShuf],length(corrShuf)+1);
                        if shufCorr(1)>max(shufCorr(2:end))
                            shuffled(repeat)=1;
                        elseif sum(shufCorr(2:end)==shufCorr(1))>0
                            shuffled(repeat)=randperm(sum(shufCorr(2:end)==shufCorr(1))+1,1)==1;
                        else
                            shuffled(repeat)=0;
                        end
                    end
                    obj.dualPlot=false;
                    
                else
                    [pf1,pf2,bn1,bn2]=obj.getSampleBins(samples,delay,repeat);
                    if exist('type','var') && strcmpi(type,'sample')
                        delayBins=1/obj.binSize+1:2/obj.binSize;
                        if rand<0.5 % Use PF Test
                            corrPF=corrcoef(pf2(bin,:),mean(pf1(delayBins,:)));
                            corrBN=corrcoef(pf2(bin,:),mean(bn1(delayBins,:)));
                            decoded(repeat)=corrPF(1,2)>corrBN(1,2);
                            
                        else % Use BN Test
                            corrPF=corrcoef(bn2(bin,:),mean(pf1(delayBins,:)));
                            corrBN=corrcoef(bn2(bin,:),mean(bn1(delayBins,:)));
                            decoded(repeat)=corrBN(1,2)>corrPF(1,2);
                        end
                        obj.dualPlot=true;
                        
                    elseif exist('type','var') && strcmpi(type,'delay')
                        delayBins=2/obj.binSize+1:(delay+2)/obj.binSize;
                        if rand<0.5 % Use PF Test
                            corrPF=corrcoef(pf2(bin,:),mean(pf1(delayBins,:)));
                            corrBN=corrcoef(pf2(bin,:),mean(bn1(delayBins,:)));
                            decoded(repeat)=corrPF(1,2)>corrBN(1,2);
                            
                        else % Use BN Test
                            corrPF=corrcoef(bn2(bin,:),mean(pf1(delayBins,:)));
                            corrBN=corrcoef(bn2(bin,:),mean(bn1(delayBins,:)));
                            decoded(repeat)=corrBN(1,2)>corrPF(1,2);
                        end
                        obj.dualPlot=true;
                        %%%%%%%%%%%%%%%%%%%%%%% Multiple Sample %%%%%%%%%
                    elseif exist('type','var') && strcmpi(type,'multi')
                        if rand<0.5 % Use PF Test
                            corrPF=corrcoef(pf2(bin,:),pf1(bin,:));
                            corrBN=corrcoef(pf2(bin,:),bn1(bin,:));
                            decoded(repeat)=corrPF(1,2)>corrBN(1,2);
                            
                        else % Use BN Test
                            corrPF=corrcoef(bn2(bin,:),pf1(bin,:));
                            corrBN=corrcoef(bn2(bin,:),bn1(bin,:));
                            decoded(repeat)=corrBN(1,2)>corrPF(1,2);
                        end
                        obj.dualPlot=false;
                        %%%%%%%%%%%%%%%%%%%%%
                    elseif exist('type','var') && strcmpi(type,'sampledelay')
                        delayBins=1/obj.binSize+1:(delay+2)/obj.binSize;
                        if rand<0.5 % Use PF Test
                            corrPF=corrcoef(pf2(bin,:),mean(pf1(delayBins,:)));
                            corrBN=corrcoef(pf2(bin,:),mean(bn1(delayBins,:)));
                            decoded(repeat)=corrPF(1,2)>corrBN(1,2);
                            
                        else % Use BN Test
                            corrPF=corrcoef(bn2(bin,:),mean(pf1(delayBins,:)));
                            corrBN=corrcoef(bn2(bin,:),mean(bn1(delayBins,:)));
                            decoded(repeat)=corrBN(1,2)>corrPF(1,2);
                        end
                        obj.dualPlot=true;
                    elseif exist('type','var') && strcmpi(type,'late')
                        delayBins=delay/obj.binSize+1:(delay+2)/obj.binSize;
                        if rand<0.5 % Use PF Test
                            corrPF=corrcoef(pf2(bin,:),mean(pf1(delayBins,:)));
                            corrBN=corrcoef(pf2(bin,:),mean(bn1(delayBins,:)));
                            decoded(repeat)=corrPF(1,2)>corrBN(1,2);
                            
                        else % Use BN Test
                            corrPF=corrcoef(bn2(bin,:),mean(pf1(delayBins,:)));
                            corrBN=corrcoef(bn2(bin,:),mean(bn1(delayBins,:)));
                            decoded(repeat)=corrBN(1,2)>corrPF(1,2);
                        end
                        obj.dualPlot=true;
                    elseif exist('type','var') && strcmpi(type,'dynamic')
                        if rand<0.5 % Use PF Test
                            corrPF=corrcoef(pf2(bin,:),pf1(bin,:));
                            corrBN=corrcoef(pf2(bin,:),bn1(bin,:));
                            decoded(repeat)=corrPF(1,2)>corrBN(1,2);
                            
                        else % Use BN Test
                            corrPF=corrcoef(bn2(bin,:),pf1(bin,:));
                            corrBN=corrcoef(bn2(bin,:),bn1(bin,:));
                            decoded(repeat)=corrBN(1,2)>corrPF(1,2);
                        end
                        obj.dualPlot=false;
                    end
                    shuffled(repeat)=randsample([decoded(repeat),~decoded(repeat)],1);
                end
            end
        end
        
        
        function writeFile(obj,fileName)
            %             towrite=questdlg('Save File ?','Save File');
            %             if strcmpi(towrite,'yes')
            set(gcf,'PaperPositionMode','auto');
            savefig([fileName,'.fig']);
            %             end
        end
        
    end
end