function out=trans8s(in,binSize)
% binSize=0.5;
oneTrial=[1:6/binSize,10/binSize+1:18/binSize];
oneChunk=18/binSize;
out=in(:,:,[oneTrial,oneTrial+oneChunk,oneTrial+2*oneChunk,oneTrial+3*oneChunk]);
end
