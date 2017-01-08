function str=p2Str(p)
if p<0.001
    str='***';
elseif p<0.01
    str='**';
elseif p<0.05
    str='*';
else
    str='n.s.';
end
end

