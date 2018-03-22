 classdef plotVarTCurve < handle
    properties
        binSize=0.5;
        per100=false;
        half=false;
    end
    methods (Access=private)
       
        function [pf1,pf2,bn1,bn2]=getSampleBins(obj,samples,delay,repeat)
            start=1/obj.binSize+1;
            stop=(delay+4)/obj.binSize;
            delta=(delay+5)/obj.binSize;
            SUCount=size(samples,1);
            if obj.per100 && SUCount>100
                selectedSU=randperm(SUCount,100);
            elseif obj.half
                selectedSU=randperm(SUCount,round(SUCount/2));
            else
                selectedSU=1:SUCount;
            end
            pf1=samples(selectedSU,start:stop,repeat)';
            pf2=samples(selectedSU,start+delta:stop+delta,repeat)';
            bn1=samples(selectedSU,start+delta*2:stop+delta*2,repeat)';
            bn2=samples(selectedSU,start+delta*3:stop+delta*3,repeat)';
        end
        
    end
    
    
    methods
        
        function out=plotDecoding(obj,samples,shuf)
            delay=size(samples,3)/4*obj.binSize-5;
            samples=permute(samples,[1,3,2]);
            repeats=size(samples,3);
            delayBins=5:((delay+2)/obj.binSize);
            out=nan(length(delayBins),repeats);
            
            for bin=delayBins
                decoded=nan(repeats,1);

                for repeat=1:repeats
                    
                    [pf1,pf2,bn1,bn2]=obj.getSampleBins(samples,delay,repeat);
                    if exist('shuf','var') && strcmpi(shuf,'shuffle') && rand>0.5
                        t=pf2;
                        pf2=bn2;
                        bn2=t;
                    end
                    
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
                out(bin-delayBins(1)+1,:)=decoded;
            end
            out=mean(out);
        end
        
               
        function out=plotAvgedDecoding(obj,samples,window)
            delay=size(samples,3)/4*obj.binSize-5;
            switch window
                case 'delay'
                    templateBins=2/obj.binSize+1:((delay+2)/obj.binSize);
                case 'sample'
                    templateBins=1/obj.binSize+1:2/obj.binSize;
            end
            
            samples=permute(samples,[1,3,2]);
            repeats=size(samples,3);
            
            delayBins=2/obj.binSize+1:((delay+2)/obj.binSize);
            out=nan(length(delayBins),repeats);
            
            
            for bin=delayBins
                decoded=nan(repeats,1);
                
                for repeat=1:repeats
                    
                    [pf1,pf2,bn1,bn2]=obj.getSampleBins(samples,delay,repeat);
                    if exist('shuf','var') && strcmpi(shuf,'shuffle') && rand>0.5
                        t=pf2;
                        pf2=bn2;
                        bn2=t;
                    end
                    if rand<0.5 % Use PF Test
                        corrPF=corrcoef(pf2(bin,:),mean(pf1(templateBins,:)));
                        corrBN=corrcoef(pf2(bin,:),mean(bn1(templateBins,:)));
                        decoded(repeat)=corrPF(1,2)>corrBN(1,2);
                        
                    else % Use BN Test
                        corrPF=corrcoef(bn2(bin,:),mean(pf1(templateBins,:)));
                        corrBN=corrcoef(bn2(bin,:),mean(bn1(templateBins,:)));
                        decoded(repeat)=corrBN(1,2)>corrPF(1,2);
                    end
                    
                end
                out(bin-delayBins(1)+1,:)=decoded;
            end
            out=mean(out);
        end
        
        
    end
end