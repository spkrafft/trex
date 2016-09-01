function [test_missing] = laws2D_textureX(extractRead_entry,test_missing)
%% Do some preallocation...
num_missing = numel(test_missing.module);

stats = laws2D_features(1);
featureNames = fieldnames(stats);
for nameCount = 1:length(featureNames)    
    test_missing.(['feature_',featureNames{nameCount}]) = nan(num_missing,1);
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

img = load(fullfile(project_patient,image_file),'array');
img = img.array;

mask = load(fullfile(project_patient,roi_file),'mask');
mask = mask.mask;

preprocess = unique(test_missing.parameter_preprocess);

%% -----Preprocess Loop-----
for count_preprocess = 1:length(preprocess) %Start loop over each preprocess...
    %Start with each preprocess so we don't have to do this
    %preprocessing/preprocessing every time...helps speed things up, especially
    %in the instances where the applied preprocess takes awhile.
    
    %Prep the data to get the image I that will be passed into the analysis
    %routines
    [~,current_preprocess,mask,I_crop] = prepCT(img,mask,'preprocess',preprocess{count_preprocess});

    ind_preprocess = strcmpi(test_missing.parameter_preprocess,current_preprocess); %logical index for current preprocess
    ind = find(ind_preprocess); %Numerical index for loop
    
    for i = 1:length(ind) %Loop through each parameter combination
        %Print to the command window...
        disp(['TREX-RT>> Preprocess (',current_preprocess,')']);

        stats = laws2D_features(I_crop,mask);

        %Write stats
        for nameCount = 1:length(featureNames)    
            test_missing.(['feature_',featureNames{nameCount}])(ind(i)) = stats.(featureNames{nameCount});
        end
    end
end %end loop over each preprocess

%%
clearvars -except test_missing
