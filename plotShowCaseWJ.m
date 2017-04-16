function plotShowCaseWJ
byLick=true;
binSize=0.25;
javaaddpath('R:\ZX\java\spk2fr\build\classes');
javaaddpath('R:\ZX\java\spk2fr\lib\jmatio.jar');
javaaddpath('R:\ZX\java\spk2fr\lib\commons-math3-3.5.jar');
javaaddpath('R:\ZX\java\DualEvtParser\build\classes');
s2f=spk2fr.Spk2fr;
s2f.setWellTrainOnly(1);
s2f.setRefracRatio(0.0015);
s2f.setLeastFR('all');
% fl=listF();
% fileList=fl.listDNMS4s();
% fileList=fl.listDNMS8s();
[~,id]=allByTypeDNMS('sample','Average2Hz',-2,0.5,12,true,4,true);
% id=evalin('base','idselA');
fileList=cell2mat(id(:,1));


% 91_3 Dual-8s-R109-1-32EVT1234-R110-65-96-EVT18-21-0930_1GRP.mat
% 07002
% 03008
% 00101

for fi=1 %:size(fileList)
    
    fprintf('fid: %d\n',fi);
    disp(fileList(fi,:));
    ft=load(fileList(fi,:));
    spk=ft.Spk;
    if(numel(spk)>1000)
    ts1=s2f.getTS(ft.TrialInfo,spk,'wjdnms',byLick);
      if ~isempty(ts1)
          for tet=1 %:size(ts1,1)
            plotOne(ts1{tet},fi*100+tet);
          end
      end
      disp(s2f.getKeyIdx());
    end
    
%     pause;
end

    function plotOne(ts,fidx)
%         pf=nan(0,0);
%         bn=nan(0,0);
        figure('Color','w','Position',[100,100,280,280]);

        subplot('Position',[0.1,0.5,0.85,0.40]);
        hold on;
        if length(ts{1})>20
            pos=round((length(ts{1})-20)/2);
            posRange1=pos:pos+19;
        else
            pos=1;
            posRange1=1:length(ts{1});
        end
        for i=posRange1
            plot([ts{1}{i}';ts{1}{i}'],repmat([i-pos;i-pos+1]+1,1,length(ts{1}{i})),'-r','LineWidth',1);
%             pf=[pf;ts{1}{i}];
        end
        
%         currH=length(ts{1});
        if length(ts{2})>20
            pos=round((length(ts{2})-20)/2);
            posRange2=pos:pos+19;
        else
            pos=1;
            posRange2=1:length(ts{2});
        end

        for i=posRange2
            plot([ts{2}{i}';ts{2}{i}'],repmat([i+20-pos;i+20-pos+1]+1,1,length(ts{2}{i})),'-b','LineWidth',1);
%             bn=[bn;ts{2}{i}];
        end
        
