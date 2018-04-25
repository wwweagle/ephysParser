% load Im4sDNMS.mat
% load Im8s.mat
% inFile='Im4sDNMS.mat';
% inFile='ImDualAll8s.mat';
inFile='ImDualAll13s.mat';
% inFile='im8sDNMS.mat';
% 
% inFile='imMultiSample5s.mat';

load(inFile);
pMat=cell2mat(pCrossTime(:,2));
imMat=cell2mat(Im(:,2));


xPos=[1:size(pMat,2)]*0.1-1.75-0.1;

switch size(imMat,2)
    case 126
        sdtTS=19:(19+59);
    case 166
        sdtTS=19:(19+59)+40;
    case 136
        sdtTS=19:(19+59)+10;
    case 146
        sdtTS=19:(19+59)+10;
    case 216
        sdtTS=19:(19+59)+90;
end


for i=1:size(imMat,1)
    for j=13:max(sdtTS)
        if isnan(imMat(i,j)) || isinf(imMat(i,j))
            imMat(i,j)=0;
            k=j+1;
            while isnan(imMat(i,k)) || isinf(imMat(i,k))
                k=k+1;
            end
            imMat(i,j:k-1)=imMat(i ,j-1)+(1:k-j).*(imMat(i,k)-imMat(i,j-1))/(k-j+1);
             imMat(i,j:k-1)=0;
        end
    end
end


transient=false(size(pMat,1),1);
sust=false(size(pMat,1),1);
peak=zeros(size(pMat,1),1);

for u=1:size(pMat,1)
    tVec=pMat(u,sdtTS);
    iVec=imMat(u,sdtTS);
    for i=1:length(sdtTS)-29
        if all(isnan(tVec(i:i+29)) | tVec(i:i+29)<0.001) && all(iVec(i:i+29)>0)
            sust(u)=true;
            break;
        end
    end
    if ~sust(u)
        for i=1:length(sdtTS)-4
            if all(isnan(tVec(i:i+4))| tVec(i:i+4)<0.001) && all(iVec(i:i+4)>0)
                transient(u)=true;
                break;
            end
        end
    end
    
    if sust(u) || transient(u)
        [~,peak(u)]=max(smooth(imMat(u,sdtTS)));
    end
end
fh=plotBothTile(transient,sust,sdtTS,xPos,imMat,peak);
% fh=plotTile(transient,sdtTS,xPos,imMat,peak);
% % ylim([-0.05,0.3]);
% savefig(fh,[replace(inFile,'.mat',''),'tileTransient.fig'],'compact');
% if nnz(sust)>0
%     fh=plotTile(sust,sdtTS,xPos,imMat,peak);
%     savefig(fh,[replace(inFile,'.mat',''),'tileSust.fig'],'compact');
% end
fprintf('\n%s, %.4f, %.4f\n',inFile,nnz(sust)/length(sust),nnz(transient)/length(transient));



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
        if numel(maxIdx)>1
            plot(xPos([13:18,sdtTS]),smooth(imMat(oids(maxIdx(2)),[13:18,sdtTS])),'-','Color',(cmap(peak(oids(maxIdx(2))),:)),'LineWidth',2);
            fprintf('%d,',oids(maxIdx(2)));
        end
    end
end

% for u=find(selection)'
%     plot(xPos([13:18,sdtTS]),smooth(imMat(u,[13:18,sdtTS])),'-','Color',[cmap(peak(u),:)],'LineWidth',1);
% end
if length(sdtTS)==60
    arrayfun(@(x) plot([x,x],[-1,1],':k'),[0,1,5,6]);
    xlim([-0.5,6]);
elseif length(sdtTS)==70
        arrayfun(@(x) plot([x,x],[-1,1],':k'),[0,1,6,7]);
        xlim([-0.5,7]);
else
    arrayfun(@(x) plot([x,x],[-1,1],':k'),[0,1,3,3.5,4,4.5,9,10]);
    xlim([-0.5,10]);
end

ylim([-0.05,max(max(imMat(selection,sdtTS)))+0.05]);
colormap('cool');
set(gca,'XTick',0:5:10);
cbh=colorbar('Ticks',[0:2:6]/6.4,'TickLabels',0:2:6);
xlabel('Time (s)');
ylabel('Sample Im (bits)');
cbh.Label.String='Peak Im time (s)';
cbh.Label.FontSize=12;
end


