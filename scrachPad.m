pause();

unique(SPK(:,4))

s1=min([Evt04;Evt09;Evt21]);
s2=max([Evt04;Evt09;Evt21]);

ts=SPK(SPK(:,4)==1 & SPK(:,2)==1 & SPK(:,3)> s1-30 & SPK(:,3)< s2+30,3);
[n,~]=histcounts(ts,s1:1:s2);
plot(n(800:1200));


edges=sort([Evt04-2;Evt04;Evt04+2]);
[n4,~]=histcounts(ts,edges);
e4=[mean(n4(1:3:end)),mean(n4(2:3:end))];
edges=sort([Evt09-2;Evt09;Evt09+2]);
[n9,~]=histcounts(ts,edges);
e9=[mean(n9(1:3:end)),mean(n9(2:3:end))];
edges=sort([Evt21-2;Evt21;Evt21+2]);
[n21,~]=histcounts(ts,edges);
e21=[mean(n21(1:3:end)),mean(n21(2:3:end))];


[fName,sSPK,sEVT]=saveOne(1,SPK,Evt04,'R105');
[fName,sSPK,sEVT]=saveOne(2,SPK,Evt09,'R107');
[fName,sSPK,sEVT]=saveOne(3,SPK,Evt21,'R106');


cd r:\ZX\APC\RecordingAug16\

clear java;
snone=sampleDualByType('distrNoneZ','Average2Hz',-2,0.5,11,[100,0;100,0],1,1);
snogo=sampleDualByType('distrNogoZ','Average2Hz',-2,0.5,11,[100,0;100,0],1,1);
sgo=sampleDualByType('distrGoZ','Average2Hz',-2,0.5,11,[100,0;100,0],1,1);


sGoDist=sampleDualByType('distrGo','Average2Hz',-2,0.5,11,[20,20;20,20],100,1);
sNogoDist=sampleDualByType('distrNoGo','Average2Hz',-2,0.5,11,[20,20;20,20],100,1);
sNoneDist=sampleDualByType('distrNone','Average2Hz',-2,0.5,11,[20,20;20,20],100,1);

sGoDecode=sampleDualByType('distrGo','Average2Hz',-2,0.5,11,[30,1;30,1],500,1);
sNogoDecode=sampleDualByType('distrNoGo','Average2Hz',-2,0.5,11,[30,1;30,1],500,1);
sNoneDecode=sampleDualByType('distrNone','Average2Hz',-2,0.5,11,[30,1;30,1],500,1);

sGoCD=sampleDualByType('distrGoIncIncorr','Average2Hz',-2,1,11,[20,10,10;20,10,10],100,1);
sNogoCD=sampleDualByType('distrNogoIncIncorr','Average2Hz',-2,1,11,[20,10,10;20,10,10],100,1);
sNoneCD=sampleDualByType('distrNoneIncIncorr','Average2Hz',-2,1,11,[20,10,10;20,10,10],100,1);

ph=plotHeat;ph.binSize=2;
ph.plot(snone,'NoneHeat');
ph.plot(snogo,'NoGoHeat');
ph.plot(sgo,'GoHeat');


pc=plotCurve;pc.binSize=1;
path(path,'R:\ZX\APC\Script1608');
pc.binSize=1;
pc.plotTrajectory(sGoDist,'GoTrajByOdor');
pc.plotTrajectory(sNogoDist,'NogoTrajByOdor');
pc.plotTrajectory(sNoneDist,'NoneTrajByOdor');

pc.plotDecoding(sGoDecode,'GoDecodeByOdor');
pc.plotDecoding(sNogoDecode,'NogoDecodeByOdor');
pc.plotDecoding(sNoneDecode,'NoneDecodeByOdor');

plotCD (sGoCD,sNogoCD,sNoneCD,false);
plotCD (sGoCD,sNogoCD,sNoneCD,true);



pc.plotDecodMat(sGoDecode,'GoTimeShiftDecode');
pc.plotDecodMat(sNogoDecode,'NogoTimeShiftDecode');


pc.plotDecodMat(sNoneDecode,'NoneTimeShiftDecode');

[pp,ff]=perf();
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotDistPerf.txt')