%         xlim([-1,6]);

        set(gca,'XTick',[],'YTick',[0,17,24,40],'YTickLabel',[0,20,0,20]);
        
        plot([0,1,5,6,7,7.5;0,1,5,6,7,7.5],repmat(ylim()',1,6),':k');
%         plot([0,1,9,10;0,1,9,10],repmat(ylim()',1,4),':k');
        xlim([4,10]);
        ylim([0,41]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot('Position',[0.1,0.1,0.85,0.35]);
        hold on;
        pfHist=nan(length(posRange1),11/binSize);
        idx=1;
        for t=posRange1
            pfHist(idx,:)=histcounts(ts{1}{t},-1:binSize:10)./binSize;
            idx=idx+1;
        end
        bnHist=nan(length(posRange2),11/binSize);
        idx=1;
        for t=posRange2
            bnHist(idx,:)=histcounts(ts{2}{t},-1:binSize:10)./binSize;
            idx=idx+1;
        end
        
%         fill([-1+binSize/2:binSize:10,10-binSize/2:-binSize:-1],[smooth(mean(pfHist)+std(pfHist)./sqrt(size(pfHist,1)));smooth(fliplr(mean(pfHist)-std(pfHist)./sqrt(size(pfHist,1))))],[1,0.8,0.8],'EdgeColor','none');
%         fill([-1+binSize/2:binSize:10,10-binSize/2:-binSize:-1],[smooth(mean(bnHist)+std(bnHist)./sqrt(size(bnHist,1)));smooth(fliplr(mean(bnHist)-std(bnHist)./sqrt(size(bnHist,1))))],[0.8,0.8,1],'EdgeColor','none');
% 
%         plot(-1+binSize/2:binSize:10,smooth(mean(pfHist)),'-r');
%         plot(-1+binSize/2:binSize:10,smooth(mean(bnHist)),'-b');

        fill([-1+binSize/2:binSize:10,10-binSize/2:-binSize:-1],[(mean(pfHist)+std(pfHist)./sqrt(size(pfHist,1))),(fliplr(mean(pfHist)-std(pfHist)./sqrt(size(pfHist,1))))],[1,0.8,0.8],'EdgeColor','none');
        fill([-1+binSize/2:binSize:10,10-binSize/2:-binSize:-1],[(mean(bnHist)+std(bnHist)./sqrt(size(bnHist,1))),(fliplr(mean(bnHist)-std(bnHist)./sqrt(size(bnHist,1))))],[0.8,0.8,1],'EdgeColor','none');

        plot(-1+binSize/2:binSize:10,(mean(pfHist)),'-r','LineWidth',1);
        plot(-1+binSize/2:binSize:10,(mean(bnHist)),'-b','LineWidth',1);

        plot([0,1,5,6,7,7.5;0,1,5,6,7,7.5],repmat(ylim()',1,6),':k');
%         plot([0,1,9,10;0,1,9,10],repmat(ylim()',1,4),':k');
        set(gca,'XTick',[0,5,10]);
        xlim([4,10]);
%         xlim([-1,10]);
        ylim([min(ylim()),max([mean(pfHist)+std(pfHist)./sqrt(size(pfHist,1)),mean(bnHist)+std(bnHist)./sqrt(size(bnHist,1))])]);
        
        Lick=evalin('base','Lick');
        li=cell(0);
        nl=cell(0);
        idx=1;
        for i=posRange1
            li{idx}=Lick(find(Lick>(ts{3}(i)-1) & Lick<(ts{3}(i)+13)))-ts{3}(i)-1;
            idx=idx+1;
        end
        idx=1;
        for i=posRange2
            nl{idx}=Lick(find(Lick>(ts{4}(i)-1) & Lick<(ts{4}(i)+13)))-ts{4}(i)-1;
            idx=idx+1;
        end
        lim=nan(20,44);
        nlm=nan(20,44);
        for i=1:20
            lim(i,:)=histcounts(li{i},-1:binSize:10)./binSize;
            nlm(i,:)=histcounts(nl{i},-1:binSize:10)./binSize;
        end
        yyaxis right
        
        fill([-1+binSize/2:binSize:10,10-binSize/2:-binSize:-1],[(mean(lim)+std(lim)./sqrt(size(lim,1))),(fliplr(mean(lim)-std(lim)./sqrt(size(lim,1))))],'m','EdgeColor','none');
        fill([-1+binSize/2:binSize:10,10-binSize/2:-binSize:-1],[(mean(nlm)+std(nlm)./sqrt(size(nlm,1))),(fliplr(mean(nlm)-std(nlm)./sqrt(size(nlm,1))))],'c','EdgeColor','none');
        
        plot(-1+binSize/2:binSize:10,mean(lim),'m:','LineWidth',1);
        plot(-1+binSize/2:binSize:10,mean(nlm),'c:','LineWidth',1);
        ylim([-2,7]);
        
        
        
        
        
        
        
        
        
        
        
        
        
%         text(8,diff(ylim())*0.9,sprintf('%05d',fidx),'HorizontalAlignment','center');
%
%             set(gcf,'PaperUnits','inches','PaperPosition',[0 0 12 6])
%             print('-r100','-dpng',['png\DNMS4s_Match_Case',sprintf('%05d',fidx),'.png']);
%             close all;
%  pause;
    end



end