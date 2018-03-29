function [pCrossTime,Im]=plotImContCluster(inName,outName)

pCrossTime=cell(0,0);
Im=cell(0,0);

% [spkCA,uniqTag]=allByTypeDNMS('sample','Average2Hz',-2,0.1,11,true,delayLen,true);
% [spkCB,~]=allByTypeDNMS('sample','Average2Hz',-2,0.1,11,false,delayLen,true);
% [spkCA,uniqTag]=allByTypeDual('distrNone','Average2Hz',-2,0.1,15,true,true);
% [spkCB,~]=allByTypeDual('distrNone','Average2Hz',-2,0.1,15,false,true);


fstr=load(inName);
spkCA=fstr.spkCA;
spkCB=fstr.spkCB;
uniqTag=fstr.uniqTag;

fidx=0;
tag=cell(0,0);
for f= 1:length(spkCA)
    for u=1:size(spkCA{f},1)
        fidx=fidx+1;
        tag{fidx}={uniqTag{f,1},uniqTag{f,2}(u,:)};
        futures(fidx)=parfeval(@plotOne,2,spkCA,spkCB,f,u,outName);
%         [a,b]=plotOne(spkCA,spkCB,f,u,outName);
    end
end

for ffidx=1:fidx
    try
        [ps,ims]=fetchOutputs(futures(ffidx));
        fprintf('%d,',ffidx);
        pCrossTime=[pCrossTime;{tag{ffidx},ps}];
        Im=[Im;{tag{ffidx},ims}];
    catch ME
         disp(ffidx);
         disp(ME.identifier);
    end
end

save([outName,'.mat'],'pCrossTime','Im');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            

    function im=calcIm(aSpkCount,bSpkCount)
            pool=[aSpkCount,bSpkCount];
            if max(pool)==min(pool)
                im=0;
                return;
            end
            
            p_s_a=length(aSpkCount)/length(pool);
            p_s_b=length(bSpkCount)/length(pool);
            
            
            pdfa=fitdist(aSpkCount','Normal');
            pdfb=fitdist(bSpkCount','Normal');


            if (max(aSpkCount)-min(aSpkCount))~=0
                if (max(bSpkCount)-min(bSpkCount))~=0
                    imA=p_s_a*integral(@(x) pdf(pdfa,x)*(log2(pdf(pdfa,x)/(p_s_a*pdf(pdfa,x)+p_s_b*pdf(pdfb,x)))),-inf,inf);
                else
                    imA=p_s_a*integral(@(x) pdf(pdfa,x)*(log2(pdf(pdfa,x)/(p_s_a*pdf(pdfa,x)+p_s_b*(bSpkCount(1)==x)))),-inf,inf);
                end
            else
                imA=-p_s_a*log2(nnz(pool==aSpkCount(1))/length(pool));
            end
            if (max(bSpkCount)-min(bSpkCount))~=0
                if (max(aSpkCount)-min(aSpkCount))~=0
                    imB=p_s_b*integral(@(x) pdf(pdfb,x)*(log2(pdf(pdfb,x)/(p_s_a*pdf(pdfa,x)+p_s_b*pdf(pdfb,x)))),-inf,inf);
                else
                    imB=p_s_b*integral(@(x) pdf(pdfb,x)*(log2(pdf(pdfb,x)/(p_s_a*(aSpkCount(1)==x)+p_s_b*pdf(pdfb,x)))),-inf,inf);
                end
            else
                imB=-p_s_b*log2(nnz(pool==bSpkCount(1))/length(pool));
            end
            im=imA+imB;
            if isnan(im) || im==inf || im==-inf
                fprintf('unexpected im\n');
            end
    end

    function [AA,BB]=shuf2Vec(A,B)
        pool=[A,B];
        pool=pool(randperm(length(pool)));
        AA=pool(1:length(A));
        BB=pool((length(A)+1):end);
    end
    function out=genShuf(aSpkCount,bSpkCount,rpt)
        out=nan(rpt,1);
        currIdx=1;
        while currIdx<=rpt
            [AA,BB]=shuf2Vec(aSpkCount,bSpkCount);
            val=calcIm(AA,BB);
            if ~isnan(val) && abs(val)~=inf
                out(currIdx)=val;
                currIdx=currIdx+1;
            end
        end
    end

    function plotFig(curve,imShuf,pOne,f,u,fnameTag)
        cf=figure();
        fprintf('new figure for %d %d',f,u);
        hold on;
        xPos=[1:length(curve)]*0.1-1.75-0.1;
        
        
        shufs=bootci(3,@(x) mean(x),imShuf);
        fill([xPos,fliplr(xPos)],[shufs(1,:),fliplr(shufs(2,:))],'k','FaceAlpha',0.2,'EdgeColor','none');
        plot(xPos,mean(shufs),'-k','LineWidth',1);
        plot(xPos,curve,'-r.','LineWidth',1);
        ylim([-0.1,1.1]);
        set(gca,'XTick',0:5:10);
        xlabel('Time (s)');
        ylabel('Mutual Info (bits)');
        
        plotTag=@(x) plot([x,x],[-1,1],':k','LineWidth',0.5);
        if contains(inName,'8s','IgnoreCase',true) || contains(outName,'8s','IgnoreCase',true) 
            arrayfun(plotTag,[0 1 3 3.5 4 4.5 9 10]);
        else
            arrayfun(plotTag,[0 1 5 6]);
        end
        plot(xPos(pOne<0.01),-0.05,'k.');
        xlim([-1,11]);
        savefig(cf,[fnameTag,num2str(f*1000+u),'.fig'],'compact');
        print('-dpng',[fnameTag,num2str(f*1000+u),'.png']);
        close(cf);
    end

    function [pOne,curve]=plotOne(spkCA,spkCB,f,u,fnameTag)
        shufRpt=5;
        fprintf('plotOne, %d %d', f,u);
        curveLen=size(spkCA{1},3);
        curve=nan(1,curveLen-4);
        imShuf=nan(shufRpt,curveLen-4);
        pOne=nan(size(curve));
        for windowCenter=3:curveLen-2
            %calc
            cidx=windowCenter-2;
            fprintf('%d, ',cidx);
            winRange=(cidx):(windowCenter+2);
            aSpkCount=sum(spkCA{f}(u,:,winRange)*0.1,3);
            bSpkCount=sum(spkCB{f}(u,:,winRange)*0.1,3);
            curve(cidx)=calcIm(aSpkCount,bSpkCount);
            imShuf(:,cidx)=genShuf(aSpkCount,bSpkCount,shufRpt);
            pOne(cidx)=sum(abs(imShuf(:,cidx)-mean(imShuf(:,cidx)))>abs((curve(cidx)-mean(imShuf(:,cidx)))))/shufRpt;
        end
        fprintf('before plot %d %d %s',f,u,fnameTag);
        plotFig(curve,imShuf,pOne,f,u,fnameTag);
    end


end