clear java;

snone13=sampleDualByType('distrNoneZ','Average2Hz',-2,0.5,16,[100,0;100,0],1,1,'WJ');
snogo13=sampleDualByType('distrNogoZ','Average2Hz',-2,0.5,16,[100,0;100,0],1,1,'WJ');
sgo13=sampleDualByType('distrGoZ','Average2Hz',-2,0.5,16,[100,0;100,0],1,1,'WJ');



plotSeq(Heat4s, Sel4sDNMS,'DNMS4s');

sGoDecode13=sampleDualByType('distrGo','Average2Hz',-2,0.5,16,[30,1;30,1],500,1,'WJ');
sNogoDecode13=sampleDualByType('distrNoGo','Average2Hz',-2,0.5,16,[30,1;30,1],500,1,'WJ');
sNoneDecode13=sampleDualByType('distrNone','Average2Hz',-2,0.5,16,[30,1;30,1],500,1,'WJ');

sGoCD13=sampleDualByType('distrGoIncIncorr','Average2Hz',-2,1,16,[20,10,10;20,10,10],100,1,'WJ');
sNogoCD13=sampleDualByType('distrNoGoIncIncorr','Average2Hz',-2,1,16,[20,10,10;20,10,10],100,1,'WJ');
sNoneCD13=sampleDualByType('distrNoneIncIncorr','Average2Hz',-2,1,16,[20,10,10;20,10,10],100,1,'WJ');

sGoDist13=sampleDualByType('distrGo','Average2Hz',-2,0.5,16,[20,20;20,20],100,1,'WJ');
sNogoDist13=sampleDualByType('distrNoGo','Average2Hz',-2,0.5,16,[20,20;20,20],100,1,'WJ');
sNoneDist13=sampleDualByType('distrNone','Average2Hz',-2,0.5,16,[20,20;20,20],100,1,'WJ');

ph=plotHeat;ph.binSize=2;
ph.plot(snone,13,'NoneHeat_13');
ph.plot(snogo,13,'NoGoHeat_13');
ph.plot(sgo,13,'GoHeat_13');


pc=plotCurve;
path(path,'R:\ZX\APC\Script16013');

pc.plotTrajectory(sGoDist,13,'GoTrajByOdor_13');
pc.plotTrajectory(sNogoDist,13,'NogoTrajByOdor_13');
pc.plotTrajectory(sNoneDist,13,'NoneTrajByOdor_13');

pc.plotDecoding(sGoDecode,13,'GoDecodeByOdor_13');
pc.plotDecoding(sNogoDecode,13,'NogoDecodeByOdor_13');
pc.plotDecoding(sNoneDecode,13,'NoneDecodeByOdor_13');

plotCD (sGoCD,sNogoCD,sNoneCD);


pc.plotDecodMat(sGoDecode,13,'GoTimeShiftDecode_13');
pc.plotDecodMat(sNogoDecode,13,'NogoTimeShiftDecode_13');
pc.plotDecodMat(sNoneDecode,13,'NoneTimeShiftDecode_13');
ph=plotHeat;ph.binSize=2;
ph.plot(snone,'NoneHeat_13');
ph.plot(snogo,'NoGoHeat_13');
ph.plot(sgo,'GoHeat_13');


pc=plotCurve;
path(path,'R:\ZX\APC\Script1608');

pc.plotTrajectory(sGoDist,'GoTrajByOdor_13');
pc.plotTrajectory(sNogoDist,'NogoTrajByOdor_13');
pc.plotTrajectory(sNoneDist,'NoneTrajByOdor_13');

pc.plotDecoding(sGoDecode,'GoDecodeByOdor_13');
pc.plotDecoding(sNogoDecode,'NogoDecodeByOdor_13');
pc.plotDecoding(sNoneDecode,'NoneDecodeByOdor_13');

plotCD (sGoCD,sNogoCD,sNoneCD,false);
plotCD (sGoCD,sNogoCD,sNoneCD,true);


pc.plotDecodMat(sGoDecode,'GoTimeShiftDecode_13');
pc.plotDecodMat(sNogoDecode,'NogoTimeShiftDecode_13');
pc.plotDecodMat(sNoneDecode,'NoneTimeShiftDecode_13');





