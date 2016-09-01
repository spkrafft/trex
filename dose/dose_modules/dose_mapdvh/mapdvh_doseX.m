function [test_missing] = mapdvh_doseX(extractRead_entry,test_missing)
%% Do some preallocation...
num_mising = numel(test_missing.module);

stats = mapdvh_features(1);
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

%     xV = load(fullfile(project_patient,image_file),'array_xV');
%     xV = xV.array_xV;
%     yV = load(fullfile(project_patient,image_file),'array_yV');
%     yV = yV.array_yV;
%     zV = load(fullfile(project_patient,image_file),'array_zV');
%     zV = zV.array_zV;
% 
%     vol_vox = abs(mean(diff(xV))*mean(diff(yV))*mean(diff(zV)));
%     clear xV yV zV
    
    map_names = unique(test_missing.parameter_map); %get the unique preprocess names
    %% -----Map Module Loop-----
    for count_map = 1:length(map_names) %Start loop over each map...
    
        current_map = map_names{count_map};
        ind_map = strcmpi(test_missing.parameter_map,current_map); %logical index for current map
        ind = find(ind_map); %Numerical index for loop
        
        feature_name = strsplit(current_map,'.');
        feature_name = feature_name{end};
        
        map_file = fullfile(project_patient,'mapx',strrep(current_map,feature_name,roi_file));
        
        %%
        map = load(map_file,'mask');
        
        map.array = vector2array_mapX(map_file,feature_name,'linear');
        map.array = prepCrop(map.array,map.mask,'Pad',[0,0,0]);

        %Get the relative pixel coords of the cropped area now
        [~,~,crop_xV,crop_yV,crop_zV] = prepCrop(dose,mask,'Pad',[0,0,0]);

        %%
        map.array = padarray(map.array,[min(crop_yV)-1,min(crop_xV)-1,min(crop_zV)-1],nan,'pre');

        map.array = padarray(map.array,...
                         [size(dose,1) - size(map.array,1),...
                         size(dose,2) - size(map.array,2),...
                         size(dose,3) - size(map.array,3)],nan,'post');

        %No filtering applied for the time being...
%         filt = ones(5,5,2)/sum(sum(sum(ones(5,5,2))));
%         map.array = nanconv_mapX(map.array,filt,'nanout');
    
%         map.array = norm_mapX(map.array,[0,1]);
        map.array = percentile_mapX(map.array);
        map.array(isnan(map.array)) = 0;
        
        %%
        bin_size = 10;
%         [stats,doseBins,volHist,cumVolHist] = mapdvh_features(mask,dose.*map.array,vol_vox,bin_size);
        [stats,doseBins,volHist,cumVolHist] = mapdvh_features(mask,dose,map.array,bin_size);

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
