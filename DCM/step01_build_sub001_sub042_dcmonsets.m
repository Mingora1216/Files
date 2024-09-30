clear;
subs={'001','002','003','004','005','006','007','008','009','010','011','012','013','014','015','016','017','018','019','020','021','022','023','025','026','028','029','030','031','032','033','034','035','036','037','038','039','040','041','042'};
onsetsdir='F:\Haaaaaaa\rawdata1\2nd\onesample_DCManalysis\glmonsets';
outputdir='F:\Haaaaaaa\rawdata1\2nd\onesample_DCManalysis\DCMonsets';
if ~exist(outputdir,'dir')
    mkdir(outputdir);
end
cd(onsetsdir);
ntrseachblock=267; 
cd(onsetsdir);
for isub=1:numel(subs)
    clear onsets durations names onsets1 durations1 names1 ;
    
   
    load('myexperimentdesign_run1.mat');

    onsets1=onsets;
    durations1=durations;
    names1=names;

    load('myexperimentdesign_run2.mat');
    

    for i=1:numel(onsets)
        onsets1{i}=[onsets1{i};onsets{i}+ntrseachblock];
        durations1{i}=[durations1{i};durations{i}];
    end
    

    runregressors=zeros(267+272,1);  
    runregressors(1:ntrseachblock,1)=1;   
    
    names={'allstimulidriving','PETmodulatory'};
    onsets=cell(1);
    durations=cell(1);
    % onsets{1}要储存allstimuli的onsets，它接下来被当作driving input
    % onsets{2}要储存companion animal条件的onsets，它接下来被当作modulatory
    onsets{1}=[];
    durations{1}=[];
    for i=1:numel(onsets1)
        % 对在各run连接好的onset1文件，将它各个条件连接起来，构成driving input
        onsets{1}=[onsets{1};onsets1{i}];
        durations{1}=[durations{1};durations1{i}];
    end

    onsets{2}=onsets1{1};
    durations{2}=durations1{1};
    
    save(fullfile(outputdir,['DCM_sub',subs{isub},'.mat']),'onsets','durations','names','runregressors');
end

    



