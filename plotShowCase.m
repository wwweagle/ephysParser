function plotShowCase
binSize=0.5;
javaaddpath('R:\ZX\java\spk2fr\build\classes');
javaaddpath('R:\ZX\java\spk2fr\lib\jmatio.jar');
javaaddpath('R:\ZX\java\spk2fr\lib\commons-math3-3.5.jar');
javaaddpath('R:\ZX\java\DualEvtParser\build\classes');
s2f=spk2fr.Spk2fr;
s2f.setWellTrainOnly(1);
s2f.setRefracRatio(0.0015);
s2f.setLeastFR('all');
fl=listF();
% fileList=fl.listTrialF();
fileList=fl.listTrialFWJ();

% 91_3 Dual-8s-R109-1-32EVT1234-R110-65-96-EVT18-21-0930_1GRP.mat


for fi=10%size(fileList)
    %     fh=gobjects(1);
    fprintf('fid: %d\n',fi);
    ft=load(fileList{fi});
    spk=ft.SPK;
    if(size(spk,1)>1000)
%     ts1=s2f.getTS(ft.EVT,spk,'Dual');
        for tet=10%1:length(ts1)
            for btype=[0 2 1]
                evt=ft.EVT(ft.EVT(:,3)==btype,:);
                ts=s2f.getTS(evt,spk,'Dual');
                if ~isempty(ts)
                    plotOne(ts{tet},fi*100+tet,btype);
                end
            end
        end
        disp(s2f.getKeyIdx());
    end
    
%     pause;
end

    function plotOne(ts,fidx,onetype)
        transPos=[0 2 1];
%         pf=nan(0,0);
%         bn=nan(0,0);
        if onetype==0
            figure('Color','w','Position',[100,100,730,200]);
        end
        subplot('Position',[0.05+transPos(onetype+1)*0.33,0.5,0.266,0.40]);
        hold on;
        if length(ts{1})>20
            pos=round((length(ts{1})-20)/2);
            posRange=pos:pos+19;
        else
            pos=1;
            posRange=1:length(ts{1});
        end
        for i=posRange
            plot([ts{1}{i}';ts{1}{i}'],repmat([i-pos;i-pos+0.8]+1,1,length(ts{1}{i})),'-r');
%             pf=[pf;ts{1}{i}];
        end
        
%         currH=length(ts{1});
        if length(ts{2})>20
            pos=round((length(ts{2})-20)/2);
            posRange=pos:pos+19;
        else
            pos=1;
            posRange=1:length(ts{2});
        end

        for i=posRange
            plot([ts{2}{i}';ts{2}{i}'],repmat([i+20-pos;i+20-pos+0.8]+1,1,length(ts{2}{i})),'-b');
%             bn=[bn;ts{2}{i}];
        end
        
%         xlim([-1,10]);
        xlim([-1,15]);
        ylim([0,41]);
        set(gca,'XTick',[],'YTick',[1,17,24,40],'YTickLabel',[1,20,1,20]);
        plot(repmat([0,1,5,5.5,6,6.5,14,15],2,1),repmat(ylim()',1,8),':k');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot('Position',[0.05+transPos(onetype+1)*0.33,0.1,0.266,0.35]);
        hold on;
        pfHist=nan(length(ts{1}),19/binSize);
        for t=1:size(pfHist,1)
            pfHist(t,:)=histcounts(ts{1}{t},-4:binSize:15)./binSize;
        end
        bnHist=nan(length(ts{2}),19/binSize);
        for t=1:size(bnHist,1)
            bnHist(t,:)=histcounts(ts{2}{t},-4:binSize:15)./binSize;
        end
        
%         fill([-4+binSize/2:binSize:15,15-binSize/2:-binSize:-4],[smooth(mean(pfHist)+std(pfHist)./sqrt(size(pfHist,1)),3);smooth(fliplr(mean(pfHist)-std(pfHist)./sqrt(size(pfHist,1))),3)],[1,0.8,0.8],'EdgeColor','none');
%         fill([-4+binSize/2:binSize:15,15-binSize/2:-binSize:-4],[smooth(mean(bnHist)+std(bnHist)./sqrt(size(bnHist,1)),3);smooth(fliplr(mean(bnHist)-std(bnHist)./sqrt(size(bnHist,1))),3)],[0.8,0.8,1],'EdgeColor','none');
% 
%         plot(-4+binSize/2:binSize:15,smooth(mean(pfHist),3)','-r');
%         plot(-4+binSize/2:binSize:15,smooth(mean(bnHist),3)','-b');


        fill([-4+binSize/2:binSize:15,15-binSize/2:-binSize:-4],[(mean(pfHist)+std(pfHist)./sqrt(size(pfHist,1))),(fliplr(mean(pfHist)-std(pfHist)./sqrt(size(pfHist,1))))],[1,0.8,0.8],'EdgeColor','none');
        fill([-4+binSize/2:binSize:15,15-binSize/2:-binSize:-4],[(mean(bnHist)+std(bnHist)./sqrt(size(bnHist,1))),(fliplr(mean(bnHist)-std(bnHist)./sqrt(size(bnHist,1))))],[0.8,0.8,1],'EdgeColor','none');

        plot(-4+binSize/2:binSize:15,(mean(pfHist))','-r');
        plot(-4+binSize/2:binSize:15,(mean(bnHist))','-b');

        xlim([-1,15]);
%         xlim([-1,10]);
        ylim([min(ylim()),max([mean(pfHist)+std(pfHist)./sqrt(size(pfHist,1)),mean(bnHist)+std(bnHist)./sqrt(size(bnHist,1))])]);
        plot(repmat([0,1,5,5.5,6,6.5,14,15],2,1),repmat(ylim()',1,8),':k');
%         text(8,diff(ylim())*0.9,sprintf('%05d',fidx),'HorizontalAlignment','center');
        if onetype==1
            set(gcf,'PaperUnits','inches','PaperPosition',[0 0 12 6])
            print('-r100','-dpng',['png\Dual13s_case_',sprintf('%05d',fidx),'.png']);
%             close all;
        end
    end


end