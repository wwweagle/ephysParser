delayLen=8;
set=unique(regexp(tagA(:,1),'(?<=\\)(M|Pir)\d+','match','once'));
ts=101;%61 for 4s last sec in delay, 101 for 8s
bars=[];
for setIdx=1:length(set)
    tagIdces=cellfun(@(x) ~isempty(x),strfind(tagA(:,1),set{setIdx}));
    countAll=sum(cellfun(@(x) size(x,2),sig{ts}(tagIdces)));
    countSig1=sum(sum(cell2mat(arrayfun(@(y) cellfun(@(x) sum(x<0.05),sig{ts+y}(tagIdces))',0:9,'UniformOutput',false)),2)>0);
    countSigAll=sum(sum(cell2mat(arrayfun(@(y) cellfun(@(x) sum(x<0.05),sig{ts+y}(tagIdces))',0:9,'UniformOutput',false)),2)>9);
    bars=[bars;countSigAll,countSig1-countSigAll,countAll-countSig1];
end
figure('Color','w','Position',[10,100,310,230]);
bh=bar(bars,'stacked');
bh(1).EdgeColor='k';
bh(2).EdgeColor='k';
bh(3).EdgeColor='k';
bh(1).FaceColor='r';
bh(2).FaceColor='b';
bh(3).FaceColor='w';

xlabel('Mouse #');
ylabel('Single Units');
if ts>21
    suffix='_Late';
else
    suffix='';
end
print('-depsc','-painters',sprintf('SU_Contrib_PerMouse_%d%s.eps',delayLen,suffix));
disp(sum(sum(bars(:,1:2),2)>0))
disp(size(bars,1));
disp(sum(bars(:)));