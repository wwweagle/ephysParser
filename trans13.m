function out=trans13(data,is6part)

if exist('is6part','var') && is6part
    partLen=size(data,3)/6;
    binLen=partLen/18;
    truncated=[1:3*binLen,5*binLen+1:13*binLen,16*binLen+1:18*binLen];
    out=data(:,:,[truncated,truncated+partLen,truncated+partLen*2,truncated+partLen*3,truncated+partLen*4,truncated+partLen*5]);
else
    partLen=size(data,3)/4;
    binLen=partLen/18;
    truncated=[1:3*binLen,5*binLen+1:13*binLen,16*binLen+1:18*binLen];
    out=data(:,:,[truncated,truncated+partLen,truncated+partLen*2,truncated+partLen*3]);
end
