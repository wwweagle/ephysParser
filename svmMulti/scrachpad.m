[sample3,ids3]=processAll('sample',3,[-2,0.5,13]);
[sample2,ids2]=processAll('sample',2,[-2,0.5,13]);
[sample12,ids12]=processAll('sample',12,[-2,0.5,13]);
[sample6,ids6]=processAll('sample',6,[-2,0.5,13]);
[sample4,ids4]=processAll('sample',4,[-2,0.5,13]);
[sample5,ids5]=processAll('sample',5,[-2,0.5,13]);
%%%%%%%%%  1        2       3       4      5         6

thresh=15;
sel=cellfun(@(x) size(x,2),sample3)>thresh & ...
    cellfun(@(x) size(x,2),sample2)>thresh & ...
    cellfun(@(x) size(x,2),sample12)>thresh & ...
    cellfun(@(x) size(x,2),sample6)>thresh & ...
    cellfun(@(x) size(x,2),sample4)>thresh & ...
    cellfun(@(x) size(x,2),sample5)>thresh;


samples={sample2(sel),sample3(sel),sample4(sel),sample5(sel),sample6(sel),sample12(sel)};
save('multiSamples.mat','samples');
