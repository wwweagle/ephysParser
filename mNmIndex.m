function mNmIndex(match,nonMatch,matchError,nonMatchError,selId,inclusion,delay)

idxCorr=oneGrp(match,nonMatch,selId,inclusion, delay);
idxEror=oneGrp(matchError,nonMatchError,selId,inclusion, delay);

idxCorr(isnan(idxEror))=nan;


% [~,idx]=sort(mean(idxCorr,2));
[~,idx]=sort(idxCorr);

idx=idx(1:sum(~isnan(idxCorr(:,1))));


% cidata=idxCorr(idx,:);
% ci=bootci(100,@(x) mean(x),cidata')-mean(idxCorr(idx),2)';


figure('Color','w','Position',[100,100,350,250]);
subplot('Position',[0.15,0.15,0.75,0.7])
hold on;

% hc=plot(idxCorr(idx),'r.','MarkerFaceColor','r');
% he=plot(idxEror(idx),'k.','MarkerFaceColor','k');
he=plot(idxCorr(idx),idxEror(idx),'k.','MarkerFaceColor','k');
% errorbar(1:length(idx),mean(idxCorr(idx),2),ci(1,:)-ci(2,:),'.r','LineWidth',1);
assignin('base','idxCorr',idxCorr);
assignin('base','idxEror',idxEror);
text(0.8,0.8,['n = ',num2str(length(idx))],'FontName','Helvetica','FontSize',10);
[r,p]=corrcoef(idxCorr(idx),idxEror(idx));
text(0.8,0.86,['p = ',sprintf('%.3f',p(1,2))],'FontName','Helvetica','FontSize',10);
text(0.8,0.92,['r = ',sprintf('%.3f',r(1,2))],'FontName','Helvetica','FontSize',10);
r=polyfit(idxCorr(idx),idxEror(idx),1)
fplot(@(x) r(1)*x+r(2),[-1,1],'k:','LineWidth',1);
% xlim([0,length(idx)+1]);
% xlabel('Neuron No.');
% ylabel('Match/non-match selective index');
xlabel('In correct trials');
ylabel('In error trials');

% legend([hc,he],{'Correct trials','Error Trials'});


    function out=oneGrp(match,nonmatch,selId,inclusion,delay)
    binSize=1;
    preRespBin=(delay+3)/binSize+1:(delay+4)/binSize;
    
    
    if inclusion
        saneIdx=match(:,1,1)<10000 & nonmatch(:,1,1)<10000 & min(selId(:,preRespBin),[],2)>=4;
    else
        saneIdx=match(:,1,1)<10000 & nonmatch(:,1,1)<10000 & min(selId(:,preRespBin),[],2)==4 & max(selId(:,preRespBin),[],2)==4 ;
    end
    
    preRespBin=(delay+4)/binSize+1:(delay+5)/binSize;
    preRespBin=[preRespBin,preRespBin+size(match,3)/2];

    matchMeanFR=mean((match(:,:,preRespBin)),3);
    nonmatchMeanFR=mean((nonmatch(:,:,preRespBin)),3);

    out=(nonmatchMeanFR-matchMeanFR)./(nonmatchMeanFR+matchMeanFR);
    out(~saneIdx,:)=NaN;

    end
end