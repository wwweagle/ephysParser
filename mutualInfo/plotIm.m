function [ImPerUnit,ImShuf,selPerUnit,selShuf, avgFR]=plotIm(window,delayLen,shufRepeat)
switch window
    case 'sample'
        range=3;
    case 'sampledelay'
        range=3:7;
    case 'delay'
        range=4:7;
    case 'early'
        range=4:5;
    case 'late'
        range=6:7;
        
    case 'sample8'
        range=3;        
    case 'sampledelay8'
        range=3:11;
    case 'delay8'
        range=4:11;
    case 'early8'
        range=4:5;
    case 'late8'
        range=10:11;
end
% shufRepeat=10000;


    wd=pwd();
    cd r:\ZX\APC\RecordingAug16\
    [spkCA,~]=allByTypeDNMS('sample','Average2Hz',-2,1,11,true,delayLen,1);
    [spkCB,~]=allByTypeDNMS('sample','Average2Hz',-2,1,11,false,delayLen,1);
%     assignin('base','spkCA',spkCA);
%     assignin('base','spkCB',spkCB);
    cd(wd);

ImPerUnit=nan(sum(cellfun(@(x) size(x,1),spkCA)),1);
selPerUnit=nan(sum(cellfun(@(x) size(x,1),spkCA)),1);
avgFR=nan(sum(cellfun(@(x) size(x,1),spkCA)),1);


ImShuf=nan(size(ImPerUnit,1),shufRepeat);
selShuf=nan(size(selPerUnit,1),shufRepeat);

uidx=0;
for f=1:length(spkCA)
    for u=1:size(spkCA{f},1)
        uidx=uidx+1;
        
        aSpkCount=sum(spkCA{f}(u,:,range),3);
        bSpkCount=sum(spkCB{f}(u,:,range),3);
        
        pool=[aSpkCount,bSpkCount];
        
        
        trialCount=length(pool);
        p_r=histcounts([aSpkCount,bSpkCount],unique([aSpkCount,bSpkCount,realmax]))./trialCount;
        
%       A=cellfun(@(x) histcounts(x,unique([aSpkCount,bSpkCount,realmax]))./trialCount,{aSpkCount,bSpkCount},'UniformOutput',false);
        A=cellfun(@(x) histcounts(x,unique([aSpkCount,bSpkCount,realmax]))./trialCount,{aSpkCount,bSpkCount},'UniformOutput',false);
%       if fit is preffered, do it here
        

        im=sum(cell2mat(cellfun(@(p_rs) p_rs(p_rs>0).*log2(p_rs(p_rs>0)./(p_r(p_rs>0).*sum(p_rs))),A,'UniformOutput',false)));
%       implement continuous im.
        avgFR(uidx,1)=mean(pool)./length(range);
        ImPerUnit(uidx,1)=im;
        selPerUnit(uidx,1)=(sum(aSpkCount)-sum(bSpkCount))/(sum(aSpkCount)+sum(bSpkCount));
        
        
        
        for rptIdx=1:shufRepeat
            aShufIdx=randperm(length(pool));
            aShuf=pool(aShufIdx<=length(aSpkCount));
            bShuf=pool(aShufIdx>length(aSpkCount));
            p_r_shuf=histcounts([aShuf,bShuf],unique([aShuf,bShuf,realmax]))./trialCount;
            A_Shuf=cellfun(@(x) histcounts(x,unique([aShuf,bShuf,realmax]))./trialCount,{aShuf,bShuf},'UniformOutput',false);
            im_Shuf=sum(cell2mat(cellfun(@(p_rs) p_rs(p_rs>0).*log2(p_rs(p_rs>0)./(p_r_shuf(p_rs>0).*sum(p_rs))),A_Shuf,'UniformOutput',false)));
            ImShuf(uidx,rptIdx)=im_Shuf;
            selShuf(uidx,rptIdx)=(sum(aShuf)-sum(bShuf))/(sum(aShuf)+sum(bShuf));
        end
        
        
    end
end

end