function [FRData,keyIdx]=processAll(groupBy,value,bins,sampleSize,repeats,rwdGrp)

FRData=[];
keyIdx=[];

javaaddpath('R:\ZX\java\spk2fr\lib\commons-math3-3.5.jar');
javaaddpath('R:\ZX\java\spk2fr\build\classes');
bfl=spk2fr.multiplesample.BuildFileList();
flist=string(bfl.toString(bfl.build('R:\ZX\APC\intan')));
clear bfl;
fidx=0;
for f=1:size(flist,1)
    if exist('rwdGrp','var') && ~contains(flist(f,1),rwdGrp,'IgnoreCase',true)
        continue;
    end
    fidx=fidx+1;
    flog(fidx)=f;
    futures(f)=parfeval(@processOne,3,flist,f,groupBy,value,bins,sampleSize,repeats);

end
for ffidx=1:fidx
    [isEmpty,FRDataNew,keyIdxNew]=fetchOutputs(futures(ffidx));
    if ~isEmpty
        FRData=[FRData;FRDataNew];
        keyIdx=[keyIdx;keyIdxNew];
    else
        fprintf('Error  in file %d\n',flog(ffidx));
    end
end


    function [isEmpty,FRData,keyIdx]=processOne(flist,f,groupBy,value,bins,sampleSize,repeats)
        javaaddpath('R:\ZX\java\spk2fr\lib\commons-math3-3.5.jar');
        javaaddpath('R:\ZX\java\spk2fr\build\classes');
        s2f=spk2fr.multiplesample.Spk2fr();
        strSPK=load(flist(f,1));
        strEvt=load(flist(f,2));
        evtTrials=wellTrained(s2f.buildTrials(strEvt.OdorOnset,strEvt.OdorOffset,strEvt.OdorID,strEvt.Lick,5));
        switch(groupBy)
            case 'sample'
                evtTrials=selectBySample(evtTrials,value);
            case 'test'
                evtTrials=selectByTest(evtTrials,value);
        end
        if ~isempty(evtTrials) && isfield(strSPK,'SPK') && ~isempty(strSPK.SPK)
            
            out=s2f.getSampleFiringRate(s2f.processFile(evtTrials,strSPK.SPK),bins,sampleSize,repeats,'');
            
            if isempty(out)
                isEmpty=true;
                FRData=[];
                keyIdx=[];
            else
                isEmpty=false;
                %         fprintf('SPK: %d, out: %d \n',size(unique(strSPK.SPK(:,1:2),'rows'),1),size(out.getFRData,1));
                FRData=out.getFRData();
                tidx=out.getKeyIdx();
                keyIdx=[ones(size(tidx,1),1)*f,tidx];
            end
        else
            isEmpty=true;
            FRData=[];
            keyIdx=[];
        end
    end


    function [rtn,flag]=wellTrained(evt)
        flag=false;
        good=isCorrect(evt);
        evt=[evt,good];
        rtnIdx=false(size(good));
        if length(evt)>=40
            i=40;
            while i<length(evt)
                windowGood=sum(good(i-39:i));
                if windowGood>=32
                    flag=true;
                    rtnIdx(i-39:i)=true;
                end
                i=i+1;
            end
        end
        rtn=evt(rtnIdx,:);
    end

    function out=isCorrect(evt)
        classA=[3 4 6 7];
        out=xor(xor(ismember(evt(:,3),classA),ismember(evt(:,4),classA)),~evt(:,5));
    end


    function out=selectBySample(evtTrials,sample)
        out=evtTrials(ismember(evtTrials(:,3),sample) & evtTrials(:,7)==1,:);
    end

    function out=selectByTest(evtTrials,test)
        out=evtTrials(ismember(evtTrials(:,4),test) & evtTrials(:,7)==1,:);
    end


end