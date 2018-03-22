 classdef SUVarTCurve < handle
    properties
        binSize=0.5;
    end
    methods (Access=private)
       
        function [pf1,pf2,bn1,bn2]=getSampleBins(obj,SU,samples,delay,repeat)
            start=1/obj.binSize+1;
            stop=(delay+4)/obj.binSize;
            delta=(delay+5)/obj.binSize;
            pf1=samples(SU,start:stop,repeat)';
            pf2=samples(SU,start+delta:stop+delta,repeat)';
            bn1=samples(SU,start+delta*2:stop+delta*2,repeat)';
            bn2=samples(SU,start+delta*3:stop+delta*3,repeat)';
        end
        
    end
    
    methods
        
        function out=plotDecoding(obj,samples,shuf)
            delay=size(samples,3)/4*obj.binSize-5;
            samples=permute(samples,[1,3,2]);
            repeats=size(samples,3);
            delayBins=1/obj.binSize+1:((delay+2)/obj.binSize);
            out=nan(size(samples,1),repeats);

            
            for SU=1:size(samples,1)
                for repeat=1:repeats
                    [pf1,pf2,bn1,bn2]=obj.getSampleBins(SU,samples,delay,repeat);
                    if exist('shuf','var') && strcmpi(shuf,'shuffle') && rand>0.5
                        t=pf2;
                        pf2=bn2;
                        bn2=t;
                    end
                    decoded=nan(size(delayBins));
                    for bin=delayBins
                        binIdx=bin-delayBins(1)+1;
                        if rand<0.5 % Use PF Test
                            corrPF=pf2(bin)-pf1(bin);
                            corrBN=pf2(bin)-bn1(bin);
                            decoded(binIdx)=abs(corrPF)<abs(corrBN);

                        else % Use BN Test
                            corrPF=bn2(bin)-pf1(bin);
                            corrBN=bn2(bin)-bn1(bin);
                            decoded(binIdx)=abs(corrBN)<abs(corrPF);
                        end
                    end
                    out(SU,repeat)=mean(decoded);
                end
            end
        end
        
               
        function out=plotAvgedDecoding(obj,samples,window)
            delay=size(samples,3)/4*obj.binSize-5;
            switch window
                case 'delay'
                    templateBins=2/obj.binSize+1:((delay+2)/obj.binSize);
                case 'sampledelay'
                    templateBins=1/obj.binSize+1:((delay+2)/obj.binSize);
                case 'sample'
                    templateBins=1/obj.binSize+1:2/obj.binSize;
                case 'late'
                    templateBins=delay/obj.binSize+1:((delay+2)/obj.binSize);
            end
            
            samples=permute(samples,[1,3,2]);
            repeats=size(samples,3);
            delayBins=1/obj.binSize+1:((delay+2)/obj.binSize);
            out=nan(size(samples,1),repeats);
            for SU=1:size(samples,1)
                for repeat=1:repeats
                    [pf1,pf2,bn1,bn2]=obj.getSampleBins(SU,samples,delay,repeat);
                    if exist('shuf','var') && strcmpi(shuf,'shuffle') && rand>0.5
                        t=pf2;
                        pf2=bn2;
                        bn2=t;
                    end
                    decoded=nan(size(delayBins));
                    for bin=delayBins
                        binIdx=bin-delayBins(1)+1;
                        if rand<0.5 % Use PF Test
                            corrPF=pf2(bin)-mean(pf1(templateBins));
                            corrBN=pf2(bin)-mean(bn1(templateBins));
                            decoded(binIdx)=abs(corrPF)<abs(corrBN);

                        else % Use BN Test
                            corrPF=bn2(bin)-mean(pf1(templateBins));
                            corrBN=bn2(bin)-mean(bn1(templateBins));
                            decoded(binIdx)=abs(corrBN)<abs(corrPF);
                        end
                    end
                    out(SU,repeat)=mean(decoded);
                end
            end
        end

        function out=plotDynamic(obj,samples)
          delay=size(samples,3)/4*obj.binSize-5;
            samples=permute(samples,[1,3,2]);
            repeats=size(samples,3);
            sampledelayBins=1/obj.binSize+1:((delay+2)/obj.binSize);
            out=nan(size(samples,1),3,repeats);

            
            for SU=1:size(samples,1)
                for repeat=1:repeats
                    [pf1,pf2,bn1,bn2]=obj.getSampleBins(SU,samples,delay,repeat);
                    decoded=nan(size(sampledelayBins));
                    for bin=sampledelayBins
                        binIdx=bin-sampledelayBins(1)+1;
                        if rand<0.5 % Use PF Test
                            corrPF=pf2(bin)-pf1(bin);
                            corrBN=pf2(bin)-bn1(bin);
                            decoded(binIdx)=abs(corrPF)<abs(corrBN);

                        else % Use BN Test
                            corrPF=bn2(bin)-pf1(bin);
                            corrBN=bn2(bin)-bn1(bin);
                            decoded(binIdx)=abs(corrBN)<abs(corrPF);
                        end
                    end
                    out(SU,1,repeat)=mean(decoded(1:1/obj.binSize));
                    out(SU,2,repeat)=mean(decoded(end-(2/obj.binSize)+1:end));
                    out(SU,3,repeat)=mean(decoded);
                end
            end
        end

        
    end
end