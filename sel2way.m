% binSize=0.5;
% selNoneA=allDualByType('distrNone','Average2Hz',-2,binSize,11,true,1);
% selNogoA=allDualByType('distrNogo','Average2Hz',-2,binSize,11,true,1);
% selGoA=allDualByType('distrGo','Average2Hz',-2,binSize,11,true,1);
% 
% selNone13A=allDualByType('distrNone','Average2Hz',-2,binSize,16,true,1,'WJ');
% selNogo13A=allDualByType('distrNogo','Average2Hz',-2,binSize,16,true,1,'WJ');
% selGo13A=allDualByType('distrGo','Average2Hz',-2,binSize,16,true,1,'WJ');
% 
% 
% selNoneB=allDualByType('distrNone','Average2Hz',-2,binSize,11,false,1);
% selNogoB=allDualByType('distrNogo','Average2Hz',-2,binSize,11,false,1);
% selGoB=allDualByType('distrGo','Average2Hz',-2,binSize,11,false,1);
% 
% selNone13B=allDualByType('distrNone','Average2Hz',-2,binSize,16,false,1,'WJ');
% selNogo13B=allDualByType('distrNogo','Average2Hz',-2,binSize,16,false,1,'WJ');
% selGo13B=allDualByType('distrGo','Average2Hz',-2,binSize,16,false,1,'WJ');


function [sample,distractor,interaction]=sel2way()
load('sel2way.mat');
sample=nan(size(selGo,1)+size(selGo13,1),13/binSize);
distractor=nan(size(selGo,1)+size(selGo13,1),13/binSize);
interaction=nan(size(selGo,1)+size(selGo13,1),13/binSize);

for n=1:size(selGo,1)
    for bin=1/binSize+1:12/binSize
        tbl=testOne(n,bin);
        outBin=bin-1/binSize;
        sample(n,outBin)=tbl{2,6};
        distractor(n,outBin)=tbl{3,6};
        interaction(n,outBin)=tbl{4,6};
    end
end

count8=size(selGo,1);

for n=1:size(selGo13,1)
    for bin=1/binSize+1:17/binSize
        tbl=testOne(n,bin,true);
        outBin=bin-1/binSize;
        sample(n+count8,outBin)=tbl{2,6};
        distractor(n+count8,outBin)=tbl{3,6};
        interaction(n+count8,outBin)=tbl{4,6};
    end
end



%     function tbl=testOne(n,bin,is13)
%         if exist('is13','var') && is13
%             halfWidth=size(selGo13,3)/2;
%             testMat=[shiftdim(selGo13(n,:,bin),1),shiftdim(selGo13(n,:,bin+halfWidth),1);
%                 shiftdim(selNogo13(n,:,bin),1),shiftdim(selNogo13(n,:,bin+halfWidth),1);
%                 shiftdim(selNone13(n,:,bin),1),shiftdim(selNone13(n,:,bin+halfWidth),1)];
%             [~,tbl,~]=anova2(testMat,size(selGo13,2),'off');
%         else
%             halfWidth=size(selGo,3)/2;
%             testMat=[shiftdim(selGo(n,:,bin),1),shiftdim(selGo(n,:,bin+halfWidth),1);
%                 shiftdim(selNogo(n,:,bin),1),shiftdim(selNogo(n,:,bin+halfWidth),1);
%                 shiftdim(selNone(n,:,bin),1),shiftdim(selNone(n,:,bin+halfWidth),1)];
%             [~,tbl,~]=anova2(testMat,size(selGo,2),'off');
%         end
%     end

    function tbl=testOne(n,bin,is13)
        if exist('is13','var') && is13
            halfWidth=size(selGo13,3)/2;
            testMat=[shiftdim(selGo13(n,1:30,bin),1),shiftdim(selGo13(n,31:60,bin),1);
                shiftdim(selNogo13(n,1:30,bin),1),shiftdim(selNogo13(n,31:60,bin),1);
                shiftdim(selNone13(n,1:30,bin),1),shiftdim(selNone13(n,31:60,bin),1)];
            [~,tbl,~]=anova2(testMat,30,'off');
        else
            halfWidth=size(selGo,3)/2;
            testMat=[shiftdim(selGo(n,1:30,bin),1),shiftdim(selGo(n,31:60,bin),1);
                shiftdim(selNogo(n,1:30,bin),1),shiftdim(selNogo(n,31:60,bin),1);
                shiftdim(selNone(n,1:30,bin),1),shiftdim(selNone(n,31:60,bin),1)];
            [~,tbl,~]=anova2(testMat,30,'off');
        end
    end


end