pc.plotDecoding([sGoDecode;trans13(sGoDecode13)],'GoDecodeByOdor_8_13');
pc.plotDecoding([sNogoDecode;trans13(sNogoDecode13)],'NogoDecodeByOdor_8_13');
pc.plotDecoding([sNoneDecode;trans13(sNoneDecode13)],'NoneDecodeByOdor_8_13');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stats=barCombined(sGoDecode,sGoDecode13,3);
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotBarDecode.txt')
movefile('gnuTemp.eps','GoDecodeBar.eps');
save('GoDecodeBarStats_Comb.txt','stats','-ascii');

stats=barCombined(sNogoDecode,sNogoDecode13,3);
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotBarDecode.txt')
movefile('gnuTemp.eps','NogoDecodeBar.eps');
save('NogoDecodeBarStats_Comb.txt','stats','-ascii');

stats=barCombined(sNoneDecode,sNoneDecode13,3);
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotBarDecode.txt')
movefile('gnuTemp.eps','NoneDecodeBar.eps');
save('NoneDecodeBarStats_Comb.txt','stats','-ascii');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stats=barCombined(sGoDecode,sGoDecode13,1);
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotBarDecode.txt')
movefile('gnuTemp.eps','GoDecodeBar_8.eps');
save('GoDecodeBarStats_8.txt','stats','-ascii');


stats=barCombined(sNogoDecode,sNogoDecode13,1);
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotBarDecode.txt')
movefile('gnuTemp.eps','NogoDecodeBar_8.eps');
save('NogoDecodeBarStats_8.txt','stats','-ascii');


stats=barCombined(sNoneDecode,sNoneDecode13,1);
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotBarDecode.txt')
movefile('gnuTemp.eps','NoneDecodeBar_8.eps');
save('NoneDecodeBarStats_8.txt','stats','-ascii');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stats=barCombined(sGoDecode,sGoDecode13,2);
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotBarDecode.txt')
movefile('gnuTemp.eps','GoDecodeBar_13.eps');
save('GoDecodeBarStats_13.txt','stats','-ascii');

stats=barCombined(sNogoDecode,sNogoDecode13,2);
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotBarDecode.txt')
movefile('gnuTemp.eps','NogoDecodeBar_13.eps');
save('NogoDecodeBarStats_13.txt','stats','-ascii');

stats=barCombined(sNoneDecode,sNoneDecode13,2);
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotBarDecode.txt')
movefile('gnuTemp.eps','NoneDecodeBar_13.eps');
save('NoneDecodeBarStats_13.txt','stats','-ascii');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% selNone=sampleDualByType('distrNone','Average2Hz',-2,0.5,11,[1,0;1,0],30,1);
% selNogo=sampleDualByType('distrNogo','Average2Hz',-2,0.5,11,[1,0;1,0],30,1);
% selGo=sampleDualByType('distrGo','Average2Hz',-2,0.5,11,[1,0;1,0],30,1);
% 
% selNone13=sampleDualByType('distrNone','Average2Hz',-2,0.5,16,[1,0;1,0],30,1,'WJ');
% selNogo13=sampleDualByType('distrNogo','Average2Hz',-2,0.5,16,[1,0;1,0],30,1,'WJ');
% selGo13=sampleDualByType('distrGo','Average2Hz',-2,0.5,16,[1,0;1,0],30,1,'WJ');


selNone=sampleDualByType('distrNone','Average2Hz',-2,0.5,11,[100,0;100,0],1,1);
selNogo=sampleDualByType('distrNogo','Average2Hz',-2,0.5,11,[100,0;100,0],1,1);
selGo=sampleDualByType('distrGo','Average2Hz',-2,0.5,11,[100,0;100,0],1,1);

selNone13=sampleDualByType('distrNone','Average2Hz',-2,0.5,16,[100,0;100,0],1,1,'WJ');
selNogo13=sampleDualByType('distrNogo','Average2Hz',-2,0.5,16,[100,0;100,0],1,1,'WJ');
selGo13=sampleDualByType('distrGo','Average2Hz',-2,0.5,16,[100,0;100,0],1,1,'WJ');



