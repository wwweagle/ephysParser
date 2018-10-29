function plotShowCase
binSize=0.5;
javaaddpath('R:\ZX\java\spk2fr\build\classes');
javaaddpath('R:\ZX\java\spk2fr\lib\jmatio.jar');
javaaddpath('R:\ZX\java\spk2fr\lib\commons-math3-3.5.jar');
javaaddpath('R:\ZX\java\DualEvtParser\build\classes');
s2f=spk2fr.Spk2fr;
% s2f.setWellTrainOnly(1);
s2f.setRefracRatio(0.0015);
s2f.setLeastFR('Average2Hz');
fl=listF();
% fileList=fl.listTrialF();
fileList=fl.listTrialFWJ();

rLim=18;
% rLim=13;



% toCell=[];

for fi=1:size(fileList,1)
    fprintf('fid: %d\n',fi);
    ft=load(fileList{fi});
    spk=ft.SPK;
    
    if(size(spk,1)>1000) && sum(ismember(0:2,unique(ft.EVT(:,3))))==3
        s2f.setRefracRatio(0.0015);
        s2f.setLeastFR('Average2Hz');
        s2f.getTS(ft.EVT,spk,'Dual',false);
        keysAll=s2f.getKeyIdx();
        if isempty(keysAll)
            continue;
        end
        s2f.setRefracRatio(0.1);
        s2f.setLeastFR('all');
        ts=cell(1,3);
        keys=cell(1,3);
        tsIdx=1;
        for btype=[0 2 1]
            evt=ft.EVT(ft.EVT(:,3)==btype,:);
            ts{tsIdx}=s2f.getTS(evt,spk,'Dual',false);
            if ~isempty(s2f.getKeyIdx())
                keys{tsIdx}=s2f.getKeyIdx();
            else
                keys{tsIdx}=[0,0];
            end
            ts{tsIdx}=ts{tsIdx}(ismember(keys{tsIdx},keysAll,'rows'),:);
            tsIdx=tsIdx+1;
        end
        
        for unit=1:size(ts{1},1)
            for cond=1:3
                plotOne(ts{cond}{unit},fi*100+unit,cond);
            end
            close all;
        end
    end
    
