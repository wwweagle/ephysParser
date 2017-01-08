function stats=barCombined(d8,d13,useSample)
binSize=1;
repeats=size(d8,2);
bars=nan(repeats,6);
for i=1:3
    [pf1,pf2,bn1,bn2]=genSamples(d8,d13,i,useSample);
    bars(:,i*2-1:i*2)=plotDecoding(pf1,pf2,bn1,bn2);
end

stats=nan(6,4);
stats(:,1)=1:6;
stats(:,2)=mean(bars);
stats(:,3)=std(bars)./sqrt(size(bars,1));
[~,p1]=ttest(bars(:,1),bars(:,2));
[~,p2]=ttest(bars(:,3),bars(:,4));
[~,p3]=ttest(bars(:,5),bars(:,6));
fprintf('n = %d, p = %f, %f, %f \n',size(pf1,1), p1,p2,p3);

stats(:,4)=[p1,NaN,p2,NaN,p3,NaN];
save('decodeBar.txt','stats','-ascii');

    function [pf1,pf2,bn1,bn2]=genSamples(d8,d13,timing,useSample)
        trunk8=size(d8,3)/4;
        trunk13=size(d13,3)/4;
        sa8={(3/binSize)+1:(5/binSize),(5/binSize)+1:(6/binSize),(9/binSize)+1:(11/binSize)};
        sa13={(3/binSize)+1:(5/binSize),(7/binSize)+1:(8/binSize),(11/binSize)+1:(13/binSize)};
        switch useSample
            case 3
                pf1=[d8(:,:,sa8{timing});d13(:,:,sa13{timing})];
                sa8=updateTiming(sa8,trunk8);sa13=updateTiming(sa13,trunk13);
                pf2=[d8(:,:,sa8{timing});d13(:,:,sa13{timing})];
                sa8=updateTiming(sa8,trunk8);sa13=updateTiming(sa13,trunk13);
                bn1=[d8(:,:,sa8{timing});d13(:,:,sa13{timing})];
                sa8=updateTiming(sa8,trunk8);sa13=updateTiming(sa13,trunk13);
                bn2=[d8(:,:,sa8{timing});d13(:,:,sa13{timing})];
            case 1
                pf1=d8(:,:,sa8{timing});
                sa8=updateTiming(sa8,trunk8);
                pf2=d8(:,:,sa8{timing});
                sa8=updateTiming(sa8,trunk8);
                bn1=d8(:,:,sa8{timing});
                sa8=updateTiming(sa8,trunk8);
                bn2=d8(:,:,sa8{timing});
            case 2
                pf1=d13(:,:,sa13{timing});
                sa13=updateTiming(sa13,trunk13);
                pf2=d13(:,:,sa13{timing});
                sa13=updateTiming(sa13,trunk13);
                bn1=d13(:,:,sa13{timing});
                sa13=updateTiming(sa13,trunk13);
                bn2=d13(:,:,sa13{timing});
        end
    end

    function updated=updateTiming(oriSa,trunkLen)
        updated=oriSa;
        for j=1:length(oriSa)
            updated{j}=oriSa{j}+trunkLen;
        end
    end
        
        

    function out=plotDecoding(pf1,pf2,bn1,bn2)
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
end