close all
[sortedGo,sideGo]=plotSelect([selGo;trans13(selGo13)],'GoSelect');
[sortedNogo,sideNogo]=plotSelect([selNogo;trans13(selNogo13)],'NogoSelect');
[sortedNone,sideNone]=plotSelect([selNone;trans13(selNone13)],'NoneSelect');
convertFigs('*Select');

selectivityChange(sortedNone,sortedNogo,sortedGo)
selectivityChangeUnit(sortedNone,sortedNogo,sortedGo)
dynNone=selectivityChangeAllByTime(sortedNone,'None');
dynNogo=selectivityChangeAllByTime(sortedNogo,'Nogo');
dynGo=selectivityChangeAllByTime(sortedGo,'Go');
dynDNMS=selectivityChangeAllByTime(sortedDNMS,'DNMS');
barDynamic(dynNone,dynNogo,dynGo,dynDNMS);
    system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotBarDyn.txt');
    movefile('gnuTemp.eps',['dynBar.eps']);
convertFigs('*Change');
convertFigs('DNMS_SelectivityVSTime');


selDNMS8s=sampleByType(lf.listDNMS8s,'odor','Average2Hz',-2,1,11,[100,0;100,0],1,1);
sortedDNMS=plotSelect(selDNMS8s,'DNMSSelect');
decodingDNMS8s=sampleByType(lf.listDNMS8s,'odor','Average2Hz',-2,0.5,11,[30,1;30,1],500,1);

selectivityChange(sortedDNMS,sortedDNMS,sortedDNMS);



convertFigs('*DNMSSelect');

selectivityChange(sortedDNMS,sortedDNMS,sortedDNMS);




pb=0;
while pb<0.05
close all
sNogoDecode=sampleDualByType('distrNogo','Average2Hz',-2,1,11,[30,1;30,1],500,1);
[pb,pl]=pc.plotDecoding(sNoneDecode,'NoneDecodeByOdor');
end


close all;
ph=plotHeat;ph.binSize=5;
ph.plot([snone;trans13(snone13)],false,'NoneHeat');
ph.plot([snogo;trans13(snogo13)],false,'NoGoHeat');
ph.plot([sgo;trans13(sgo13)],false,'GoHeat');

convertFigs('*Heat');
convertFigs('*Colorbar');

plotCD ([sGoCD;trans13(sGoCD13,true)],[sNogoCD;trans13(sNogoCD13,true)],[sNoneCD;trans13(sNoneCD13,true)],true);

convertFigs('*LateCD');


barCombinedRegrp([sGoDecode;trans13(sGoDecode13)],[sNogoDecode;trans13(sNogoDecode13)],[sNoneDecode;trans13(sNoneDecode13)]);


fileName={'barDecodeEarly','barDecodeDisti','barDecodeLate'};
for i=1:length(fileName)
    f=[fileName{i},'_Stats.txt'];
    copyfile(f,'decodeBar.txt');
    system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotBarDecodeRegrp.txt');
    movefile('gnuTemp.eps',[fileName{i},'.eps']);
end

trajectoryByMatchLate4s=sampleByType(files.heat4s(~files.early4sLogical,:),'match','Average2Hz',-2,0.2,7,[20,20;20,20],100,1);
trajectoryByMatchNaive=sampleByType(files.naive5s,'matchIncIncorr','Average2Hz',-2,0.2,8,[20,20;20,20],100,2);
trajectoryByMatchEarly4s=sampleByType(files.heat4s(files.early4sLogical,:),'match','Average2Hz',-2,0.2,7,[20,20;20,20],100,1);
trajectoryByOdor8s=sampleByType(lf.listDNMS8s,'odor','Average2Hz',-2,0.5,11,[20,20;20,20],100,1);

p=nan(size(s,1),2);
for i=1:size(s,1)
    p(i,1)=ranksum(s(i,6:15),s(i,16:25));
    p(i,2)=mean(s(i,16:25))>mean(s(i,6:15));
end




