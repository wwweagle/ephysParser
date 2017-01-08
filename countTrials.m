function countTrials
fl=listF();
fileList=fl.listTrialFWJ();
for fidx=1:length(fileList)
    ft=load(fileList{fidx});
    EVT=ft.EVT;
    fprintf('%d,%d,%d,%s\n',sum(EVT(:,3)==0),sum(EVT(:,3)==1),sum(EVT(:,3)==2),fileList{fidx});
    
end