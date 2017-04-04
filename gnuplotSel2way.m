toSave=nan(25,4);
toSave(2:end,2)=sum(selId==1 | selId==5)'./size(selId,1);%sample
toSave(2:end,3)=sum(selId==3 | selId==7)'./size(selId,1);%both
toSave(2:end,4)=sum(selId==2 | selId==6)'./size(selId,1);%test
save('sel2way.txt','toSave','-ascii');
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuPlotSel2way.txt')


toSave=nan(25,4);
toSave(2:end,2)=sum(selId==4)'./size(selId,1);%choice
toSave(2:end,3)=sum(selId==5 | selId==6 | selId==7)'./size(selId,1);%both
toSave(2:end,4)=sum(selId==1 | selId==2 | selId==3)'./size(selId,1);%sensory
save('sel2way.txt','toSave','-ascii');
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuPlotSel2way.txt')