Heat8s=sampleByType(lf.listDNMS8s,'odorZ','Average2Hz',-2,0.5,11,[100,0;100,0],1,1);
trajectoryByOdor8s=sampleByType(lf.listDNMS8s,'odor','Average2Hz',-2,0.5,11,[20,20;20,20],100,1);
selDNMS8s=sampleByType(lf.listDNMS8s,'odor','Average2Hz',-2,1,11,[100,0;100,0],1,1);



plotSeq(Heat4s, Sel4sDNMS,'DNMS4s');
plotSeq(Heat8s, Sel8sDNMS,'DNMS8s');
plotSeq([snone;trans13(snone13)], [selNone;trans13(selNone13)],'Dual_None');
plotSeq([snogo;trans13(snogo13)], [selNogo;trans13(selNogo13)],'Dual_Nogo');
plotSeq([sgo;trans13(sgo13)], [selGo;trans13(selGo13)],'Dual_Go');

pc=plotCurve();


contribute(DNMSSidde,decodingDNMS8s,'DNMS8s');
% contribute(sideGo,[sGoDecode;trans13(sGoDecode13)],'Go');
% contribute(sideNogo,[sNogoDecode;trans13(sNogoDecode13)],'Nogo');
% contribute(sideNone,[sNoneDecode;trans13(sNoneDecode13)],'None');


[dynNogo,sustNogo]=contribute(sideNogo,[sNogoDecode;trans13(sNogoDecode13)],'Nogo');
[dynGo,sustGo]=contribute(sideGo,[sGoDecode;trans13(sGoDecode13)],'Go');
[dynNone,sustNone]=contribute(sideNone,[sNoneDecode;trans13(sNoneDecode13)],'None');


load CDPBar.txt
load perfData.txt
xyBar=[CDPBar(:,2),perfData(:,2),CDPBar(:,3),perfData(:,3)];
system('R:\ZX\Tools\gnuplot\bin\gnuplot.exe -persist R:\ZX\APC\RecordingAug16\gnuplotXYBar.txt');
movefile('gnuTemp.eps',['xyBar.eps']);





plotShowCase
savefig('Showcase_Stable_03903.fig');
convertFigs('*03903');
plotShowCase
savefig('Showcase_Transient_09103.fig');
convertFigs('*09103');
plotShowCase
savefig('Showcase_Switch_09402.fig');
convertFigs('*09402');



pe=0;
pl=0;

while pe<0.05 || pl<0.05
sGoDecode13=sampleDualByType('distrGo','Average2Hz',-2,0.5,16,[30,1;30,1],500,1,'WJ');
sGoDecode=sampleDualByType('distrGo','Average2Hz',-2,0.5,11,[30,1;30,1],500,1);
[pe,pl]=contribute(sideGo,[sGoDecode;trans13(sGoDecode13)],'Go');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       dPCA                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
binSize=0.5;
none=sampleDualByType('distrNone','Average2Hz',-2,binSize,11,[100,0;100,0],1,1);
nogo=sampleDualByType('distrNogo','Average2Hz',-2,binSize,11,[100,0;100,0],1,1);
go=sampleDualByType('distrGo','Average2Hz',-2,binSize,11,[100,0;100,0],1,1);
none13=sampleDualByType('distrNoneZ','Average2Hz',-2,binSize,16,[100,0;100,0],1,1,'WJ');
nogo13=sampleDualByType('distrNogoZ','Average2Hz',-2,binSize,16,[100,0;100,0],1,1,'WJ');
go13=sampleDualByType('distrGoZ','Average2Hz',-2,binSize,16,[100,0;100,0],1,1,'WJ');
gendPCAFR([none;trans13(none13)], [nogo;trans13(nogo13)], [go;trans13(go13)])



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     crosstab                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,DNMSSidde]=plotSelect(selDNMS8s,'DNMSSelect');
X1=[repmat('a',159,1);repmat('b',159,1)];
X2=[DNMSSidde(:,1);DNMSSidde(:,2)];
[table,chi,p]=crosstab(X1,X2);



X1=[repmat('a',94,1);repmat('b',107,1)];
X2=[ones(92,1);0;0;ones(82,1);zeros(107-82,1)];
[table,chi,p]=crosstab(X1,X2);