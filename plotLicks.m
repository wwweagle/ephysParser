function out=plotLicks
javaaddpath('r:\ZX\Tools\zmat.jar');
javaaddpath('..\Script\hel2arial\hel2arial.jar');
f=listSer();
z=zmat.ZmatDual();
h2a=hel2arial.Hel2arial;
z.setFullSession(24);
out=cell(length(f),6);
for i=1:length(f)
    z.processFile(f{i});
    l=z.getTrialLick(1000);
    lSub=cell(1,6);
    lSub{1}=l(l(:,4)==12 & l(:,3)<3,1:2);
    lSub{2}=l(l(:,4)==2 & l(:,3)<3,1:2);
    lSub{3}=l(l(:,4)==1 & l(:,3)<3,1:2);
    lSub{4}=l(l(:,4)==12 & l(:,3)>2,1:2);
    lSub{5}=l(l(:,4)==2 & l(:,3)>2,1:2);
    lSub{6}=l(l(:,4)==1 & l(:,3)>2,1:2);
    for s=1:6
        out{i,s}=histcounts(lSub{s}(:,2),-10000:100:5000)./length(unique(lSub{s}(:,1))).*10;
    end
end
titles={'Paired, no distractor','Paired, no-go distractor','Paired, go distractor','Non-paired, no distractor','Non-paired, no-go distractor','Non-paired, go distractor'};
for i=1:6
    figure('Position',[100,100,400,300],'Color','w');
    one=cell2mat(out(:,i));
    plot(mean(one),'-k','LineWidth',1);
    sem=std(one)./sqrt(size(one,1));
    errorbar(mean(one),sem,'-k.');
    set(gca,'XTick',10:20:150,'XTickLabel',0:2:14,'FontSize',10,'FontName','Helvitica');
    xlabel('Time (s)');
    ylabel('Lick Freq (Hz)');
    xlim([0,150]);
    ylim([0,10]);
    title(titles{i});
    line([10,10],[0,10],'LineStyle','--','Color','k','LineWidth',0.5);
    line([20,20],[0,10],'LineStyle','--','Color','k','LineWidth',0.5);
    line([40,40],[0,10],'LineStyle','--','Color','k','LineWidth',0.5);
    line([50,50],[0,10],'LineStyle','--','Color','k','LineWidth',0.5);
    line([100,100],[0,10],'LineStyle','--','Color','k','LineWidth',0.5);
    line([110,110],[0,10],'LineStyle','--','Color','k','LineWidth',0.5);
    writeFile(titles{i});
end
    



    function f=listSer()
        all=ls();
        f=cell(2,1);
        fIdx=1;
        for i=3:size(all,1)
            if exist(strtrim(all(i,:)),'file')==7
                cd(strtrim(all(i,:)));
                ft=ls('*.ser');
                ft=[repmat([pwd(),'\'],size(ft,1),1),ft];
                for j=1:size(ft,1)
                    f{fIdx}=strtrim(ft(j,:));
                    fIdx=fIdx+1;
                end
                cd('..');
            end
        end
    end

    function writeFile(fileName)
        
%         dpath=javaclasspath('-dynamic');
%         if ~ismember('..\Script\hel2arial\hel2arial.jar',dpath)
%             javaaddpath('..\Script\hel2arial\hel2arial.jar');
%         end
        h2a=hel2arial.Hel2arial;
        set(gcf,'PaperPositionMode','auto');
        %                 print('-depsc',[fileName,'.eps'],'-cmyk');
        print('-depsc',[fileName,'.eps']);
        
        h2a.h2a([pwd,'\',fileName,'.eps']);
        
    end
end