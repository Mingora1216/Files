function chenchangminggppiconfigure(varargin)
% Configuration file for gPPI.m
% Shaozheng Qin adapted for his poject on January 1, 2014
% Lei Hao adapted for his poject on September 12, 2017
%1
%1
%masbar must be removed
%=========================================================================%
clear
% restoredefaultpath
%% Set Path
a=which('marsbar.m');
marsbarfilepath='';
if ~isempty(a)
    marsbarfilepath=fileparts(a);
    rmpath(marsbarfilepath);
end
experimentdesign             = 'F:\Haaaaaaa\myexperimentdesign.xlsx';   % select experiment desgin file, could be xlsx or matlab cells
script_dir                   = 'F:\Haaaaaaa\gPPIspm12';   % change it to your destination of gPPI
dirfirstlevel                 = 'F:\Haaaaaaa\rawdata1\1st';
outputppidir                  = 'F:\Haaaaaaa\rawdata1\gPPI_1st_20240711';
firstlevelappend             = 'none';    % the folder within each subject saving results from first-level GLM analysis, input 'none' if there is no firstlevelappend
roi_nii_folder               = 'F:\Haaaaaaa\rawdata1\gPPI_1st_20240711\Parietal_Inf_R';
ROI_form                    = 'nii';
roifilter                   = 'Parietal_Inf_R*';
%%**********************************
% Please specify the task to include
% set = { '1', 'task1', 'task2'} -> must exist in all sessions
% set = { '0', 'task1', 'task2'} -> does not need to exist in all sessions
paralist.tasks_to_include    = {'1', 'a', 'b','c','d'};
paralist.confound_names = {'R1', 'R2', 'R3', 'R4', 'R5', 'R6'};

Pcon.Contrasts(1).left     = {'a'};
Pcon.Contrasts(1).right    = {'none'};
Pcon.Contrasts(1).STAT     = 'T';
Pcon.Contrasts(1).Weighted = 0;
Pcon.Contrasts(1).name     = 'a';

Pcon.Contrasts(2).left     = {'b'};
Pcon.Contrasts(2).right    = {'none'};
Pcon.Contrasts(2).STAT     = 'T';
Pcon.Contrasts(2).Weighted = 0;
Pcon.Contrasts(2).name     = 'b';

Pcon.Contrasts(3).left     = {'c'};
Pcon.Contrasts(3).right    = {'none'};
Pcon.Contrasts(3).STAT     = 'T';
Pcon.Contrasts(3).Weighted = 0;
Pcon.Contrasts(3).name     = 'c';

Pcon.Contrasts(4).left     = {'d'};
Pcon.Contrasts(4).right    = {'none'};
Pcon.Contrasts(4).STAT     = 'T';
Pcon.Contrasts(4).Weighted = 0;
Pcon.Contrasts(4).name     = 'd';

%a和b两种条件对比
%Pcon.Contrasts(5).left     = {'a'};
%Pcon.Contrasts(5).right    = {'b'};
%Pcon.Contrasts(5).STAT     = 'T';
%Pcon.Contrasts(5).Weighted = 0;
%Pcon.Contrasts(5).name     = 'a vs b';

%congruent和incongruent两种条件对比
%Pcon.Contrasts(4).left     = {'congruent'};
%Pcon.Contrasts(4).right    = {'incongruent'};
%Pcon.Contrasts(4).STAT     = 'T';
%Pcon.Contrasts(4).Weighted = 0;
%Pcon.Contrasts(4).name     = 'congruentvsincongruent';
%% ********************************
%% define roi
paralist.roi_nii_folder  =roi_nii_folder;
roi_list                 = dir (fullfile (paralist.roi_nii_folder, [roifilter, ROI_form]));
roi_list                 = struct2cell (roi_list);
roi_list                 = roi_list (1, 1:end);
roi_list                 = roi_list';
paralist.roi_file_list   = {};
for roi_i = 1:length (roi_list)
    paralist.roi_file_list {roi_i,1} = fullfile (paralist.roi_nii_folder, roi_list {roi_i, 1});
end
paralist.firstlevelappend  =firstlevelappend;
paralist.dirfirstlevel  = dirfirstlevel;
paralist.roi_name_list   = strtok (roi_list, '.');
[subs,~]                 = findsubs(experimentdesign);
paralist.subject_list    = subs;
paralist.outputppidir    = outputppidir;
gzip_swcar = 0; % 1:yes or 0:no
% addpath (genpath (spm_dir('dir')));
addpath (genpath (script_dir));
scr_gPPI_ccm(paralist,Pcon,script_dir,gzip_swcar);
if ~isempty(marsbarfilepath)
    addpath(genpath(marsbarfilepath));
