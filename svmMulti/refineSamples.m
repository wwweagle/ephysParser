%%%%The whole pipeline is stupid but works. It would be used once or twice
%%%%so 

inAll=intersect(ids12,intersect(ids6,intersect(ids5,intersect(ids4,intersect(ids2,ids3,'rows'),'rows'),'rows'),'rows'),'rows');
sample2=rmvPart(sample2,ids2,inAll);
sample3=rmvPart(sample3,ids3,inAll);
sample4=rmvPart(sample4,ids4,inAll);
sample5=rmvPart(sample5,ids5,inAll);
sample6=rmvPart(sample6,ids6,inAll);
sample12=rmvPart(sample12,ids12,inAll);

function [cellId,matId]=projBack(samplesIn,id)
counts=(cellfun(@(x) size(x,1),samplesIn));
sums=arrayfun(@(x) sum(counts(1:x)),1:length(counts));
cellId=find(id>sums,1,'last')+1;
matId=id-sums(cellId-1);
end


function out=rmvPart(sample2,ids2,inAll)
rmv2=find(~ismember(ids2,inAll,'rows'))';
if numel(rmv2)>0
cids=[];
uids=[];
for r=rmv2
    [cids(end+1),uids(end+1)]=projBack(sample2,r);
end

for c=unique(cids)
    sample2{c}(uids(cids==c),:,:)=[];
end
sample2(cellfun(@(x) isempty(x), sample2))=[];
end
out=sample2;
end