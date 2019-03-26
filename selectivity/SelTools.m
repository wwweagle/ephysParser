classdef SelTools < handle

    
    methods (Static)
        function out=permTAll(A,B,window)
            out=nan(1,size(A,1));
            flat=@(x) x(:);
            for i=1:size(A,1)
                if all(flat(A(i,:,window))==0) && all(flat(B(i,:,window))==0)
                    out(i)=1;
                else
                    out(i)=SelTools.permTest(flat(A(i,:,window)),flat(B(i,:,window)));
                end
            end
        end
        
        
        function out=permTest(A,B)
            currDelta=abs(mean(A(:))-mean(B(:)));
            permed=nan(1,1000);
            for i=1:1000
                [AA,BB]=SelTools.permSample(A,B);
                permed(i)=abs(mean(AA)-mean(BB));
            end
            out=mean(permed>=currDelta);
        end
        
        function [newA,newB]=permSample(A,B)
            pool=[A(:);B(:)];
            pool=pool(randperm(length(pool)));
            newA=pool(1:numel(A));
            newB=pool((numel(A)+1):end);
        end
        
        function out=p2str(p)
            if p<0.001
                out='***';
            elseif p<0.01
                out='**';
            elseif p<0.05
                out='*';
            else
                out='N.S.';
            end
        end
        
    end
end