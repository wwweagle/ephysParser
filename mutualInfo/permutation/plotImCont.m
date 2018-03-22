function plotImCont()

pCrossTime=cell(0,0);
Im=cell(0,0);

fstru=load('toCluster.mat');
spkCA=fstru.spkCA;
spkCB=fstru.spkCB;
uniqTag=fstru.uniqTag;
%    wd=pwd();
%    cd r:\ZX\APC\RecordingAug16\
%    [spkCA,uniqTag]=allByTypeDNMS('sample','Average2Hz',-2,0.1,11,true,delayLen,true);
%    [spkCB,~]=allByTypeDNMS('sample','Average2Hz',-2,0.1,11,false,delayLen,true);

%    cd(wd);


fidx=0;
tag=cell(0,0);
for f= 1:length(spkCA)
    for u=1:size(spkCA{f},1)
        fidx=fidx+1;
        tag{fidx}={uniqTag{f,1},uniqTag{f,2}(u,:)};
        futures(fidx)=parfeval(@plotOne,2,spkCA,spkCB,f,u);
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
% 
%     function str=p2str(x)
%         if x>0.05
%             str='N.S.';
%         else
%             str=sprintf('%0.3f',x);
%         end
%     end

save('ImOutput.mat','pCrossTime','Im');

    function im=calcIm(aSpkCount,bSpkCount)
            pool=[aSpkCount,bSpkCount];
            p_s_a=length(aSpkCount)/length(pool);
            p_s_b=length(bSpkCount)/length(pool);

            pdfa=fitdist(aSpkCount','Normal');
            pdfb=fitdist(bSpkCount','Normal');
            if pdfa.sigma~=0
                imA=p_s_a*integral(@(x) pdf(pdfa,x)*p_s_a*(log2(pdf(pdfa,x)/(pdf(pdfa,x)*p_s_a+pdf(pdfb,x)*p_s_b))),-inf,inf);
            else
                imA=0;
            end
            if pdfb.sigma~=0
                imB=p_s_b*integral(@(x) pdf(pdfb,x)*p_s_b*(log2(pdf(pdfb,x)/(pdf(pdfa,x)*p_s_a+pdf(pdfb,x)*p_s_b))),-inf,inf);
            else
                imB=0;
            end
            im=imA+imB;
    end

    function [AA,BB]=shuf2Vec(A,B)
        pool=[A,B];
        pool=pool(randperm(length(pool)));
        AA=pool(1:length(A));
        BB=pool((length(A)+1):end);
    end
    function out=genShuf(aSpkCount,bSpkCount,rpt)
        out=nan(rpt,1);
        for i=1:rpt
            [AA,BB]=shuf2Vec(aSpkCount,bSpkCount);
            out(i)=calcIm(AA,BB);
        end
        
    end

    function plotFig(curve,imShuf,pOne,f,u)
        cf=figure();
        fprintf('new figure for %d %d',f,u);
        hold on;
        xPos=[1:length(curve)]*0.1-1.75-0.1;
        shufs=bootci(100,@(x) mean(x),imShuf);
        fill([xPos,fliplr(xPos)],[shufs(1,:),fliplr(shufs(2,:))],'k','FaceAlpha',0.2,'EdgeColor','none');
        plot(xPos,mean(shufs),'-k','LineWidth',1);
        plot(xPos,curve,'-r.','LineWidth',1);
        ylim([-0.1,0.6]);
        set(gca,'XTick',0:5:10);
        xlabel('Time (s)');
        ylabel('Mutual Info (bits)');
        
        plotOne=@(x) plot([x,x],[-1,1],':k','LineWidth',0.5);
        arrayfun(plotOne,[0 1 5 6]);
%         arrayfun(@(x) text(xPos,-0.05,p2str(pOne),'FontSize',10,'HorizontalAlignment','center'),1:length(p));
        plot(xPos(pOne<0.01),-0.05,'k.');
        xlim([-1,11]);
        savefig(cf,['D4',num2str(f*1000+u),'.fig'],'compact');
        print('-dpng',['D4',num2str(f*1000+u),'.png']);
        close(cf);
    end

    function [pOne,curve]=plotOne(spkCA,spkCB,f,u)
        fprintf('plotOne, %d %d', f,u);
        curveLen=size(spkCA{1},3);
        curve=nan(1,curveLen-4);
        imShuf=nan(1000,curveLen-4);
%         futures=nan(size(curve));
        pOne=nan(size(curve));
        for windowCenter=3:curveLen-2
            %calc
            cidx=windowCenter-2;
            winRange=(cidx):(windowCenter+2);
            aSpkCount=sum(spkCA{f}(u,:,winRange),3);
            bSpkCount=sum(spkCB{f}(u,:,winRange),3);
            curve(cidx)=calcIm(aSpkCount,bSpkCount);
            imShuf(:,cidx)=genShuf(aSpkCount,bSpkCount,1000);
            pOne(cidx)=sum(abs(imShuf(:,cidx)-mean(imShuf(:,cidx)))>abs((curve(cidx)-mean(imShuf(:,cidx)))))/1000;
        end
        fprintf('before plot %d %d',f,u);
        plotFig(curve,imShuf,pOne,f,u);
    end


end
