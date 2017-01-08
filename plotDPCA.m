function plotDPCA(data)
figure('Color','w','Position',[2000,100,350,250]);
% figure('Color','w','Position',[2000,100,1280,720]);
subplot('Position',[0.15,0.15,0.5,0.8]);
hold on;
binSize=0.5;
cmp=[4,5,7];
% set(gca,'XTick',[],'YTick',[],'ZTick',[]);
xlabel('Sample PC1');
ylabel('Sample PC2');
zlabel('Distractor PC1');
color={'b','r'};
lt={':','-.','-'};

% for t=1:20
%     clf;
%     hold on;
    view([55,5]);
    xlim([-20,20]);
    ylim([-10,10]);
    zlim([-100,150]);
    
    vName='dpcaVideo.mp4';
    v=VideoWriter(vName,'Uncompressed AVI');
    v.FrameRate=2;
%     v.Quality=95;
open(v);

legS={'PF sample, ','BN sample, '};
legD={'No distractor, ','No-go distractor, ','Go distractor, '};


for d=1:3
    for s=1:2
        for pEnd=16
%                 clf;
                he=zplot3(squeeze(data(cmp(1),s,d,5:8)),squeeze(data(cmp(2),s,d,5:8)),squeeze(data(cmp(3),s,d,5:8)),[lt{d},color{s},'+'],0,pEnd);
                zplot3(squeeze(data(cmp(1),s,d,8:9)),squeeze(data(cmp(2),s,d,8:9)),squeeze(data(cmp(3),s,d,8:9)),[lt{d},color{s}],4,pEnd);
                hd=zplot3(squeeze(data(cmp(1),s,d,9:11)),squeeze(data(cmp(2),s,d,9:11)),squeeze(data(cmp(3),s,d,9:11)),[lt{d},color{s},'o'],5,pEnd);
                zplot3(squeeze(data(cmp(1),s,d,11:12)),squeeze(data(cmp(2),s,d,11:12)),squeeze(data(cmp(3),s,d,11:12)),[lt{d},color{s}],7,pEnd);
                hl=zplot3(squeeze(data(cmp(1),s,d,12:end)),squeeze(data(cmp(2),s,d,12:end)),squeeze(data(cmp(3),s,d,12:end)),[lt{d},color{s},'.'],8,pEnd);

%                 if pEnd<4
%                     legend(he,{[legS{s},legD{d},' early delay']},'FontSize',12,'Location','none','Position',[0.7,0.7,0.25,0.1]);
%                 elseif pEnd>5 && pEnd<8
%                     legend(hd,{[legS{s},legD{d},' distractor']},'FontSize',12,'FontSize',12,'Location','none','Position',[0.7,0.7,0.25,0.1]);
%                 elseif pEnd>8
%                     legend(hl,{[legS{s},legD{d},' late delay']},'FontSize',12,'FontSize',12,'Location','none','Position',[0.7,0.7,0.25,0.1]);
%                 end
%                 pause;
        f=getframe(gcf);
        writeVideo(v,f);
            end
        end
        
    end
    close(v);
% pause;    
% end

% set(gca,'XTick',[],'YTick',[],'ZTick',[]);

% xlabel('Sample dPC 1');
% ylabel('Sample dPC 2');
% zlabel('Distractor dPC 1');

    function out=zplot3(X,Y,Z,s,accu,pEnd)
         if accu+length(X)<pEnd
             out=plot3(X,Y,Z,s);
         elseif pEnd>accu && pEnd<=accu+length(X)
             len=pEnd-accu;
             out=plot3(X(1:len),Y(1:len),Z(1:len),s);
         else
             out=plot3(10000,10000,10000);
         end
     end
end