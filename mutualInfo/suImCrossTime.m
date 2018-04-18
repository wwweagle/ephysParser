% plotDualIm
sampFstr=load('ImDualAll8s.mat');
distrFstr=load('Im8sDistr.mat');

dpaSampCount=0;
gngSampCount=0;
mixSampCount=0;
for i=1:length(sampFstr.Im)
    dpa=false;
    gng=false;
    for j=3:length(sampFstr.Im{i,2})-2
        if all(sampFstr.Im{i,2}(j-2:j+2)>0) && all(sampFstr.pCrossTime{i,2}(j-2:j+2)<0.01)
            dpa=true;
            break;
        end
    end
    
    
    for j=3:length(sampFstr.Im{i,2})-2
        if all(distrFstr.Im{i,2}(j-2:j+2)>0) && all(distrFstr.pCrossTime{i,2}(j-2:j+2)<0.01)
            gng=true;
            break;
        end
    end
    
    if dpa && gng
        mixSampCount=mixSampCount+1;
    elseif dpa
        dpaSampCount=dpaSampCount+1;
    elseif gng
        gngSampCount=gngSampCount+1;
    end

end


% cf=figure('Color','w','Position',[100,100,180,180]);
% hold on;
nonIm=length(sampFstr.Im)-sum([dpaSampCount,mixSampCount,gngSampCount]);
ph=pie([dpaSampCount,mixSampCount,gngSampCount,nonIm],{'DPA only','Mixed','2nd task only','No significant Im'});
ph(1).FaceColor='r';
ph(3).FaceColor='c';
ph(5).FaceColor='b';
ph(7).FaceColor='k';
set(gcf,'Color','w','Position',[100,100,180,180]);
return;    
    

    
