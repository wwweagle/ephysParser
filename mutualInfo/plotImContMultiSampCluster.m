function [pCrossTime,Im]=plotImContMultiSampCluster(inName,outName)

pCrossTime=cell(0,0);
Im=cell(0,0);

load(inName,'allSpks','uniqTag');


fidx=0;
tag=cell(0,0);
for f= 1:length(allSpks{1})
    for u=1:size(allSpks{1}{f},1)
        fidx=fidx+1;
        tag{fidx}={uniqTag{f,1},uniqTag{f,2}(u,:)};
        futures(fidx)=parfeval(@plotOne,2,allSpks,f,u,outName);
%         [a,b]=plotOne(allSpks,f,u,outName);
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


            

    function im=calcIm(spkCounts)

            pool=cell2mat(spkCounts);
            if max(pool)==min(pool)
                im=0;
                return;
            end
            
            p_sample=nan(1,length(spkCounts));
            for i=1:length(spkCounts)
                p_sample(i)=length(spkCounts{i})/length(pool);
            end
            
            
            pdfs=cell(1,length(spkCounts));
            for i=1:length(spkCounts)
                pdfs{i}=fitdist(spkCounts{i}','Normal');
            end
            imPerSamp=nan(1,length(spkCounts));
            for i=1:length(spkCounts)
                othersamples=1:length(spkCounts);
                othersamples(i)=[];
                
                if (max(spkCounts{i})-min(spkCounts{i}))~=0
                        imPerSamp(i)=p_sample(i)*integral(@(x) flexDevide(pdf(pdfs{i},x),(p_sample(i)*pdf(pdfs{i},x)...
                        + sum(cell2mat(arrayfun(@(j) flexPdf(spkCounts{j},x,p_sample(j),pdfs{j}),othersamples','UniformOutput',false))))),-inf,inf);
%                         imPerSamp(i)=p_sample(i)*integral(@(x) (pdf(pdfs{i},x).*log2((pdf(pdfs{i},x))/(p_sample(i)*pdf(pdfs{i},x)...
%                         + sum(cell2mat(arrayfun(@(j) flexPdf(spkCounts{j},x,p_sample(j),pdfs{j}),othersamples','UniformOutput',false)))))),-inf,inf);
%                     p_r_s=pdf(pdfs{i},-50:150);
%                     nzIdx=find(p_r_s~=0);
%                     p_r=p_sample(i)*p_r_s(nzIdx)+sum(cell2mat(arrayfun(@(j) flexPdf(spkCounts{j},nzIdx,p_sample(j),pdfs{j}),othersamples','UniformOutput',false)));
%                     
%                     imPerSamp(i)=p_sample(i)*0.005*sum(p_r_s(nzIdx).*log2(p_r_s(nzIdx)./p_r));
%                     temp=mean(p_r_s(nzIdx).*log2(p_r_s(nzIdx)./p_r));
%                     disp(temp*nnz(p_r_s~=0));
                    
%                     fprintf('%.6f,',sum(p_r_s(nzIdx)./p_r));
%                     fprintf('%.3f,%.3f,%.3f,%.3f\n',pdfs{1}.mean,p_r_s(20),p_r(20),imPerSamp(i));
                else
                    imPerSamp(i)=-p_sample(i)*log2(nnz(pool==spkCounts{i}(1))/length(pool));
                end
            end
            im=sum(imPerSamp);
    end

    function out=shuf2Vec(spkCounts)
        pool=cell2mat(spkCounts);
        pool=pool(randperm(length(pool)));
        out=cell(1,length(spkCounts));
        startIdx=0;
        for i=1:length(spkCounts)
            out{i}=pool((1:length(spkCounts{i}))+startIdx);
            startIdx=startIdx+length(spkCounts{i});
        end
    end
    function out=genShuf(spkCounts,rpt)
        out=nan(rpt,1);
        currIdx=1;
        while currIdx<=rpt
            newSpks=shuf2Vec(spkCounts);
            val=calcIm(newSpks);
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

    function [pOne,curve]=plotOne(allSpks,f,u,fnameTag)
        shufRpt=500;
        fprintf('plotOne, %d %d', f,u);
        curveLen=size(allSpks{1}{1},3);
        curve=nan(1,curveLen-4);
        imShuf=nan(shufRpt,curveLen-4);
        pOne=nan(size(curve));
        spkCounts=cell(1,length(allSpks));
        for windowCenter=3:curveLen-2
            %calc
            cidx=windowCenter-2;
             fprintf('%d, ',cidx);
            winRange=(cidx):(windowCenter+2);
            for sampIdx=1:length(spkCounts)
                spkCounts{sampIdx}=sum(allSpks{sampIdx}{f}(u,:,winRange)*0.1,3);
            end
            curve(cidx)=calcIm(spkCounts);
            imShuf(:,cidx)=genShuf(spkCounts,shufRpt);
            pOne(cidx)=sum(abs(imShuf(:,cidx)-mean(imShuf(:,cidx)))>abs((curve(cidx)-mean(imShuf(:,cidx)))))/shufRpt;
        end
        fprintf('before plot %d %d %s',f,u,fnameTag);
        plotFig(curve,imShuf,pOne,f,u,fnameTag);
    end


    function out=flexPdf(spkCount,x,psample,pdfsample)
        
        if (max(spkCount)-min(spkCount))~=0
            out=psample*pdf(pdfsample,x);
        else
            out=zeros(size(x));
            out(x==spkCount(1))=psample;
        end
    end

    function out=flexDevide(x,y)
        out=zeros(size(x));
        out(x==0)=0;
        nzIdx=(x~=0);
        out(nzIdx)=x(nzIdx).*log2(x(nzIdx)./y(nzIdx));
    end
end