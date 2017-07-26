function expanded=expand(fl)
if size(fl,2)==2
    expanded=cell(sum(cellfun(@(x) size(x,1),fl(:,2))),5);
    idx=1;
    for i=1:size(fl,1)
        pairs=fl{i,2};
        for j=1:size(fl{i,2},1)
            expanded(idx,:)={fl{i,1},pairs(j,1),pairs(j,2),i,j};
            idx=idx+1;
        end
    end
else
    expanded=cell(sum(cellfun(@(x) size(x,1),fl)),1);
    idx=1;
    for i=1:size(fl,1)
        all=fl{i};
        for j=1:size(all,1)
            expanded{idx}=squeeze(all(j,:,:));
            idx=idx+1;
        end
    end
end

end