function [bootDyn,bootSust]=contribute(sel,decoding,fn)
% contribute(sideNogo,[sNogoDecode;trans13(sNogoDecode13)],'Nogo');
% contribute(sideGo,[sGoDecode;trans13(sGoDecode13)],'Go');
% contribute(sideNone,[sNoneDecode;trans13(sNoneDecode13)],'None');
% Sustained, 1; trainsient, 78; switched, 12
% T-Test Early, 0.000000, 0.000000, 0.000000, 0.000000, 
% T-Test Late, 0.689836, 0.015385, 0.000000, 0.000000, 
% Sustained, 2; trainsient, 65; switched, 27
% T-Test Early, 0.000000, 0.000000, 0.000000, 0.000000, 
% T-Test Late, 0.008440, 0.000062, 0.000001, 0.032185, 
% Sustained, 6; trainsient, 68; switched, 10
% T-Test Early, 0.000000, 0.039510, 0.000000, 0.000000, 
% T-Test Late, 0.000000, 0.014004, 0.000000, 0.000000, 


binSize=0.5;

thres=5;
% thres=3;
% sNdelay=2:7;
sNdelay=2:10;

switched=(sum(sel(:,sNdelay)==1,2)>0 & sum(sel(:,sNdelay)==-1,2)>0);
stable=(~switched & (sum(sel(:,sNdelay),2)<-thres | sum(sel(:,sNdelay),2) >thres));
transient=(~switched & ((sum(sel(:,sNdelay),2)>=-thres & sum(sel(:,sNdelay),2)<0) | (sum(sel(:,sNdelay),2)>0 & sum(sel(:,sNdelay),2)<=thres)));
others=~(stable | switched | transient);
dynamic=transient|switched;
fprintf('Sustained, %d; trainsient, %d; switched, %d\n',sum(stable),sum(transient), sum(switched));

early=nan(size(decoding,2),6);
late=nan(size(decoding,2),6);


select={others,switched,transient,stable,dynamic};

for i=1:size(select,2)
    [early(:,i+1),late(:,i+1),early(:,1),late(:,1)]=decodingOne(decoding(select{i},:,:));
end
m=@(mat) mean(mat);
stats=nan(3,12);
% for i=1:5
    stats(2:3,3:3:18)=[mean(early);mean(late)];
    stats(2:3,[4,5,7,8,10,11,13,14,16,17,19,20])=[reshape(bootci(100,m,early),1,12);reshape(bootci(100,m,late),1,12)];
%     pause;
    save(['contribute_stats_',fn,'.txt'],'stats','-ascii');
% end
p=nan(1,4);
% [~,p(1)]=ttest2(early(:,1),early(:,2),'Vartype','unequal');
% [~,p(2)]=ttest2(early(:,1),early(:,3),'Vartype','unequal');
% [~,p(3)]=ttest2(early(:,1),early(:,4),'Vartype','unequal');
% [~,p(4)]=ttest2(early(:,1),early(:,5),'Vartype','unequal');
p(1)=ranksum(early(:,1),early(:,2));
p(2)=ranksum(early(:,1),early(:,3));
p(3)=ranksum(early(:,1),early(:,4));
p(4)=ranksum(early(:,1),early(:,5));
p(5)=ranksum(early(:,1),early(:,6));
% fprintf('T-Test Early, %04f, %04f, %04f, %04f, \n',p);
fprintf('Rank Sum Early, %04f, %04f, %04f, %04f,%04f, \n',p);
% pe=p(4);

% [~,p(1)]=ttest2(late(:,1),late(:,2),'Vartype','unequal');
% [~,p(2)]=ttest2(late(:,1),late(:,3),'Vartype','unequal');
% [~,p(3)]=ttest2(late(:,1),late(:,4),'Vartype','unequal');
% [~,p(4)]=ttest2(late(:,1),late(:,5),'Vartype','unequal');

p(1)=ranksum(late(:,1),late(:,2));
p(2)=ranksum(late(:,1),late(:,3));
p(3)=ranksum(late(:,1),late(:,4));
p(4)=ranksum(late(:,1),late(:,5));
p(5)=ranksum(late(:,1),late(:,6));

bootSust=[early(:,5),late(:,5)];
bootDyn=[early(:,6),late(:,6)];

% fprintf('T-Test Late, %04f, %04f, %04f, %04f, \n',p);
fprintf('Rank Sum Late, %04f, %04f, %04f, %04f,%04f, \n',p);
% pl=p(4);

