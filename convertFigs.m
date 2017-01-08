function convertFigs(fname, rgb)
javaaddpath('..\Script\hel2arial\hel2arial.jar');
h2a=hel2arial.Hel2arial;

% close all;pl
figL=ls([fname,'.fig']);
for i=1:size(figL,1)
    fh=openfig(figL(i,:));
    fname=strtrim(figL(i,:));
    fname=fname(1:length(fname)-4);
    writeFile(fh,fname);
%     close all;
    close(fh);
end





        function writeFile(fh,fileName)
                set(gcf,'PaperPositionMode','auto');
                if exist('rgb','var') && rgb==true
                    print('-painters',fh,'-depsc',[fileName,'.eps']);
                else
                    print('-painters',fh,'-depsc',[fileName,'.eps'],'-cmyk');
                end
                h2a.h2a([pwd,'\',fileName,'.eps']);
        end

end