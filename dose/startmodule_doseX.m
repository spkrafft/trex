function [h] = startmodule_doseX(h,module)
%%
h.now = datestr(now,'yyyymmddHHMMSS');
diary(fullfile(h.project_path,'Log',[h.now,'_',module,'_doseX.xlog']))

start_tic = tic;
disp(['TREX-RT>> ',upper(module),' features started...'])
set(h.text_wait2,'String',[upper(module),' features started...'])
set(h.patch_wait,'XData',[0 0 0 0])
set(h.text_wait,'String',sprintf('%.0f%%',0))
drawnow; pause(0.01);

%% Populate the parameter structs
num = [];
fields_param = fieldnames(h.(module));
fields_param = fields_param(~strcmpi(fields_param,'toggle'));
for i = 1:numel(fields_param)
    num.(fields_param{i}) = size(h.(module).(fields_param{i}),1);
end

num_param = numel(fields_param);

%% Calculate the total number of parameter combinations
num_combinations = 1;
ind = cell(1,num_param);
for i = 1:num_param
    num_combinations = num_combinations*num.(fields_param{i});
    ind{i} = 1:num.(fields_param{i});
end

if num_param > 0
    [ind{1:num_param}] = ndgrid(ind{:}); %Use ndgrid to get the parameter combination indices
end

%% Write out the parameter combinations to test struct
test = [];
test.module = repmat({upper(module)},num_combinations,1);
for i = 1:num_param
    ind{i} = ind{i}(:);
    test.(['parameter_',fields_param{i}]) = h.(module).(fields_param{i})(ind{i});
end
    
%% Read pre-existing moduleData
moduleRead = read_doseX(h.project_path,module);

%% Preallocate the moduleWrite structure
num_extract = numel(h.extractRead.project_path);
moduleWrite = [];
fields = fieldnames(moduleRead);
for i = 1:numel(fields)
    if iscell(moduleRead.(fields{i}))
        moduleWrite.(fields{i}) = cell(num_extract*num_combinations,1);
    elseif islogical(moduleRead.(fields{i}))
        moduleWrite.(fields{i}) = false(num_extract*num_combinations,1);
    else
        moduleWrite.(fields{i}) = nan(num_extract*num_combinations,size(moduleRead.(fields{i}),2));
    end
end

%% Compare and calculate loop...
writeCount = 1;

for entry = 1:num_extract %Loop over each entry
    disp(['TREX-RT>> ',upper(module),': Entry ',num2str(entry),'...']);
    set(h.text_wait2,'String',[upper(module),': Entry ',num2str(entry),'...'])
    drawnow; pause(0.001);