end
end


function [subs,subinfos]=findsubs(experimentdesign)
% this function find generate the variable of subinfos according to experimentdesign
[~,~,tempc]=fileparts(experimentdesign);
subinfos=cell(1);
if strcmp(tempc,'.xlsx') | strcmp(tempc,'.xls')
    [~,raw]=xlsread(experimentdesign);
    raw=raw(2:end,:);
    [subs,~]=unique(raw(:,1));
elseif strcmp(tempc,'.mat')
    tempinput=load(experimentdesign);
    rawccmc=fieldnames(tempinput);
    eval(['rawccm=tempinput.',rawccmc{1}]);
    if iscell(rawccm)
        [subs,~]=unique(rawccm(:,1));
        for tempi=1:numel(subs)
            subinfos{tempi,1}{1}=subs{tempi}; % subinfos{tempi,1}{1} is a string
        end
    else
        warndlg(['the variable should be of cell type in ',experimentdesign]);
        return;
    end
end
end

function scr_gPPI_ccm(paralist,Pcon,script_dir,gzip_swcar)
% gPPI analysis for task-related fMRI data and analysis pipeline
% Shaozheng Qin adapted for his memory poject on January 1, 2014
% Lei Hao readapted for his development poject on Septmber 21, 2017
% Changming chen,revised 20211007

% ======================================================================= %
warning('off', 'MATLAB:FINITE:obsoleteFunction')
c = fix(clock);
disp('==================================================================');
fprintf('gPPI analysis started at %d/%02d/%02d %02d:%02d:%02d \n',c);
disp('==================================================================');
fname = sprintf('dcan_gPPI-%d_%02d_%02d-%02d_%02d_%02.0f.log',c);
diary(fname);
disp(['Current directory is: ',pwd]);
disp('------------------------------------------------------------------');
% ======================================================================= %

data_server_stats  = paralist.dirfirstlevel;
subjects           = strtrim(paralist.subject_list);
firstlevelappend   = strtrim(paralist.firstlevelappend);
num_subj           = length(subjects);
roi_file           = paralist.roi_file_list;
roi_name           = paralist.roi_name_list;
num_roi_name       = length(roi_name);
num_roi_file       = length(roi_file);
tasks_to_include   = paralist.tasks_to_include;
confound_names     = paralist.confound_names;
outputppidir       = paralist.outputppidir;
scriptdir = strtrim(script_dir); % Added by Hao
% gzipswcar = gzip_swcar;     % Added by Hao

if num_roi_name ~= num_roi_file
    error('number of ROI files not equal to number of ROI names');
end

