glm_dir1  ='F:\Haaaaaaa\rawdata1\2nd\onesample_DCManalysis\DCMglm_1st_Occipital_Mid_R';
allsubsdir ='F:\Haaaaaaa\rawdata1\2nd\onesample_DCManalysis\DCMglm_1st_Occipital_Mid_R';
roidir     ='F:\Haaaaaaa\rawdata1\2nd\onesample_DCManalysis\roisfordcm\Occipital_Mid_R';
voi_adjust =1;
roi_list  = dir(fullfile(roidir,'PPI*.nii'));
nrois =  length(roi_list);
cd(allsubsdir);
allsubs=dir('sub*');
for isub=1:numel(allsubs)
    spm_dirf = fullfile(glm_dir1,allsubs(isub).name,'SPM.mat');
    for iroi = 1:length(roi_list)
        roi_dirf = fullfile(roidir,strcat(roi_list(iroi).name,',1'));
        matlabbatch=cell(1);
        matlabbatch{1}.spm.util.voi.spmmat = cellstr(spm_dirf);
        % Index of F-contrast used to adjust data.
        % Enter '0' for no adjustment.
        % Enter 'NaN' for adjusting for everything.
        matlabbatch{1}.spm.util.voi.adjust = voi_adjust;
        matlabbatch{1}.spm.util.voi.session = 1;
        matlabbatch{1}.spm.util.voi.name = roi_list(iroi).name(1:end-4);
        matlabbatch{1}.spm.util.voi.roi{1}.mask.image = cellstr(roi_dirf);
        matlabbatch{1}.spm.util.voi.roi{1}.mask.threshold = 0.5;
        matlabbatch{1}.spm.util.voi.expression = 'i1';
        spm_jobman('run',matlabbatch);
    end
end