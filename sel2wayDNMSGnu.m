tidx=find(smp==1 | smp==3 | smp ==5 | smp ==7);
smp(tidx)=smp(tidx)-1;
test=sum(smp==2)./size(smp,1);
match=sum(smp==4)./size(smp,1);
both=sum(smp==6)./size(smp,1);
stack=[test',both',match'];
save('sel2Way.txt','stack','-ascii');
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotSel2Way.txt');