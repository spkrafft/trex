function [test_missing] = plan_doseX(extractRead_entry,test_missing)
%% Do some preallocation...
num_mising = numel(test_missing.module);

stats = plan_features(1);
featureNames = fieldnames(stats);
for nameCount = 1:length(featureNames)    
    test_missing.(['feature_',featureNames{nameCount}]) = cell(num_mising,1);
end

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
    dose = load(fullfile(project_patient,dose_file));

    stats = plan_features(dose);

    for nameCount = 1:length(featureNames)    
        test_missing.(['feature_',featureNames{nameCount}]) = {stats.(featureNames{nameCount})};
    end
end
%%
clearvars -except test_missing