function fh=plotBothTile(seqt,sust,sdtTS,xPos,imMat,peak)
fh=figure();
cmap=colormap('cool');
close(fh);
fh=figure('Color','w','Position',[100,100,395,230]);
hold on;
disp('new tile');
for pIdx=1:3:60-5
    oids=find(seqt & ismember(peak,(pIdx:pIdx+5)));
    if ~isempty(oids)
        [~,maxIdx]=sort(max(imMat(oids,sdtTS(pIdx:pIdx+5)),[],2),'descend');
        plot(xPos([13:18,sdtTS]),smooth(imMat(oids(maxIdx(1)),[13:18,sdtTS])),'-','Color',(cmap(peak(oids(maxIdx(1))),:)),'LineWidth',2);
        fprintf('%d,',oids(maxIdx(1)));
        if numel(maxIdx)>1
            plot(xPos([13:18,sdtTS]),smooth(imMat(oids(maxIdx(2)),[13:18,sdtTS])),'-','Color',(cmap(peak(oids(maxIdx(2))),:)),'LineWidth',2);
            fprintf('%d,',oids(maxIdx(2)));
        end
    end
end

for pIdx=1:3:60-5
    oids=find(sust & ismember(peak,(pIdx:pIdx+5)));
    if ~isempty(oids)
        [~,maxIdx]=sort(max(imMat(oids,sdtTS(pIdx:pIdx+5)),[],2),'descend');
        plot(xPos([13:18,sdtTS]),smooth(imMat(oids(maxIdx(1)),[13:18,sdtTS])),'-k','LineWidth',2);
        fprintf('%d,',oids(maxIdx(1)));
    end
end

% for u=find(selection)'
%     plot(xPos([13:18,sdtTS]),smooth(imMat(u,[13:18,sdtTS])),'-','Color',[cmap(peak(u),:)],'LineWidth',1);
% end
if length(sdtTS)==60
    arrayfun(@(x) plot([x,x],[-1,1],':k'),[0,1,5,6]);
    xlim([-0.5,6]);
elseif length(sdtTS)==70
    arrayfun(@(x) plot([x,x],[-1,1],':k'),[0,1,6,7]);
    xlim([-0.5,7]);
else
    arrayfun(@(x) plot([x,x],[-1,1],':k'),[0,1,3,3.5,4,4.5,9,10]);
    xlim([-0.5,10]);
end

% ylim([-0.05,max(max(imMat(seqt,sdtTS)))+0.05]);
ylim([-0.05,0.5]);
colormap('cool');
set(gca,'XTick',0:5:10);
cbh=colorbar('Ticks',[0:2:6]/6.4,'TickLabels',0:2:6);
xlabel('Time (s)');
ylabel('Sample Im (bits)');
cbh.Label.String='Peak Im time (s)';
cbh.Label.FontSize=12;
end



function genIdxForSVM
pMat=cell2mat(pCrossTime(:,2));
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
% delayLen=4;
% [spkCA,tagA]=allByTypeDNMS('sample','Average2Hz',-2,0.5,delayLen+7,true,delayLen,true);
% [spkCB,tagB]=allByTypeDNMS('sample','Average2Hz',-2,0.5,delayLen+7,false,delayLen,true);

expTagA=cell(0,0);
for i=1:length(tagA)
    for j=1:size(tagA{i,2},1)
        expTagA=[expTagA;{tagA{i,1},tagA{i,2}(j,:)}];
    end
end

expTransient=false(length(expTagA),1);
expSust=false(length(expTagA),1);

for i=1:length(expTagA)
    for j=1:length(pCrossTime)
        if strcmp(expTagA{i,1},pCrossTime{j,1}{1}) && all(expTagA{i,2}==pCrossTime{j,1}{2})
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

save([replace(inFile,'.mat',''),'TransientDec4SVM.mat'],'spkCA','spkCB');

if nnz(expSust)>1
spkCA=expSpkCA(expSust);
spkCB=expSpkCB(expSust);

save([replace(inFile,'.mat',''),'SustDec4SVM.mat'],'spkCA','spkCB');
end

spkCA=expSpkCA(~(expSust|expTransient));
spkCB=expSpkCB(~(expSust|expTransient));

save([replace(inFile,'.mat',''),'NoImDec4SVM.mat'],'spkCA','spkCB');
end