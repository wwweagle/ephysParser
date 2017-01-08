function barCombinedRegrp(go,nogo,none)
%barCombinedRegrp([sGoDecode;trans13(sGoDecode13)],[sNogoDecode;trans13(sNogoDecode13)],[sNoneDecode;trans13(sNoneDecode13)]);

% dataset=frBound({none,nogo,go},4.5);
dataset={none,nogo,go};
fileName={'barDecodeEarly','barDecodeDisti','barDecodeLate'};
binSize=1;
repeats=size(go,2);

    function dataset=frBound(dataset,bound)
        for i=1:size(dataset,2)
            t=dataset{i};
            sel=mean(t(:,:,2),2)>bound;
            dataset{i}=t(sel,:,:);
        end
    end

    function [pf1,pf2,bn1,bn2]=genSamples(data,timing)
        trunk=size(data,3)/4;
        sa={(3/binSize)+1:(5/binSize),(5/binSize)+1:(7/binSize),(7/binSize)+1:(11/binSize)};
        
        pf1=data(:,:,sa{timing});
        sa=updateTiming(sa,trunk);
        pf2=data(:,:,sa{timing});
        sa=updateTiming(sa,trunk);
        bn1=data(:,:,sa{timing});
        sa=updateTiming(sa,trunk);
        bn2=data(:,:,sa{timing});
        
    end

    function updated=updateTiming(oriSa,trunkLen)
        updated=oriSa;
        for j=1:length(oriSa)
            updated{j}=oriSa{j}+trunkLen;
        end
    end


    function out=calcDecoding(pf1,pf2,bn1,bn2)
        repeats=size(pf1,2);
        out=nan(repeats,2);
        bins=size(pf1,3);
        for repeat=1:repeats
            decoded=nan(1,bins);
            shuffled=nan(1,bins);
            for bin=1:bins
                if rand<0.5 % Use PF Test
                    corrPF=corrcoef(pf2(:,repeat,bin),pf1(:,repeat,bin));
                    corrBN=corrcoef(pf2(:,repeat,bin),bn1(:,repeat,bin));
                    decoded(bin)=corrPF(1,2)>corrBN(1,2);
                    
                else % Use BN Test
                    corrPF=corrcoef(bn2(:,repeat,bin),pf1(:,repeat,bin));
                    corrBN=corrcoef(bn2(:,repeat,bin),bn1(:,repeat,bin));
                    decoded(bin)=corrBN(1,2)>corrPF(1,2);
                end
                shuffled(bin)=rand<0.5;
            end
            out(repeat,:)=[mean(decoded),mean(shuffled)];
        end
    end



    for t=1:3
        out=nan(repeats,6);
        for d=1:3
            [pf1,pf2,bn1,bn2]=genSamples(dataset{d},t);
            out(:,d*2-1:d*2)=calcDecoding(pf1,pf2,bn1,bn2);
        end
        stats=nan(4,4);
        stats(:,1)=1:4;
        stats(:,2)=mean(out(:,[1 3 5 6])).*100;
        stats(:,3)=std(out(:,[1 3 5 6]))./sqrt(size(out,1)).*100;
        pAll=anova1(out(:,[1 3 5 6]),[],'off');
        pWoShuffle=anova1(out(:,[1 3 5]),[],'off');
        stats(:,4)=[pAll,pWoShuffle,NaN,NaN];
        fprintf('%s,all, %f, part, %f.\n',fileName{t},pAll,pWoShuffle);
        save([fileName{t},'_Stats.txt'],'stats','-ascii');
    end


end