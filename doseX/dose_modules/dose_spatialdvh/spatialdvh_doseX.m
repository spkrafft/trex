function [test_missing] = spatialdvh_doseX(extractRead_entry,test_missing)
%% Do some preallocation...
num_mising = numel(test_missing.module);

stats = spatialdvh_features(1);
featureNames = fieldnames(stats);
for nameCount = 1:length(featureNames)    
    test_missing.(['feature_',featureNames{nameCount}]) = nan(num_mising,1);
end
test_missing.bins_dvh = cell(num_mising,1);
test_missing.diff_dvh = cell(num_mising,1);
test_missing.cumul_dvh = cell(num_mising,1);

%% Load the data, do some sanity checks of the passed data first
project_patient = unique(extractRead_entry.project_patient); 
image_file = unique(extractRead_entry.image_file);
roi_file = unique(extractRead_entry.roi_file);
if numel(project_patient) == 1 && numel(image_file) == 1 && numel(roi_file) == 1 
    project_patient = project_patient{1};
    image_file = image_file{1};
    roi_file = roi_file{1};
else
    error('All of the data in extractRead_entry should have the same project_patient, image_file, and roi_file')
end
dose_file = extractRead_entry.dose_file;
dose_file = dose_file{1};

%%
if ~isempty(dose_file)
    dose = load(fullfile(project_patient,dose_file),'array');
    dose = dose.array;

    mask = load(fullfile(project_patient,roi_file),'mask');
    mask = mask.mask;

    xV = load(fullfile(project_patient,image_file),'array_xV');
    xV = xV.array_xV;
    yV = load(fullfile(project_patient,image_file),'array_yV');
    yV = yV.array_yV;
    zV = load(fullfile(project_patient,image_file),'array_zV');
    zV = zV.array_zV;

    vol_vox = abs(mean(diff(xV))*mean(diff(yV))*mean(diff(zV)));
    clear xV yV zV
    
    weight_names = unique(test_missing.parameter_weight); %get the unique preprocess names
    %% -----Weight Loop-----
    for count_weight = 1:length(weight_names) %Start loop over each weight...
    
        current_weight = weight_names{count_weight};
        ind_weight = strcmpi(test_missing.parameter_weight,current_weight); %logical index for current weight
        ind = find(ind_weight); %Numerical index for loop
        
        weight = spatialdvh_weight(size(dose),current_weight);
        
        bin_size = 1;
        [stats,doseBins,volHist,cumVolHist] = spatialdvh_features(mask,dose.*weight,vol_vox,bin_size);

        for nameCount = 1:length(featureNames)    
            test_missing.(['feature_',featureNames{nameCount}])(ind) = stats.(featureNames{nameCount});
        end

        test_missing.bins_dvh(ind) = {doseBins};
        test_missing.diff_dvh(ind) = {volHist};
        test_missing.cumul_dvh(ind) = {cumVolHist};
    end
end   

%%
clearvars -except test_missing
