function perf=perfBySample(groupBy,value)

count=0;
correct=0;


javaaddpath('R:\ZX\java\spk2fr\lib\commons-math3-3.5.jar');
javaaddpath('R:\ZX\java\spk2fr\build\classes');
bfl=spk2fr.multiplesample.BuildFileList();
s2f=spk2fr.multiplesample.Spk2fr();
flist=string(bfl.toString(bfl.build('R:\ZX\APC\intan')));
for f=1:size(flist,1)

    strEvt=load(flist(f,2));
    evtTrials=wellTrained(s2f.buildTrials(strEvt.OdorOnset,strEvt.OdorOffset,strEvt.OdorID,strEvt.Lick,5));
    switch(groupBy)
        case 'sample'
            evtTrials=selectBySample(evtTrials,value);
        case 'test'
            evtTrials=selectByTest(evtTrials,value); 
    end
    if ~isempty(evtTrials) 
        correct=correct+sum(evtTrials(:,7));
        count=count+size(evtTrials,1);
    end
end
perf=correct*100/count;

    function rtn=wellTrained(evt)
        good=isCorrect(evt);
        evt=[evt,good];
        rtnIdx=false(size(good));
        if length(evt)>=40
            i=40;
            while i<length(evt)
                windowGood=sum(good(i-39:i));
                if windowGood>=30
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
        out=evtTrials(ismember(evtTrials(:,3),sample),:);
    end

    function out=selectByTest(evtTrials,test)
        out=evtTrials(ismember(evtTrials(:,4),test),:);
    end


end