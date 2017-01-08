function plotSelectivity(data,filename)
binSize=0.5;
permed=permute(data,[1 3 2]);
avged=nanmean(permed,3);
avged(avged==0)=realmin;
selec=(avged(:,1:12/binSize)-avged(:,(1:12/binSize)+size(data,1)/2))./(avged(:,1:12/binSize)+avged(:,(1:12/binSize)+size(data,1)/2));
smoothed=selec;
for i=1:size(smoothed)
    smoothed(i,:)=smooth(selec(i,:));
end
[~,I]=max(smoothed(:,11:50),[],2);
selec(:,1)=I;

selec(:,2)=mean(selec(:,41:50),2);
% summed=sum(selec>0.25 | selec<-0.25)
sorted=sortrows(selec,1);
figure('Position',[100 100 400 300],'Color','w');
imagesc(sorted(:,6:end),[-0.5,0.5]);
colormap('jet');
colorbar();
yspan=ylim();
xy=[5,10,20,27.5,50,55];
for i=1:length(xy)
    line([xy(i),xy(i)],yspan,'LineStyle',':','LineWidth',0.5,'Color','w');
end

xlabel('Time (s)','FontName','Helvetica','FontSize',10);
set(gca,'XTick',0:5:55,'XTickLabel',{'','0','','','','','5','','','','','10'},'TickDir','out','box','off','FontSize',10,'FontName','Helvetica');

if exist('filename','var')
    writeFile(filename);
end




        
        
        function writeFile(fileName)
            towrite=questdlg('Save File ?','Save File');
            if strcmpi(towrite,'yes')
%                 dpath=javaclasspath('-dynamic');
%                 if ~ismember('..\Script\hel2arial\hel2arial.jar',dpath)
%                     javaaddpath('..\Script\hel2arial\hel2arial.jar');
%                 end
%                 h2a=hel2arial.Hel2arial;
                set(gcf,'PaperPositionMode','auto');
                %                 print('-depsc',[fileName,'.eps'],'-cmyk');
                savefig([fileName,'.fig']);
                %         close gcf;
                %                 h2a.h2a([pwd,'\',fileName,'.eps']);
            end
        end


% pause();
end
