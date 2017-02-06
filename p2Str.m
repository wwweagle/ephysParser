function str=p2Str(p)
if p<0.001
    str='***';
elseif p<0.05
    str=sprintf('%0.3f',p);
else
    str='n.s.';
end
end

