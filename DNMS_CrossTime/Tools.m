classdef Tools < handle
    properties (Constant)
        thres=15;
    end
    
    methods (Static)
        
        function [out,larger]=permTest(A,B)
            rawDiff=mean(A(:))-mean(B(:));
            currDelta=abs(rawDiff);
            permed=nan(1,1000);
            for i=1:1000
                [AA,BB]=Tools.permSample(A,B);
                permed(i)=abs(mean(AA)-mean(BB));
            end
            out=mean(permed>=currDelta);
            if rawDiff>0
                larger=1;
            else
                larger=2;
            end
        end
        
        function [newA,newB]=permSample(A,B)
            pool=[A(:);B(:)];
            pool=pool(randperm(length(pool)));
            newA=pool(1:numel(A));
            newB=pool((numel(A)+1):end);
        end
        
        function p=pairedPermTest(A,B)
            currDelta=abs(mean(A(:)-B(:)));
            permed=nan(1,10000);
            for i=1:10000
                permed(i)=abs(((rand(1,numel(A))>0.5).*2-1)*(A(:)-B(:)))./numel(A);
            end
            p=mean(permed>=currDelta);
        end
    end
end