function plotShowCaseWJ(fidx,tetidx,uidx,delayLen)

%30,45,1,8
%86,8,2,4
%
byLick=false;
binSize=0.25;
javaaddpath('R:\ZX\java\spk2fr\build\classes');
javaaddpath('R:\ZX\java\spk2fr\lib\jmatio.jar');
javaaddpath('R:\ZX\java\spk2fr\lib\commons-math3-3.5.jar');
javaaddpath('R:\ZX\java\DualEvtParser\build\classes');
s2f=spk2fr.Spk2fr;
% s2f.setWellTrainOnly(1);
% s2f.setRefracRatio(0.0015);
% s2f.setLeastFR('Average2Hz');
s2f.setRefracRatio(0.1);
s2f.setLeastFR('all');

fl=listF();
if delayLen==4
    fileList=fl.listDNMS4s();
elseif delayLen==8
    fileList=fl.listDNMS8s();
end
% [~,id]=allByTypeDNMS('sample','Average2Hz',-2,0.5,12,true,delayLen,true);
% id=evalin('base','idselA');
% fileList=id(:,1);


rLim=delayLen+2;% 9 for 4s delay, 13 for 8s delay


for fi=fidx%1:size(fileList)
    
    fprintf('fid: %d\n',fi);
%     disp(fileList{fi});
%     ft=load(fileList{fi});
    ft=load(fileList(fi,:));
    spk=ft.Spk;
    info=ft.TrialInfo;
%     genOne(spk,info,info(:,3)==info(:,4),true,tetidx,uidx,fi*10000+tetidx*100+uidx+1);
%     genOne(spk,info,info(:,3)==info(:,4),false,tetidx,uidx,fi*10000+tetidx*100+uidx+1);
%     genOne(spk,info,info(:,3)~=info(:,4),true,tetidx,uidx,fi*10000+tetidx*100+uidx+1);
%     genOne(spk,info,info(:,3)~=info(:,4),false,tetidx,uidx,fi*10000+tetidx*100+uidx+1);
     genOne(spk,info,true(size(info,1),1),true,tetidx,uidx,fi*10000+tetidx*100+uidx+1);

end
    
    function genOne(spk,info,filter,isCorrect,tetidx,uidx,fIdx)
        if(numel(spk)>1000)
            ts=s2f.getTS(info(filter,:),spk,'wjdnms',byLick,isCorrect);
            keys=s2f.getKeyIdx();
            for k=1:size(keys,1)
                if isequal([tetidx,uidx],keys(k,:)) && (~isempty(k))
                    plotOne(ts{k},fIdx);
                end
            end
        end
    end








    function plotOne(ts,fidx)
        %         pf=nan(0,0);
        %         bn=nan(0,0);
        figure('Color','w','Position',[1000,1000,280,280]);
        
        subplot('Position',[0.1,0.5,0.85,0.40]);
        hold on;
        
        if size(ts{1},1)==0
        elseif size(ts{1},1)==1
            plot([ts{1};ts{1}],repmat([21;21.8]+1,1,length(ts{1})),'-r');
        elseif size(ts{1},1)>20
            pos=round((length(ts{1})-20)/2);
            posRange=pos:pos+19;
            cellfun(@(x) plot([x{1}';x{1}'],repmat([x{2};x{2}+0.8]+1,1,length(x{1})),'-r'),cellfun(@(x,y) {x,y},ts{1}(posRange),num2cell(1:length(posRange),1)','UniformOutput',false));
        else
            posRange=1:size(ts{1},1);
            cellfun(@(x) plot([x{1}';x{1}'],repmat([x{2};x{2}+0.8]+1,1,length(x{1})),'-r'),cellfun(@(x,y) {x,y},ts{1}(posRange),num2cell(1:length(posRange),1)','UniformOutput',false));
        end
        
        

        if size(ts{2},1)==0
        elseif size(ts{2},1)==1
            plot([ts{2};ts{2}],repmat([21;21.8]+1,1,length(ts{2})),'-b');
        elseif size(ts{2},1)>20
            pos=round((length(ts{2})-20)/2);
            posRange=pos:pos+19;
            cellfun(@(x) plot([x{1}';x{1}'],repmat([x{2};x{2}+0.8]+1,1,length(x{1})),'-b'),cellfun(@(x,y) {x,y},ts{2}(posRange),num2cell([1:length(posRange)]+20,1)','UniformOutput',false));
        else
            posRange=1:size(ts{2},1);
            cellfun(@(x) plot([x{1}';x{1}'],repmat([x{2};x{2}+0.8]+1,1,length(x{1})),'-b'),cellfun(@(x,y) {x,y},ts{2}(posRange),num2cell([1:length(posRange)]+20,1)','UniformOutput',false));
        end    
        
        
        xlim([-1,rLim]);
        ylim([0,41]);
        set(gca,'XTick',[],'YTick',[0,18,23,40],'YTickLabel',[0,20,0,20]);
        assignin('base','axT',gca());
        plotSegs(delayLen);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot('Position',[0.1,0.1,0.85,0.35]);
        hold on;
        if size(ts{1},1)==0
            pfHist=zeros(size(-4+binSize/2:binSize:rLim));
        elseif size(ts{1},1)==1
            pfHist=histcounts(ts{1},-4:binSize:rLim)./binSize;
        else
            pfHist=cell2mat(cellfun(@(x) histcounts(x,-4:binSize:rLim)./binSize,ts{1},'UniformOutput',false));
            cia=bootci(1000,@(x) mean(x), pfHist);
            fill([-4+binSize/2:binSize:rLim,rLim-binSize/2:-binSize:-4],[cia(1,:),fliplr(cia(2,:))],[1,0.8,0.8],'EdgeColor','none');
        end
        if size(ts{2},1)==0
            bnHist=zeros(size(-4+binSize/2:binSize:rLim));
        elseif size(ts{2},1)==1
            bnHist=histcounts(ts{2},-4:binSize:rLim)./binSize;
        else
            bnHist=cell2mat(cellfun(@(x) histcounts(x,-4:binSize:rLim)./binSize,ts{2},'UniformOutput',false));
            cib=bootci(1000,@(x) mean(x), bnHist);
            fill([-4+binSize/2:binSize:rLim,rLim-binSize/2:-binSize:-4],[cib(1,:),fliplr(cib(2,:))],[0.8,0.8,1],'EdgeColor','none');
        end
        
        
        plot(-4+binSize/2:binSize:rLim,(mean(pfHist,1))','-r');
        plot(-4+binSize/2:binSize:rLim,(mean(bnHist,1))','-b');
        
        xlim([-1,rLim]);
        ylim([min(ylim()),max([cia(:);cib(:)])]);
        assignin('base','axB',gca());
        plotSegs(delayLen);
        set(gca,'XTick',[0,5,10],'YTick',[0,18,23,40],'YTickLabel',[0,20,0,20]);
        
        
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%
        
        if byLick
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
        end
    end




    function plotSegs(delayLen)
        vertLine=[0,1,1,2,3,3.5]+[0,0,ones(1,4).*delayLen];
        plot(repmat(vertLine,2,1),repmat(ylim()',1,length(vertLine)),'--k');
    end



end