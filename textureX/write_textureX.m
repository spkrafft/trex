function [moduleVec] = write_textureX(moduleWrite,log_filename)
%%
%Get module name
module = unique(moduleWrite.module);
module = module{1};

disp(['TREX-RT>> Writing ',module,'...'])

%% Group Entries
%This is clunky, but I am going to let it go for now since it works like I
%want it to...

%Unique doesn't like it if dose_name is a cell array of empty arrays...it
%expects a cell array of strings...so that is what I am going to give it by
%assigning all entries without a dose_name as 'empty'
emptyCells = cellfun(@isempty,moduleWrite.dose_file);
moduleWrite.dose_file(emptyCells)= {'empty'};

[mrn,~,group_mrn] = unique(moduleWrite.patient_mrn);
num_entries = 0;
group_entries = zeros(numel(moduleWrite.patient_mrn),1);

for mrnCount = 1:numel(mrn)
    temp = group_mrn == mrnCount;
    
    [roi2,~,group_roi2] = unique(moduleWrite.roi_file(temp));
    [image2,~,group_image2] = unique(moduleWrite.image_file(temp));
    [dose2,~,group_dose2] = unique(moduleWrite.dose_file(temp));

    for roiCount2 = 1:numel(roi2)
        for imageCount2 = 1:numel(image2)
            for doseCount2 = 1:numel(dose2)
                ind_entry = (group_roi2 == roiCount2) & (group_image2 == imageCount2) & (group_dose2 == doseCount2);

                if sum(ind_entry) ~= 0
                    temp_ind = find(temp).*ind_entry;
                    temp_ind(temp_ind == 0) = [];
                    num_entries = num_entries + 1;                    
                    group_entries(temp_ind) = num_entries;
                end
            end
        end
    end
end

%% Group Parameters
fields_module = fieldnames(moduleWrite);

%Get the parameter indices, fields and the number
ind_param = cellfun(@(x) ~isempty(regexpi(x,'parameter_')),fields_module); 
fields_param = strrep(fields_module(ind_param),'parameter_','');
num_param = numel(fields_param);

%Get the features indices, fields and the number
ind_feat = cellfun(@(x) ~isempty(regexpi(x,'feature_')),fields_module);
fields_feat = strrep(fields_module(ind_feat),'feature_','');
num_feat = numel(fields_feat);

num_combinations = 1; %Initialize the total number of combinations
parameter_str = []; %This is used to group based on the unique combination of parameters

for i = 1:numel(fields_param) %Loop over each parameter
    num = numel(unique(moduleWrite.(['parameter_',fields_param{i}]))); %Unique number of options for this parameter
    num_combinations = num_combinations*num; %Get the total number of parameter combinations
    
    if i==1 %For the first loop, start parameter_str
        parameter_str = moduleWrite.(['parameter_',fields_param{i}]);
    else %Concatenate the new parameters to parameter_str
        parameter_str = strcat(parameter_str,{'_'},moduleWrite.(['parameter_',fields_param{i}])); 
    end
end

%Get the group indices...which entries in moduleWrite are similar according
%to the parameters selected (i.e. parameter_str)
if isempty(parameter_str) %i.e. no parameters, everything is in the same group
    group_parameters = ones(numel(moduleWrite.patient_mrn),1);
else
    [~,~,group_parameters] = unique(parameter_str);
end

%% Preallocate everything but parameter and features
moduleVec = [];
moduleVec.log_filename = log_filename;
for i = 1:numel(fields_module)
    if ind_feat(i) || ind_param(i)
        %Do nothing
    else
        if iscell(moduleWrite.(fields_module{i}))
            moduleVec.(fields_module{i}) =  cell(num_entries,size(moduleWrite.(fields_module{i}),2));
        else
            moduleVec.(fields_module{i}) =  nan(num_entries,size(moduleWrite.(fields_module{i}),2));
        end
    end
end

%% Preallocate parameter and feature fields
moduleVec.parameter_headings = [strcat({'parameter_'},fields_param); 'feature_name'];
moduleVec.parameter_names = cell(num_param+1,num_combinations*num_feat);
moduleVec.feature_names = cell(1,size(moduleVec.parameter_names,2));
moduleVec.feature_space = nan(num_entries,num_combinations*num_feat);

%% Isolate just the feature space data into a single matrix for ease...
feature_space = nan(num_entries*num_combinations,numel(fields_feat));
for i = 1:numel(fields_feat)
   feature_space(:,i) = moduleWrite.(['feature_',fields_feat{i}]);
end

%% Populate parameter and feature fields
h = waitbar(0,['Creating feature space: ',module]);

for entryCount = 1:num_entries %Loop over each entry
    write = 1; %Write indices

    for parameterCount = 1:num_combinations %Loop over each parameter combination
        ind = (group_entries == entryCount) & (group_parameters == parameterCount); %Find the index for the given entry and parameter
        
        %At the first parameterCount, add all of the other fields to moduleVec
        if parameterCount == 1
            for i = 1:numel(fields_module)
                if ind_feat(i) || ind_param(i)
                    %Do nothing
                else
                    moduleVec.(fields_module{i})(entryCount,:) =  moduleWrite.(fields_module{i})(ind,:);
                end
            end
        end
        
        %Add the parameter names
        for i = 1:numel(fields_param) %Loop over each parameter field
            moduleVec.parameter_names(i,write:(write+num_feat-1)) = moduleWrite.(['parameter_',fields_param{i}])(ind);
        end %End parameter field loop
        moduleVec.parameter_names(end,write:(write+num_feat-1)) = fields_feat; %Feature names in last row
                
        %Add the full feature names
        if isempty(parameter_str)
            moduleVec.feature_names(1,write:(write+num_feat-1)) = strcat(module,{'_'},fields_feat);
        else
            moduleVec.feature_names(1,write:(write+num_feat-1)) = strcat(module,{'_'},parameter_str(ind),{'_'},fields_feat);
        end
 
        %Add the feature space data
        moduleVec.feature_space(entryCount,write:(write+num_feat-1)) = feature_space(ind,:); %Add feature space data to struct

        write = write + num_feat;
        
    end %End parameter combination loop
    waitbar(entryCount/num_entries,h)
end %End entry loop

close(h)

%%
clearvars -except moduleVec
