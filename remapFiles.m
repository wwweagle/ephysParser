function out=remapFiles(in)
out=cell(size(in,1),1);
for i=1:size(in)
    tn=strtrim(in(i,:));
    out{i}=['H:\ZX\APC\DNMS\',tn(16:end-4),'_GRP.mat'];
end
out=char(out);

end