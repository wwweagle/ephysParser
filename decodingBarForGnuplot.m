function [ output_args ] = decodingBarForGnuplot( naive, early4s,late4s,data8s,forSample )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
binSize=0.5;
m=@(mat) mean(mat);
close all;
if forSample
%     stats=nan(6,14);%Actually 5timing*(4 learn stage * 3(mean+-sem)), will be changed to 7 timing(sample,q1,q2,q3,q4,test,pre-resp)
    stats=nan(8,14);
    avgD=cell(1,4); %4 learn stage, no change
%     avgD{1}=plotTrajectory(naive,(1:5)*5-5,{toBin(1,2),toBin(2,3),toBin(3,4),toBin(5,6),toBin(6,7)});%Pos-0     5    10    15    20

    avgD{1}=plotDecoding(naive,(1:7)*5-5,{toBin(1,2),toBin(2,3),toBin(3,4),toBin(5,6),toBin(6,7),toBin(7,8),toBin(8,9)});
    avgD{2}=plotDecoding(early4s,(1:7)*5-4,{toBin(1,2),toBin(2,3),toBin(3,4),toBin(4,5),toBin(5,6),toBin(6,7),toBin(7,8)});
    avgD{3}=plotDecoding(late4s,(1:7)*5-3,{toBin(1,2),toBin(2,3),toBin(3,4),toBin(4,5),toBin(5,6),toBin(6,7),toBin(7,8)});
    avgD{4}=plotDecoding(data8s,(1:7)*5-2,{toBin(1,2),toBin(2,4),toBin(4,6),toBin(6,8),toBin(8,10),toBin(10,11),toBin(11,12)});
    

    plotData=[];
    hold on;
   
    p=nan(1,7);
    for pp=1:7
        stats(pp+1,3:3:12)=mean([avgD{1}{pp},avgD{2}{pp},avgD{3}{pp},avgD{4}{pp}]);
        plotData=[plotData,avgD{1}{pp},avgD{2}{pp},avgD{3}{pp},avgD{4}{pp},nan(size(avgD{4}{pp}))];
        stats(pp+1,[4,5,7,8,10,11,13,14])=reshape(bootci(100,m,[avgD{1}{pp},avgD{2}{pp},avgD{3}{pp},avgD{4}{pp}]),1,8);
        [p(pp),tbl,~]=anova1([avgD{1}{pp},avgD{2}{pp},avgD{3}{pp},avgD{4}{pp}],[],'off');
        fprintf('sample\t%d Part\tone-way ANOVA\t\t%d\tnumber of neurons in bootstrapping resamples\t\terrorbars are mean +/- SEM\t\tp = %.2e\t\tF(%d, %d) = %.3f\n',pp,100,p(pp),tbl{2,3},tbl{3,3},tbl{2,5});
        stats(pp+1,2)=p(pp);
    end
    figure('Color','w','Position',[900,100,380,250]);
    hold on;
    line([5:5:30;5:5:30],repmat([0;1],1,6),'Color','k','LineStyle','--','LineWidth',0.5);
    
    bootmean=bootstrp(50,@(x) nanmean(x),plotData);
%     ci=bootci(100,@(x) nanmean(x),plotData);
    cc={[1,1,1],[0.8,0.8,0.8],[1,0.8,0.8],[0.8,0.8,1],[1,0.8,1]};
    ccm={[1,1,1],[0,0,0],[1,0,0],[0,0,1],[1,0,1]};
    for i=1:size(bootmean,2)
        bias=rand(50,1)*0.8-0.4;
        plot(i+bias,bootmean(:,i),'Marker','o','LineStyle','none','MarkerFaceColor',cc{mod(i,5)+1},'MarkerEdgeColor','none','MarkerSize',1);
%         plot(i,nanmean(plotData(:,i)),'Marker','o','LineStyle','none','MarkerFaceColor','none','MarkerEdgeColor',ccm{mod(i,5)+1},'MarkerSize',8,'LineWidth',1);
        if mod(i,5)~=0
            ci=bootci(100,@(x) mean(x),plotData(:,i));
            errorbar(i,nanmean(plotData(:,i)),nanmean(plotData(:,i))-ci(1),ci(2)-nanmean(plotData(:,i)),'o','Color',ccm{mod(i,5)+1});
        end
    end
    set(gca,'XTick',2.5:5:35,'XTickLabel',[],'TickDir','out');
    xlim([0,35]);
    ylim([0.48,1]);

    
    save('gnuplot_trajectory_stats.txt','stats','-ascii');
    system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\Script1608\gnuplotBarTraj.txt');
%     movefile('gnuTemp.eps','trajBar.eps');
    
    fprintf('anova ');
    fprintf('%.4f, ',p);
    fprintf('\n');
else
   
    stats=nan(3,14);
    avgD{1}=plotDecoding(naive,[0,5],{toBin(7,8),toBin(8,9)});
    avgD{2}=plotDecoding(early4s,[1,6],{toBin(6,7),toBin(7,8)});
    avgD{3}=plotDecoding(late4s,[2,7],{toBin(6,7),toBin(7,8)});
    avgD{4}=plotDecoding(data8s,[3,8],{toBin(10,11),toBin(11,12)});
    plotData=[];
    p=nan(1,5);
    for pp=1:2
        stats(pp+1,3:3:12)=mean([avgD{1}{pp},avgD{2}{pp},avgD{3}{pp},avgD{4}{pp}]);
        plotData=[plotData,avgD{1}{pp},avgD{2}{pp},avgD{3}{pp},avgD{4}{pp},nan(size(avgD{4}{pp}))];
        stats(pp+1,[4,5,7,8,10,11,13,14])=reshape(bootci(100,m,[avgD{1}{pp},avgD{2}{pp},avgD{3}{pp},avgD{4}{pp}]),1,8);
        [p(pp),tbl,~]=anova1([avgD{1}{pp},avgD{2}{pp},avgD{3}{pp},avgD{4}{pp}],[],'off');
        fprintf('sample\t%d Part\tone-way ANOVA\t\t%d\tnumber of neurons in bootstrapping resamples\t\terrorbars are mean +/- SEM\t\tp = %.2e\t\tF(%d, %d) = %.3f\n',pp,100,p(pp),tbl{2,3},tbl{3,3},tbl{2,5});
        stats(pp+1,2)=p(pp);
    end
    
        figure('Color','w','Position',[900,100,125,250]);
    hold on;
    line([5;5],[0;1],'Color','k','LineStyle','--','LineWidth',0.5);
    
    bootmean=bootstrp(50,@(x) nanmean(x),plotData);