end



    function plotOne(ts,fidx,onetype)
        titles={'None','Nogo','Go'};
        if onetype==1
            figure('Color','w','Position',[1601,0,1366,768]);
        end
        subplot('Position',[0.05+(onetype-1)*0.33,0.745,0.266,0.22]);
        hold on;
        title(titles{onetype});
        if length(ts{1})>20
            pos=round((length(ts{1})-20)/2);
            posRange=pos:pos+19;
        else
            posRange=1:length(ts{1});
        end
        cellfun(@(x) plot([x{1}';x{1}'],repmat([x{2};x{2}+0.8]+1,1,length(x{1})),'-r'),cellfun(@(x,y) {x,y},ts{1}(posRange),num2cell(1:length(posRange),1)','UniformOutput',false));
        
        if length(ts{2})>20
            pos=round((length(ts{2})-20)/2);
            posRange=pos:pos+19;
        else
            posRange=1:length(ts{2});
        end
        cellfun(@(x) plot([x{1}';x{1}'],repmat([x{2};x{2}+0.8]+1,1,length(x{1})),'-b'),cellfun(@(x,y) {x,y},ts{2}(posRange),num2cell([1:length(posRange)]+20,1)','UniformOutput',false));
        
        xlim([-1,rLim]);
        ylim([0,41]);
        set(gca,'XTick',[],'YTick',[1,18,23,40],'YTickLabel',[1,20,1,20]);
        plotSegs(onetype);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot('Position',[0.05+(onetype-1)*0.33,0.3,0.266,0.4]);
        hold on;
        pfHist=cell2mat(cellfun(@(x) histcounts(x,-4:binSize:rLim)./binSize,ts{1},'UniformOutput',false));
        bnHist=cell2mat(cellfun(@(x) histcounts(x,-4:binSize:rLim)./binSize,ts{2},'UniformOutput',false));
        
        fill([-4+binSize/2:binSize:rLim,rLim-binSize/2:-binSize:-4],[(mean(pfHist)+std(pfHist)./sqrt(size(pfHist,1))),(fliplr(mean(pfHist)-std(pfHist)./sqrt(size(pfHist,1))))],[1,0.8,0.8],'EdgeColor','none');
        fill([-4+binSize/2:binSize:rLim,rLim-binSize/2:-binSize:-4],[(mean(bnHist)+std(bnHist)./sqrt(size(bnHist,1))),(fliplr(mean(bnHist)-std(bnHist)./sqrt(size(bnHist,1))))],[0.8,0.8,1],'EdgeColor','none');
        
        plot(-4+binSize/2:binSize:rLim,(mean(pfHist))','-r');
        plot(-4+binSize/2:binSize:rLim,(mean(bnHist))','-b');
        
        xlim([-1,rLim]);
        ylim([min(ylim()),max([mean(pfHist)+std(pfHist)./sqrt(size(pfHist,1)),mean(bnHist)+std(bnHist)./sqrt(size(bnHist,1))])]);
        plotSegs(onetype);
        %         text(8,diff(ylim())*0.9,sprintf('%05d',fidx),'HorizontalAlignment','center');
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%% Mutual Info   Selectivity    %%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        Im=nan(1,rLim+1);
        sel=nan(1,rLim+1);
        
        for t=1:length(Im)
            ImTend=t*2+6;
            aSpkCount=sum(pfHist(:,ImTend-1:ImTend),2)';
            bSpkCount=sum(bnHist(:,ImTend-1:ImTend),2)';
            trialCount=length([aSpkCount,bSpkCount]);
            p_r=histcounts([aSpkCount,bSpkCount],unique([aSpkCount,bSpkCount,intmax]))./trialCount;
            A=cellfun(@(x) histcounts(x,unique([aSpkCount,bSpkCount,intmax]))./trialCount,{aSpkCount,bSpkCount},'UniformOutput',false);
            im=sum(cell2mat(cellfun(@(p_rs) p_rs(p_rs>0).*log2(p_rs(p_rs>0)./(p_r(p_rs>0).*sum(p_rs))),A,'UniformOutput',false)));
            Im(t)=im;
            sel(t)=(mean(aSpkCount)-mean(bSpkCount))/(mean(aSpkCount)+mean(bSpkCount));
        end
        subplot('Position',[0.05+(onetype-1)*0.33,0.05,0.266,0.2]);
        hold on;
        lhIm=plot(-0.5:rLim,Im,'b');
        lhSel=plot(-0.5:rLim,sel,'r');
        xlim([-1,rLim]);
        ylim([-1,1]);
        plotSegs(onetype);
        set(gca,'YGrid','on');
        
        if onetype==3
            legend([lhIm,lhSel],{'Mutual Info','Selectivity'},'Location','SouthEast');
            export_fig(['pngNew\Dual13s_case_',sprintf('%05d',fidx),'.png'],'-nocrop');
        end
        
                function plotSegs(onetype)
                    switch onetype
                        case 1
                            vertLine=[0,1,14,15];
                        case 2
                            vertLine=[0,1,5,5.5,14,15];
                        case 3
                            vertLine=[0,1,5,5.5,6,6.5,14,15];
                    end
                    plot(repmat(vertLine,2,1),repmat(ylim()',1,length(vertLine)),':k');
                    plot(repmat([16,16.5],2,1),repmat(ylim()',1,2),'--k');
                end
        
        
%         function plotSegs(onetype)
%             switch onetype
%                 case 1
%                     vertLine=[0,1,9,10];
%                 case 2
%                     vertLine=[0,1,3,3.5,9,10];
%                 case 3
%                     vertLine=[0,1,3,3.5,4,4.5,9,10];
%             end
%             plot(repmat(vertLine,2,1),repmat(ylim()',1,length(vertLine)),':k');
%             plot(repmat([11,11.5],2,1),repmat(ylim()',1,2),'--k');
%         end
        
    end


end