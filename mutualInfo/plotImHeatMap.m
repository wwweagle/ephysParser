imMat=cell2mat(Im(:,2));
pMat=cell2mat(pCrossTime(:,2));
imMat(ismember(inAll(:,1),DelayLaserFiles),:)=[];
pMat(ismember(inAll(:,1),DelayLaserFiles),:)=[];



imMat(pMat>0.001)=0;

imMat(isnan(imMat) | isinf(imMat))=0;
% imFilt=

% for i=1:size(imMat,1)
%     for j=1:size(imMat,2)
%         if isnan(imMat(i,j)) || isinf(imMat(i,j))
%             imMat(i,j)=0;
%             k=j+1;
%             while isnan(imMat(i,k)) || isinf(imMat(i,k))
%                 k=k+1;
%             end
%             imMat(i,j:k-1)=imMat(i ,j-1)+(1:k-j).*(imMat(i,k)-imMat(i,j-1))/(k-j+1);
% %             imMat(i,j:k-1)=0;
%         end
%     end
% end

% disp(nnz(isinf(imMat)));
xPos=[1:size(pMat,2)]*0.1-1.75-0.1;
imImd=cell2mat(arrayfun(@(x) smooth(imMat(x,:)),1:size(imMat,1)','UniformOutput',false))';
imImd=imImd(:,9:89);
% imImd=imMat(:,9:89);
% [~,maxIdces]=max(imImd,[],2);
% [~,sortIdx]=sort(maxIdces);
fh=figure('Color','w','Position',[1700,400,320,240]);
meanIdces=-mean(imImd(:,19:79),2);
[~,sortIdx]=sort(meanIdces);

imagesc(xPos(9:89),1:size(imImd,1),imImd(sortIdx,:),[0,0.6]);
hold on;
arrayfun(@(x) plot([x,x],ylim(),':w'), [0,1,6,7]);
colormap('jet')
colorbar();
set(gca,'XTick',0:5:10,'YTick',[]);
xlabel('Time (s)');