%     ci=bootci(100,@(x) nanmean(x),plotData);
    cc={[1,1,1],[0.8,0.8,0.8],[1,0.8,0.8],[0.8,0.8,1],[1,0.8,1]};
    ccm={[1,1,1],[0,0,0],[1,0,0],[0,0,1],[1,0,1]};
    for i=1:size(bootmean,2)
        bias=rand(50,1)*0.8-0.4;
        plot(i+bias,bootmean(:,i),'Marker','o','LineStyle','none','MarkerFaceColor',cc{mod(i,5)+1},'MarkerEdgeColor','none','MarkerSize',1);
%         plot(i,nanmean(plotData(:,i)),'Marker','o','LineStyle','none','MarkerFaceColor','none','MarkerEdgeColor',ccm{mod(i,5)+1},'MarkerSize',8,'LineWidth',1);
        if mod(i,5)~=0
            ci=bootci(100,@(x) mean(x),plotData(:,i));
            errorbar(i,nanmean(plotData(:,i)),nanmean(plotData(:,i))-ci(1),ci(2)-nanmean(plotData(:,i)),'o','Color',ccm{mod(i,5)+1});
        end
    end
    set(gca,'XTick',[2.5,7.5],'XTickLabel',[],'TickDir','out');
    xlim([0,10]);
    ylim([0.5,1]);
    
    
    save('gnuplot_trajectory_stats.txt','stats','-ascii');
    system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\Script1608\gnuplotBarTraj.txt');
%     movefile('gnuTemp.eps','trajMatchBar.eps');
    
    fprintf('anova ');
    fprintf('%.4f, ',p);
    fprintf('\n');
end


        function [pf1,pf2,bn1,bn2]=getSampleBins(samples,delay,repeat)
            start=1/binSize+1;
            stop=delay/binSize+4/binSize;
            delta=delay/binSize+5/binSize;
            SUCount=size(samples,1);
            if SUCount>100
                selectedSU=randperm(SUCount,100);
            else
                selectedSU=1:SUCount;
            end
            pf1=samples(selectedSU,start:stop,repeat)';
            pf2=samples(selectedSU,start+delta:stop+delta,repeat)';
            bn1=samples(selectedSU,start+delta*2:stop+delta*2,repeat)';
            bn2=samples(selectedSU,start+delta*3:stop+delta*3,repeat)';
        end


    function dAvg=plotDecoding(samples,Qx,periods)
        delay=size(samples,3)*binSize/4-5;
        samples=permute(samples,[1,3,2]);
        repeats=size(samples,3);
        
        decoded=nan(repeats,1);
        [pf1,~,~,~]=getSampleBins(samples,delay,1);
        bins=size(pf1,1);
        out=nan(size(pf1,1),repeats);
        for bin=1:bins
%         for i=1:length(Qx)
            for repeat=1:repeats
                [pf1,pf2,bn1,bn2]=getSampleBins(samples,delay,repeat);
                if rand<0.5 % Use PF Test
%                     corrPF=corrcoef(flat(pf2(periods{i},:)),flat(pf1(periods{i},:)));
%                     corrBN=corrcoef(flat(pf2(periods{i},:)),flat(bn1(periods{i},:)));
                    corrPF=corrcoef(flat(pf2(bin,:)),flat(pf1(bin,:)));
                    corrBN=corrcoef(flat(pf2(bin,:)),flat(bn1(bin,:)));

                    decoded(repeat)=corrPF(1,2)>corrBN(1,2);
                    
                else % Use BN Test
                    corrPF=corrcoef(flat(bn2(bin,:)),flat(pf1(bin,:)));
                    corrBN=corrcoef(flat(bn2(bin,:)),flat(bn1(bin,:)));
                    decoded(repeat)=corrBN(1,2)>corrPF(1,2);
                end
            end
            out(bin,:)=decoded;
        end
%         dAvg{i}=decoded;
%         end
        dist=permute(out,[2,1]);

        for i=1:length(Qx)
%             avg=mean(mean(dist(:,periods{i})));
            dAvg{i}=mean(dist(:,periods{i}),2);
        end
        
    end

    function out=flat(in)
        out=in(:);
    end

    function out=toBin(start,bEnd)
        out=start/binSize+1:bEnd/binSize;
    end

%     function writeFile(fileName)
%         towrite=questdlg('Save File ?','Save File');
%         if strcmpi(towrite,'yes')
%             dpath=javaclasspath('-dynamic');
%             if ~ismember('..\Script\hel2arial\hel2arial.jar',dpath)
%                 javaaddpath('..\Script\hel2arial\hel2arial.jar');
%             end
%             h2a=hel2arial.Hel2arial;
%             set(gcf,'PaperPositionMode','auto');
%             print('-depsc',[fileName,'.eps'],'-cmyk');
%             %         close gcf;
%             h2a.h2a([pwd,'\',fileName,'.eps']);
%         end
%     end
end