% 
% 
% figure('Color','w','Position',[100,100,400,400]);
% subplot('Position',[0.15,0.1,0.8,0.65]);
% hold on;
% bh=bar([mean(early);mean(late)]);
% bh(1).FaceColor='k';
% bh(2).FaceColor='g';
% bh(3).FaceColor='b';
% bh(4).FaceColor='r';
% bh(5).FaceColor='w';
% 
% ylim([0.48,1]);
% total=num2str(size(decoding,1));
% legend({'Shuffle',['Others ',num2str(sum(others)),'/',total], ...
%     ['Switched selectivity',num2str(sum(switched)),'/',total], ...
%     ['Transient selectivity ',num2str(sum(transient)),'/',total], ...
%     ['Stable selectivity ',num2str(sum(stable)),'/',total]});
% errorbar([(-0.31:0.155:0.31)+1,(-0.31:0.155:0.31)+2],[mean(early),mean(late)],[std(early)./sqrt(size(decoding,1)),std(late)./sqrt(size(decoding,1))],'k.');
% set(gca,'Xtick',1:2,'XTickLabel',{'Early delay','Late delay'});
% ylabel('Decoding Accuracy');
% % pause;
% savefig([fn,'_Contribute.fig']);



    function [early,late,shuffleEarly,shuffleLate]=decodingOne(samples)
        delay=size(samples,3)/4*binSize-5;
        delta=(delay+3)/binSize;
        samples=permute(samples,[1,3,2]);
        repeats=size(samples,3);
        out=nan(delta,repeats,2);
        [pf1,~,~,~]=getSampleBins(samples,delay,1);
        bins=size(pf1,1);
        for bin=1:bins
            decoded=nan(repeats,1);
            shuffled=nan(repeats,1);
            for repeat=1:repeats
                
                [pf1,pf2,bn1,bn2]=getSampleBins(samples,delay,repeat);
                
                if size(pf1,2)==0
                    decoded(repeat)=rand<0.5;
                elseif size(pf1,2)<=2
                    if rand<0.5
                        decoded(repeat)=sqrt(sum((pf2(bin)-pf1(bin)).^2))<sqrt(sum((pf2(bin)-bn1(bin)).^2));
                    else
                        decoded(repeat)=sqrt(sum((bn2(bin)-bn1(bin)).^2))<sqrt(sum((bn2(bin)-pf1(bin)).^2));
                    end
                else
                    if rand<0.5 % Use PF Test
                        corrPF=corrcoef(pf2(bin,:),pf1(bin,:));
                        corrBN=corrcoef(pf2(bin,:),bn1(bin,:));
                        decoded(repeat)=corrPF(1,2)>corrBN(1,2);
                    else % Use BN Test
                        corrPF=corrcoef(bn2(bin,:),pf1(bin,:));
                        corrBN=corrcoef(bn2(bin,:),bn1(bin,:));
                        decoded(repeat)=corrBN(1,2)>corrPF(1,2);
                    end
                end
                
                shuffled(repeat)=rand<0.5;
            end
            out(bin,:,:)=[decoded,shuffled];
        end

%         decRec=out(:,:,1)';
%         decShuffle=out(:,:,2)';
        
%         m=@(mat) mean(mat);
%         ciRec=bootci(100,m,decRec);
%         ciShuffle=bootci(100,m,decShuffle);
        
        
%         plotLength=(delay+3)/binSize;
        
%         fill([1:plotLength,plotLength:-1:1]-0.5*binSize,[(ciRec(1,:)),(fliplr(ciRec(2,:)))],[1,0.8,0.8],'EdgeColor','none');
%         fill([1:plotLength,plotLength:-1:1]-0.5*binSize,[(ciShuffle(1,:)),(fliplr(ciShuffle(2,:)))],[0.8,0.8,0.8],'EdgeColor','none');
        
        
        early=mean(out(2/binSize+1:4/binSize,:,1),1)';
        late=mean(out(6/binSize+1:10/binSize,:,1),1)';
        
        shuffleEarly=mean(out(2/binSize+1:4/binSize,:,2),1)';
        shuffleLate=mean(out(6/binSize+1:10/binSize,:,2),1)';
%         hShuffle=plot([1:plotLength]-0.5*binSize,(mean(out(:,:,2),2)),'-k','LineWidth',1);

    end


        function [pf1,pf2,bn1,bn2]=getSampleBins(samples,delay,repeat)
            start=1/binSize+1;
            stop=(delay+4)/binSize;
            delta=(delay+5)/binSize;
            SUCount=size(samples,1);
            %             if SUCount>100
            %                 selectedSU=randperm(SUCount,100);
            %             else
            selectedSU=1:SUCount;
            %             end
            pf1=samples(selectedSU,start:stop,repeat)';
            pf2=samples(selectedSU,start+delta:stop+delta,repeat)';
            bn1=samples(selectedSU,start+delta*2:stop+delta*2,repeat)';
            bn2=samples(selectedSU,start+delta*3:stop+delta*3,repeat)';
        end

end