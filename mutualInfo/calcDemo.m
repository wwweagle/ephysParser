
H=sum(-p_r.*log2(p_r));
% % sum(arrayfun(@(x) -x.*log2(x),histcounts(A,[unique(A),realmax])./length(A)));


% entropy=0;
% for i=unique(spkCount)
%     p_r=sum(spkCount==i)/length(spkCount);
%     entropy=entropy-p_r.*log2(p_r);
% end

trialCount=length([aSpkCount,bSpkCount]);
Hnoise=0;

p_s=length(aSpkCount)/trialCount;
for i=unique(aSpkCount)
    p_r_s=sum(aSpkCount==i)/length(aSpkCount);
    Hnoise=Hnoise-p_s*p_r_s*log2(p_r_s);
end


p_s=length(bSpkCount)/trialCount;
for i=unique(bSpkCount)
    p_r_s=sum(bSpkCount==i)/length(bSpkCount);
    Hnoise=Hnoise-p_s*p_r_s*log2(p_r_s);
end



trialCount=length([aSpkCount,bSpkCount]);
p_r=histcounts([aSpkCount,bSpkCount],unique([aSpkCount,realmax]))./trialCount;
p_s=length(aSpkCount)/trialCount;
p_r_s=histcounts(aSpkCount,[unique(aSpkCount),realmax])./trialCount;
Im=sum(p_r_s.*log2(p_r_s./(p_r.*p_s)));


p_r=histcounts([aSpkCount,bSpkCount],unique([bSpkCount,realmax]))./trialCount;
p_s=length(bSpkCount)/trialCount;
p_r_s=histcounts(bSpkCount,[unique(bSpkCount),realmax])./trialCount;
Im=Im+sum(p_r_s.*log2(p_r_s./(p_r.*p_s)));



%%%%%%%%%%Continuous
trialCount=length([aSpkCount,bSpkCount]);
p_r=histcounts([aSpkCount,bSpkCount],unique([aSpkCount,realmax]))./trialCount;
p_s=length(aSpkCount)/trialCount;
p_r_s=histcounts(aSpkCount,[unique(aSpkCount),realmax])./trialCount;
Im=sum(p_r_s.*log2(p_r_s./(p_r.*p_s)));





