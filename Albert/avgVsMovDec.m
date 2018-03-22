function avgVsMovDec
addpath('..');
addpath('..\mutualInfo\');
delayLen=4;
lf=listF();
if delayLen==4
    decodingByOdor=sampleByType(lf.listDNMS4s,'sample','Average2Hz',-2,0.5,7,[30,1;30,1],500,1);
 elseif delayLen==8
    decodingByOdor=sampleByType(lf.listDNMS8s,'sample','Average2Hz',-2,0.5,11,[30,1;30,1],500,1);
end
[Im,ImShuf,sel,selShuf]=plotIm('delay',delayLen);
% [~,iIdxIm]=sort(Im);
[~,iIdxSel]=sort(abs(sel));


delayPlusBoots=nan(ceil(length(Im)/5),500);
movedPlusBoots=nan(ceil(length(Im)/5),500);
samplePlusBoots=nan(ceil(length(Im)/5),500);
shufflePlusBoots=nan(ceil(length(Im)/5),500);


delayMinusBoots=nan(ceil(length(Im)/5),500);
movedMinusBoots=nan(ceil(length(Im)/5),500);
sampleMinusBoots=nan(ceil(length(Im)/5),500);
shuffleMinusBoots=nan(ceil(length(Im)/5),500);



grpLen=500;

pc=plotVarTCurve;

for i=1:(length(Im)+5)/5
    fprintf('%d,',i);
    farEnd=i*5;
    if farEnd>length(Im)
        farEnd=length(Im);
    end
    
%     delayPlusBoots(i,1:grpLen)=pc.plotAvgedDecoding(decodingByOdor(iIdxIm(1:farEnd),:,:),'delay');
%     movedPlusBoots(i,1:grpLen)=pc.plotDecoding(decodingByOdor(iIdxIm(1:farEnd),:,:));
%     samplePlusBoots(i,1:grpLen)=pc.plotAvgedDecoding(decodingByOdor(iIdxIm(1:farEnd),:,:),'sample');
%     shufflePlusBoots(i,1:grpLen)=pc.plotDecoding(decodingByOdor(iIdxIm(1:farEnd),:,:),'shuffle');
%     
%     delayMinusBoots(i,1:grpLen)=pc.plotAvgedDecoding(decodingByOdor(iIdxIm(i*5-4:end),:,:),'delay');
%     movedMinusBoots(i,1:grpLen)=pc.plotDecoding(decodingByOdor(iIdxIm(i*5-4:end),:,:));
%     sampleMinusBoots(i,1:grpLen)=pc.plotAvgedDecoding(decodingByOdor(iIdxIm(i*5-4:end),:,:),'sample');
%     shuffleMinusBoots(i,1:grpLen)=pc.plotDecoding(decodingByOdor(iIdxIm(i*5-4:end),:,:),'shuffle');
    
    delayPlusBoots(i,(1:grpLen))=pc.plotAvgedDecoding(decodingByOdor(iIdxSel(1:farEnd),:,:),'delay');
%     movedPlusBoots(i,(1:grpLen))=pc.plotDecoding(decodingByOdor(iIdxSel(1:farEnd),:,:));
%     samplePlusBoots(i,(1:grpLen))=pc.plotAvgedDecoding(decodingByOdor(iIdxSel(1:farEnd),:,:),'sample');
    shufflePlusBoots(i,1:grpLen)=pc.plotDecoding(decodingByOdor(iIdxSel(1:farEnd),:,:),'shuffle');
    
    farEnd=length(Im)-(i*5)+1;
    if farEnd<1
        farEnd=1;
    end
    
    
    delayMinusBoots(i,(1:grpLen))=pc.plotAvgedDecoding(decodingByOdor(iIdxSel(farEnd:end),:,:),'delay');
%     movedMinusBoots(i,(1:grpLen))=pc.plotDecoding(decodingByOdor(iIdxSel(i*5-4:end),:,:));
%     sampleMinusBoots(i,(1:grpLen))=pc.plotAvgedDecoding(decodingByOdor(iIdxSel(i*5-4:end),:,:),'sample');
    shuffleMinusBoots(i,1:grpLen)=pc.plotDecoding(decodingByOdor(iIdxSel(farEnd:end),:,:),'shuffle');
    
    
    
    
end

%     plotOne(delayPlusBoots,movedPlusBoots,samplePlusBoots,shufflePlusBoots,['imPlus_',num2str(delayLen),'s']);
    plotOne(delayPlusBoots,movedPlusBoots,samplePlusBoots,shufflePlusBoots,['selPlus_',num2str(delayLen),'s']);
%     plotOne(delayMinusBoots,movedMinusBoots,sampleMinusBoots,shuffleMinusBoots,['imMinus_',num2str(delayLen),'s']);
    plotOne(delayMinusBoots,movedMinusBoots,sampleMinusBoots,shufflePlusBoots,['selMinus_',num2str(delayLen),'s']);

end
