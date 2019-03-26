close all
window=(-11:-8)+size(avgAccu,3);
mm=mean(avgAccu(:,:,(window),1),3);figure;imagesc(mm,[max(mm(:))*0.95,max(mm(:))]);colorbar;
mmconv=conv2(mm,gcore,'same');figure;imagesc(mmconv,[max(mmconv(:))*0.95,max(mmconv(:))]);colorbar;
crange=2.^(-5:0.1:5);
grange=2.^(-10:0.1:-2);
[cgmatc,cgmatg]=ndgrid(crange,grange);

[maxx,idx]=max(mmconv(:))

c0=cgmatc(idx)
g0=cgmatg(idx)

[cidx,gidx]=ind2sub(size(cgmatc),idx)

figure;hold on;plot(squeeze(avgAccu(cidx,gidx,:,1)));plot([2.5,4.5,size(avgAccu,3)+(-9.5:2:-7.5)].'*[1 1],[0,100],':k');ylim([45,100]);
plot([1,max(window)],[50,50],'-k');