for i_roi = 1:num_roi_file
    
    fprintf('===> gPPI for ROI: %s\n', roi_name{i_roi});
    
    load(fullfile(scriptdir,'depend','ppi_master_template.mat'));
    
    P.VOI      = roi_file{i_roi};
    P.Region   = roi_name{i_roi};
    P.Tasks    = tasks_to_include;
    P.FLmask   = 1;
    P.equalroi = 0;
    
    for i_subj = 1:num_subj
        fprintf('------> processing subject: %s\n', subjects{i_subj});
        
        % directory of SPM.mat file
        if strcmp(firstlevelappend,'none')
            subject_stats_dir = fullfile(data_server_stats,subjects{i_subj});
        else
            subject_stats_dir = fullfile(data_server_stats,subjects{i_subj},firstlevelappend);
        end
        subject_gPPI_stats_dir = fullfile(outputppidir,subjects{i_subj},'gppi');
        
        if ~exist(subject_gPPI_stats_dir, 'dir')
            mkdir(subject_gPPI_stats_dir);
        end
        
        cd(subject_gPPI_stats_dir);
        if strfind(spm('version'),'SPM8')
                copyfile(fullfile(subject_stats_dir, 'SPM.mat'),subject_gPPI_stats_dir);                
                copyfile(fullfile(subject_stats_dir, '*.img'), subject_gPPI_stats_dir);
                copyfile(fullfile(subject_stats_dir, '*.hdr'), subject_gPPI_stats_dir);
        elseif strfind(spm('version'),'SPM12')
            if isunix
                copyfile(fullfile(subject_stats_dir, 'SPM.mat'),subject_gPPI_stats_dir);
                copyfile(fullfile(subject_stats_dir, '*.nii'), subject_gPPI_stats_dir);
            elseif ispc
                copyfile(fullfile(subject_stats_dir, 'SPM.mat'),subject_gPPI_stats_dir);
                copyfile(fullfile(subject_stats_dir, 'beta*.nii'),subject_gPPI_stats_dir);
                copyfile(fullfile(subject_stats_dir, 'con*.nii'),subject_gPPI_stats_dir);
                copyfile(fullfile(subject_stats_dir, 'con*.nii'),subject_gPPI_stats_dir);
                copyfile(fullfile(subject_stats_dir, 'spmT*.nii'),subject_gPPI_stats_dir);
                copyfile(fullfile(subject_stats_dir, 'mask.nii'),subject_gPPI_stats_dir);
                copyfile(fullfile(subject_stats_dir, 'ResMS.nii'),subject_gPPI_stats_dir);
                copyfile(fullfile(subject_stats_dir, 'RPV.nii'),subject_gPPI_stats_dir);
            end
        end
        P.subject = subjects{i_subj};
        P.directory = subject_gPPI_stats_dir;
        
        % Update the SPM path for gPPI analysis
        load('SPM.mat');
        SPM.swd = pwd;
        
        num_sess = numel(SPM.Sess);
        
        img_name = cell(num_sess, 1);
        img_path = cell(num_sess, 1);
        num_scan = [1, SPM.nscan];
        
        for i_sess = 1:num_sess
            first_scan_sess = sum(num_scan(1:i_sess));
            img_name{i_sess} = SPM.xY.VY(first_scan_sess).fname;
            img_path{i_sess} = fileparts(img_name{i_sess});
        end
        
        iG = [];
        col_name = SPM.xX.name;
        
        num_confound = length(confound_names);
        
        for i_c = 1:num_confound
            iG_exp = ['^Sn\(.*\).', confound_names{i_c}, '$'];
            iG_match = regexpi(col_name, iG_exp);
            iG_match = ~cellfun(@isempty, iG_match);
            if sum(iG_match) == 0
                error('confound columns are not well defined or found');
            else
                iG = [iG find(iG_match == 1)]; %#ok<*AGROW>
            end
        end
        
        if length(iG) ~= num_confound*num_sess
            error('number of confound columns does not match SPM design');
        end
        
        num_col = size(SPM.xX.X, 2);
        FCon = ones(num_col, 1);
        FCon(iG) = 0;
        FCon(SPM.xX.iB) = 0;
        FCon = diag(FCon);
        
        num_con = length(SPM.xCon);        
        SPM.xCon(end+1)= spm_FcUtil('Set', 'effects_of_interest', 'F', 'c', FCon', SPM.xX.xKXs);
        spm_contrasts(SPM, num_con+1);
        
        P.contrast = num_con + 1;
        
        SPM.xX.iG = sort(iG);
        for g = 1:length(iG)
            SPM.xX.iC(SPM.xX.iC==iG(g)) = [];
        end
        
        save SPM.mat SPM;
        clear SPM;        
        P.Contrasts = Pcon.Contrasts; 
        save(['gPPI_', subjects{i_subj}, '_analysis_', roi_name{i_roi}, '.mat'], 'P');
        PPPI(['gPPI_', subjects{i_subj}, '_analysis_', roi_name{i_roi}, '.mat']);
        
%         for i_sess = 1:num_sess
%             if gzipswcar==1
%                 if isunix
%                 unix(sprintf('gzip -fq %s', img_name{i_sess}));
%                 end
%             end
%         end
        
        cd(subject_gPPI_stats_dir);
        ppitardir=['PPI_', roi_name{i_roi}];
        if ~exist(ppitardir,'dir')
            mkdir(ppitardir);
        end
        delete('SPM.mat');
        delete('*.nii');
        delete('*.img');
        delete('*.hdr');
        copyfile('*.txt', ppitardir);
        copyfile('*.mat', ppitardir);
        copyfile('*.log', ppitardir);
    end
    cd(scriptdir);
end

cd(scriptdir);
disp('------------------------------------------------------------------');
fprintf('Changing back to the directory: %s \n', scriptdir);
c     = fix(clock);
disp('==================================================================');
fprintf('gPPI analysis finished at %d/%02d/%02d %02d:%02d:%02d \n',c);
disp('==================================================================');

diary off;
clear all;
close all;
end

