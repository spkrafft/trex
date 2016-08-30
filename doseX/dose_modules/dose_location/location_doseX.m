function [test_missing] = location_doseX(extractRead_entry,test_missing)
%% Do some preallocation...
num_mising = numel(test_missing.module);

stats = location_features(1);
featureNames = fieldnames(stats);
for nameCount = 1:length(featureNames)    
    test_missing.(['feature_',featureNames{nameCount}]) = nan(num_mising,1);
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

%%
mask = load(fullfile(project_patient,roi_file),'mask');
mask = mask.mask;

xV = load(fullfile(project_patient,image_file),'array_xV');
xV = xV.array_xV;
yV = load(fullfile(project_patient,image_file),'array_yV');
yV = yV.array_yV;
zV = load(fullfile(project_patient,image_file),'array_zV');
zV = zV.array_zV;

stats = location_features(mask,xV,yV,zV);

for nameCount = 1:length(featureNames)    
    test_missing.(['feature_',featureNames{nameCount}]) = stats.(featureNames{nameCount});
end

%%
clearvars -except test_missing
