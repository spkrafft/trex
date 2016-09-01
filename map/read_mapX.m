function [moduleRead,filename] = read_mapX(project_path,module,varargin)
disp_flag = true;

if nargin > 2
    disp_flag = varargin{1};
    if ~islogical(disp_flag)
        error('I should really validate attributes...')
    end
end

%%
moduleRead = [];
filename = [];

%%
try
    files = dir(fullfile(project_path,'Log'));

    %Find the most current _MAPX file
    date = 0;
    for i = 1:numel(files)
        if ~isempty(regexpi(files(i).name,['_',module,'_mapX.mat$']))
            filedate = str2double(files(i).name(1:14));

            if filedate > date
                date = filedate;
            end
        end
    end
    
    %Create the filename
    filename = [num2str(date),'_',module,'_mapX.mat'];
    if disp_flag
        disp(['TREX-RT>> Reading ',upper(module),' data: ',filename])
    end
    
    %Load the data
    moduleRead = load(fullfile(project_path,'Log',filename));
    
    %%
    %Cross check against the files actually found...
    map_files = findmapfiles_mapX(project_path,module);
    module_files = moduleRead.map_file;
    
    [~,ind] = setdiff(module_files,map_files);
    
    ind_log = true(numel(module_files),1);
    ind_log(ind) = false;
    
    fields_module = fieldnames(moduleRead);
    for i = 1:numel(fields_module)
        moduleRead.(fields_module{i}) = moduleRead.(fields_module{i})(ind_log,:);
    end

catch err
%%   
    files = dir(fullfile(project_path,'Log'));
        
    %Find the most current _EXTRACTX file
    date = 0;
    for i = 1:numel(files)
        if ~isempty(regexpi(files(i).name,'_extractX.mat$'))
            filedate = str2double(files(i).name(1:14));

            if filedate > date
                date = filedate;
            end
        end
    end
    
    %Get the variable names in the extract file
    vars = whos('-file',fullfile(project_path,'Log',[num2str(date),'_extractX.mat']));
    
    %Fields to keep
    fields = {'^project_',...
              '^patient_mrn',...
              '^plan_name',...
              '^image_',...
              '^dicom_',...
              '^roi_',...
              '^dose_',...
              'datestr$'};
    
    %Create moduleRead with the extract fields
    for i = 1:numel(fields)
        for j = 1:numel(vars)
            if ~isempty(regexpi(vars(j).name,fields{i}))
                if strcmpi(vars(j).class,'cell')
                    moduleRead.(vars(j).name) = cell(0);
                elseif strcmpi(vars(j).class,'logical')
                    moduleRead.(vars(j).name) = false;
                else
                    moduleRead.(vars(j).name) = nan;
                end
            end
        end
    end
    
    %Add module
    moduleRead.module = cell(0);
    
    %Add parameter fields
    parameters = parameterfields_mapX([]);
    parameters = fieldnames(parameters.(module));
    for i = 1:numel(parameters)
        if strcmpi(parameters{i},'toggle')
            %Nothing
        else
            moduleRead.(['parameter_',parameters{i}]) = cell(0);
        end
    end
    
    %Remove dim if both offset and dim are parameters
    if isfield(moduleRead,'parameter_offset') && isfield(moduleRead,'parameter_dim')
        moduleRead = rmfield(moduleRead,'parameter_dim');
    end
    
    moduleRead.map_file = cell(0);
    moduleRead.map_createdate = cell(0);
end

%%
clearvars -except moduleRead filename