%%
    %Some checking of indices...look for any matching entries in the
    %previously written module (moduleRead).
    %The same project path, image_file, roi_file, dose_file, roi_datestr,
    %and dose_datestr are necessary. 
    ind_project_path = strcmp(moduleRead.project_path,h.extractRead.project_path(entry)); %logical index
    ind_image_file = strcmp(moduleRead.image_file,h.extractRead.image_file(entry)); %logical index
    ind_roi_file = strcmp(moduleRead.roi_file,h.extractRead.roi_file(entry)); %logical index
    ind_dose_file = strcmp(moduleRead.dose_file,h.extractRead.dose_file(entry)); %logical index
    ind_dose_empty = cellfun(@isempty,moduleRead.dose_file); %logical index...matching of empty dose name is problematic, so this was added
    ind_roi_datestr = strcmp(moduleRead.convertROI_datestr,h.extractRead.convertROI_datestr(entry)); %logical index
    ind_dose_datestr = strcmp(moduleRead.convertDose_datestr,h.extractRead.convertDose_datestr(entry)); %logical index
    
    %logical index of data found in moduleRead
    ind_moduleRead = ind_project_path & ind_image_file & ind_roi_file & (ind_dose_file | ind_dose_empty) & ind_roi_datestr & ind_dose_datestr; 
    
    %Numerical indices that indicate the data found on moduleRead (and thus
    %probably doesn't need to be recalculated) or data not found
    %ind_found = [];
    ind_missing = true(numel(test.module),1);

    %If there is no data matching this entry on moduleRead, we don't need
    %to compare the selected parameters
    if ~isempty(ind_moduleRead) || sum(ind_moduleRead) > 0
        %If there is matching data, subset it out...
        moduleRead_subset = [];
        mNames = fieldnames(moduleRead);
        for nCount = 1:numel(mNames)
            moduleRead_subset.(mNames{nCount}) = moduleRead.(mNames{nCount})(ind_moduleRead,:);
        end

        %Compares data that has already been computed against the set of data that
        %we want to compute based on the selected dose parameters
        num_subset = numel(moduleRead_subset.project_path); %number of the elements in moduleRead_subset

        ind_found = false(num_subset,1); %logical index of the entries with found (i.e. already calculated) data
        ind_missing = false(num_combinations,1); %logical index of the remaining entries

        for j = 1:num_combinations
            ind_comp = true(num_combinations,1); %Initialize ind_comp
            
            for i = 1:numel(fields_param)
                if i == 1
                    ind_comp = strcmpi(moduleRead_subset.(['parameter_',fields_param{i}]),test.(['parameter_',fields_param{i}]){j}); %logical index, updated for each parameter
                else
                    ind_comp = ind_comp & strcmpi(moduleRead_subset.(['parameter_',fields_param{i}]),test.(['parameter_',fields_param{i}]){j}); %logical index, updated for each parameter
                end
            end

            if sum(ind_comp)==1 %if one entry found, the data is on moduleRead_subset
                ind_found(ind_comp) = true;
            elseif sum(ind_comp)==0 %if no entry found, the data is missing
                ind_missing(j) = true;
            else %if more than one entry found, this is problematic (i.e. we aren't correctly looking at the parameter combinations
               error('huh?')
            end
        end

        %If we have sucessfully found some of the data with correct parameters, write it out
        if ~isempty(ind_found)
            for nCount = 1:numel(mNames) %loop over each field of the readModule
                moduleWrite.(mNames{nCount})(writeCount:(writeCount+sum(ind_found)-1),:) = moduleRead_subset.(mNames{nCount})(ind_found,:);
            end
            writeCount = writeCount + sum(ind_found); %advance counter
        end
    end

    %If there are still some missing indices, then start calculation...
    if ~isempty(ind_missing) && sum(ind_missing) > 0
        %Isolate the missing test data
        test_missing = [];
        tNames = fieldnames(test);
        for nCount = 1:numel(tNames)
            test_missing.(tNames{nCount})(1:sum(ind_missing),:) = test.(tNames{nCount})(ind_missing,:);
        end

        %Get extractRead data for just the entry
        extractRead_entry = [];
        eNames = fieldnames(h.extractRead);
        for nCount = 1:numel(eNames)
            extractRead_entry.(eNames{nCount}) = h.extractRead.(eNames{nCount})(entry,:);
        end

        %Calculate missing data
        test_missing = feval([module,'_doseX'],extractRead_entry,test_missing); 

        num_missing = numel(test_missing.module);

        %Add data to moduleWrite
        tNames = fieldnames(test_missing);
        mNames = fieldnames(moduleRead);
        for nCount = 1:numel(mNames)
            if sum(strcmpi(tNames,mNames{nCount})) == 1 %If one of the test fields, add from test_missing
                moduleWrite.(mNames{nCount})(writeCount:(writeCount+num_missing-1),:) = test_missing.(mNames{nCount})(1:num_missing,:);
            else
                moduleWrite.(mNames{nCount})(writeCount:(writeCount+num_missing-1),:) = extractRead_entry.(mNames{nCount})(1,:);
            end
        end
        writeCount = writeCount + num_missing; %advance counter
    end
%%
    progress = entry/num_extract;
    drawnow; pause(0.001);
    set(h.patch_wait,'XData',[0 0 progress progress])
    set(h.text_wait,'String',sprintf('%.0f%%',progress*100))
end %End entry loop

%% Write out log data, module, and print some messages to console
log_filename = [h.now,'_',module,'_doseX.mat'];
save(fullfile(h.project_path,'Log',log_filename),'-struct','moduleWrite')

%Rearrange the data to write out...
moduleVec = write_doseX(moduleWrite,log_filename);
save(fullfile(h.project_path,[upper(module),'.mat']),'-struct','moduleVec')
disp(['TREX-RT>> ',upper(module),' complete!'])
disp(['TREX-RT>> ',upper(module),' module run time: ',num2str(toc(start_tic)),' seconds'])

diary off
disp(['TREX-RT>> Log file: ',h.now,'_',module,'_doseX.xlog'])
disp(['TREX-RT>> ',upper(module),' Done!'])

%%
clearvars -except h
