% this script combined two rp.txt files into one in batch
% all right reserved for changming chen
clear;
preprocesseddir ='F:\Haaaaaaa\rawdata1\Analysis\RealignParameter';
outputdir       ='F:\Haaaaaaa\rawdata1\DCM_rpfiles';
if ~exist(outputdir,'dir')
    mkdir(outputdir);
end
cd(preprocesseddir);
subs=dir('Sub*');
for isub=1:numel(subs)
    cursubdir=fullfile(preprocesseddir,subs(isub).name);
    
    file1=dir(fullfile(cursubdir,'rp*t'));
    rpfile1=fullfile(cursubdir,file1(1).name);
    file1=dir(fullfile(cursubdir,'S2_rp*t'));
    rpfile2=fullfile(cursubdir,file1(1).name);
    outputfilename=fullfile(outputdir,[subs(isub).name,'_rp_combined.txt']);
    commd=['copy ',rpfile1,' + ',rpfile2,' ',outputfilename];
    system(commd);
end



