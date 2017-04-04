function out=trans8s(in,binSize,late)
% binSize=0.5;
if exist('late','var') && late
    oneTrial=[1:2/binSize,6/binSize+1:18/binSize];
else
    oneTrial=[1:6/binSize,10/binSize+1:18/binSize];
end
oneChunk=18/binSize;
out=in(:,:,[oneTrial,oneTrial+oneChunk,oneTrial+2*oneChunk,oneTrial+3*oneChunk]);

end
