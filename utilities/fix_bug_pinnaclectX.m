function fix_bug_pinnaclectX(project_path)

disp(project_path)

%% Move all log files except setup and extract
cleanup_log_bugX(project_path)

%% Delete vectorized files   
% remove_doseX(project_path)
remove_textureX(project_path)

%% Add new field to extract
extractRead = read_extractX(project_path);

if isfield(extractRead,'bugfix')
    error('already fixed')
else
    extractRead.bugfix = cell(numel(extractRead.patient_mrn),1);
end

%%
for i = 1:numel(extractRead.patient_mrn)
    uid = strsplit(extractRead.image_seriesUID{i},'.');
    
    if ~strcmpi(uid{4},'113619')
        %Do nothing, not a GE scan...
    else
        if datetime(datestr(extractRead.image_date{i})) >= 'April 01, 2008' 
            %Do nothing, these are fine, imported after Pinnacle update
        elseif datetime(datestr(extractRead.image_date{i})) <= 'March 18, 2008' 
            if ~isempty(extractRead.image_manufacturer{i})
                %Do nothing, these are fine, must have been imported at a
                %later date since some DICOM data exists in the Pinnacle
                %header
            else                
                %FIX HERE
                image = load(fullfile(extractRead.project_patient{i},extractRead.image_file{i}));
                
                if isfield(image,'buggedarray')
                    
                else
                    image.buggedarray = image.array;

                    image.array = image.array - 24;
                    image.array(image.array < 0) = 0;
                    image.array = image.array;

    %                 image.array = double(image.array) - 24;
    %                 image.array(image.array < 0) = 0;
    %                 image.array = uint16(image.array);

                    save(fullfile(extractRead.project_patient{i},extractRead.image_file{i}),'-struct','image');

                    extractRead.bugfix{i} = now;

                    disp(['Fixed: ',num2str(extractRead.patient_mrn(i))])
                end

            end
        else
            %Do nothing, just flag the mrn, there is either no date, or the 
            %date is between March 18 and April 01. Not sure of the exact
            %date of the Pinnacle update.
            disp(['?: ',num2str(extractRead.patient_mrn(i))])
        end
    end
end

%% Save extract
filename = [datestr(now,'yyyymmddHHMMSS'),'_extractX.mat'];
save(fullfile(project_path,'Log',filename),'-struct','extractRead')

%%
clearvars

%--------------------------------------------------------------------------
function cleanup_log_bugX(project_path)

%%
modules = {'setup',...
           'extract'};
       
dose = parameterfields_doseX([]);
% tex = parameterfields_textureX([]);  
% map = parameterfields_mapX([]);      
% 
modules = [modules,dose.module_names];%,tex.module_names,map.module_names];
           
rundata = cell(0);
for i = 1:numel(modules)
    date = getDate_logX(project_path,modules{i});
    rundata{end+1,1} = modules{i};
    rundata{end,2} = date;
end

filenames = cell(0);
list = dir(fullfile(project_path,'Log'));
for i = 1:numel(list)
    if ~isempty(regexpi(list(i).name,'.mat$')) || ~isempty(regexpi(list(i).name,'.xlog$'))
        filenames{end+1,1} = list(i).name;
    end
end

keep = false(size(filenames));
for i = 1:size(rundata,1)    
    if rundata{i,2} ~= 0
        keep = ~cellfun(@isempty,regexpi(filenames,[num2str(rundata{i,2}),'_',rundata{i,1},'(\w*)X.mat'])) | keep;
    end
end

[s,mess,messid] = mkdir(fullfile(project_path,'Log'),'old');

for i = 1:numel(keep)
    if ~keep(i)
        %filenames{i}
        movefile(fullfile(project_path,'Log',filenames{i}),fullfile(project_path,'Log','old',filenames{i}))
    end
end

%%
clearvars