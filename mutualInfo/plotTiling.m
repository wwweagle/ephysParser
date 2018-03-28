load Im4sDNMS.mat
% load Im8s.mat
pMat=cell2mat(pCrossTime(:,2));
imMat=cell2mat(Im(:,2));
xPos=[1:size(pMat,2)]*0.1-1.75-0.1;

sdtTS=19:(19+59);%+40;
transient=false(size(pMat,1),1);
sust=false(size(pMat,1),1);
peak=zeros(size(pMat,1),1);

for u=1:size(pMat,1)
    tVec=pMat(u,sdtTS);
    for i=1:length(sdtTS)-29
        if all(tVec(i:i+29)<0.001)
            sust(u)=true;
            break;
        end
    end
    if ~sust(u)
        for i=1:length(sdtTS)-4
            if all(tVec(i:i+4)<0.001)
                transient(u)=true;
                break;
            end
        end
    end
    
    if sust(u) || transient(u)
        [~,peak(u)]=max(smooth(imMat(u,sdtTS)));
    end
end

fh=plotTile(transient,sdtTS,xPos,imMat,peak);
savefig(fh,'tileTransient.fig','compact');
fh=plotTile(sust,sdtTS,xPos,imMat,peak);
savefig(fh,'tileSust.fig','compact');

function fh=plotTile(selection,sdtTS,xPos,imMat,peak)
fh=figure();
cmap=colormap('cool');
close(fh);
fh=figure('Color','w','Position',[100,100,395,230]);
hold on;
disp('new tile');
for pIdx=1:3:60-5
    oids=find(selection & ismember(peak,(pIdx:pIdx+5)));
    if ~isempty(oids)
        [~,maxIdx]=sort(max(imMat(oids,sdtTS(pIdx:pIdx+5)),[],2),'descend');
        plot(xPos([13:18,sdtTS]),smooth(imMat(oids(maxIdx(1)),[13:18,sdtTS])),'-','Color',(cmap(peak(oids(maxIdx(1))),:)),'LineWidth',2);
        fprintf('%d,',oids(maxIdx(1)));
%         if numel(maxIdx)>1
%             plot(xPos([13:18,sdtTS]),smooth(imMat(oids(maxIdx(2)),[13:18,sdtTS])),'-','Color',(cmap(peak(oids(maxIdx(2))),:)),'LineWidth',2);
%             fprintf('%d,',oids(maxIdx(2)));
%         end
    end
end

% for u=find(selection)'
%     plot(xPos([13:18,sdtTS]),smooth(imMat(u,[13:18,sdtTS])),'-','Color',[cmap(peak(u),:)],'LineWidth',1);
% end
arrayfun(@(x) plot([x,x],[-1,1],':k'),[0,1,5,6]);
% set(gca,'Color',[0.5,0.5,0.5]);
xlim([-0.5,6]);
ylim([-0.05,max(max(imMat(selection,sdtTS)))+0.05]);
colormap('cool');
set(gca,'XTick',0:5:10);
cbh=colorbar('Ticks',[0:2:6]/6.4,'TickLabels',0:2:6);
xlabel('Time (s)');
ylabel('Sample Im (bits)');
cbh.Label.String='Peak Im time (s)';
cbh.Label.FontSize=12;
end


function genIdxForSVM
pMat=cell2mat(p(:,2));
imMat=cell2mat(Im(:,2));
transient=false(size(pMat,1),1);
sust=false(size(pMat,1),1);
for u=1:size(pMat,1)
    tVec=pMat(u,sdtTS);
    for i=1:length(sdtTS)-29
        if all(tVec(i:i+29)<0.001)
            sust(u)=true;
            break;
        end
    end
    if ~sust(u)
        for i=1:length(sdtTS)-4
            if all(tVec(i:i+4)<0.001)
                transient(u)=true;
                break;
            end
        end
    end
    
    if sust(u) || transient(u)
        [~,peak(u)]=max(smooth(imMat(u,sdtTS)));
    end
end
end


function prepareSU4SVM
expTagA=cell(0,0);
for i=1:length(tagA)
    for j=1:size(tagA{i,2},1)
        expTagA=[expTagA;{tagA{i,1},tagA{i,2}(j,:)}];
    end
end

expTransient=false(length(expTagA),1);
expSust=false(length(expTagA),1);

for i=1:length(expTagA)
    for j=1:length(p)
        if strcmp(expTagA{i,1},p{j,1}{1}) && all(expTagA{i,2}==p{j,1}{2})
            expTransient(i)=transient(j);
            expSust(i)=sust(j);
        end
    end
end


expSpkCA=cell(0,0);
for i=1:length(spkCA)
    for j=1:size(spkCA{i},1)
        expSpkCA=[expSpkCA;{spkCA{i}(j,:,:)}];
    end
end

expSpkCB=cell(0,0);
for i=1:length(spkCB)
    for j=1:size(spkCB{i},1)
        expSpkCB=[expSpkCB;{spkCB{i}(j,:,:)}];
    end
end

backSpkCA=spkCA;
backSpkCB=spkCB;

spkCA=expSpkCA(expTransient);
spkCB=expSpkCB(expTransient);

save('4sTransientDec4SVM.mat','spkCA','spkCB');


spkCA=expSpkCA(expSust);
spkCB=expSpkCB(expSust);

save('4sSustDec4SVM.mat','spkCA','spkCB');


spkCA=expSpkCA(~(expSust|expTransient));
spkCB=expSpkCB(~(expSust|expTransient));

save('4sNoImDec4SVM.mat','spkCA','spkCB');
end