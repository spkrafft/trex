function migration_projectX(varargin)

if ~isempty(varargin)
    project_path = varargin{1};
else
    project_path = uigetdir(pwd,'Select Project Directory');
end

%%
modules = {'setup',...
           'extract'};
       
dose = parameterfields_doseX([]);
tex = parameterfields_textureX([]);  
map = parameterfields_mapX([]);      

modules = [modules,strcat(dose.module_names,'_dose'),strcat(tex.module_names,'_texture'),strcat(map.module_names,'_map')];

%%        
% Delete vectorized files   
remove_doseX(project_path)

remove_textureX(project_path)

rundata = cell(0);

h = waitbar(0,'Project Migration In Progress...');

for i = 1:numel(modules)
    date = getDate_logX(project_path,modules{i});
    rundata{end+1,1} = modules{i};
    rundata{end,2} = date;
end

% Sort the files by date, not name...we might have a setup file created
% after texure or dose...but that doesn't mean we want to throw the
% texture/dose files away. This preserves the order so that we can look at
% the log files and still know that setup was created after texture was
% last run.
[~,ind] = sort(cell2mat(rundata(:,2)));
rundata = rundata(ind,:);

rewrite = 0;
%%
% Rewrite the log files
for i = 1:size(rundata,1)
    pause(1)
    
    if rundata{i,2} ~= 0
        if strcmpi(rundata{i,1},'extract')
            rewrite = fixXROI_MAT(project_path,'extract',rundata{i,2});
        else
            fixXROI_MAT(project_path,rundata{i,1},rundata{i,2});
        end
    end
end
%%
close(h)

% % Prompt to rewrite all of the extracted files
% if rewrite
%     
%     button = questdlg('Migrate extracted files?','projectMigrationX','Yes','No','No');
%     
%     if strcmpi(button,'Yes')
%         fixExtractedMAT(project_path)
%     end
% end
% 
% msgbox('Project Migration Completed!','modal')

clear

%--------------------------------------------------------------------------
function [rewrite] = fixXROI_MAT(project_path,module,date)
%%
rewrite = 0;
%fullfile(project_path,'Log',[num2str(date),'_',module,'X.mat'])
%Try to read in the most current file
try
    xroi = load(fullfile(project_path,'Log',[num2str(date),'_',module,'X.mat']));
catch err
    error('Issue with reading file in projectMigration')
end

paths = unique(xroi.project_path);
if numel(paths) > 1
    error(['Multiple paths in ',module])
end

%If the selected project path is not the same as the one in the file, then
%re-write it.
if ~strcmpi(project_path,paths{1})
    rewrite = 1;
    
    %Reset the project path in the cell array to the currently selected pat
    xroi.project_path(1:end) = {project_path};
        
    for i = 1:numel(xroi.project_path)
        if isfield(xroi,'project_patient') && ~isempty(xroi.project_patient{i})
            xroi.project_patient{i} = fullfile(project_path,num2str(xroi.patient_mrn(i)));
        end
        
        if isfield(xroi,'project_pinndata') && ~isempty(xroi.project_pinndata{i})
            xroi.project_pinndata{i} = fullfile(project_path,num2str(xroi.patient_mrn(i)),'Pinnacle Data');
        end
        
        if isfield(xroi,'project_scandata') && ~isempty(xroi.project_scandata{i})
            xroi.project_scandata{i} = fullfile(project_path,num2str(xroi.patient_mrn(i)),'Pinnacle Data',['CT.',xroi.image_internalUID{i}]);
        end
        
        if isfield(xroi,'project_dosedata') && ~isempty(xroi.project_dosedata{i})
            xroi.project_dosedata{i} = fullfile(project_path,num2str(xroi.patient_mrn(i)),'Pinnacle Data',['DOSE.',xroi.dose_internalUID{i}]);
        end
        
        if isfield(xroi,'project_roidata') && ~isempty(xroi.project_roidata{i})
            xroi.project_roidata{i} = fullfile(project_path,num2str(xroi.patient_mrn(i)),'Pinnacle Data',['ROI.',xroi.roi_internalUID{i}]);
        end
    end

    filename = [datestr(now,'yyyymmddHHMMSS'),'_',module,'X.mat'];
    save(fullfile(project_path,'Log',filename),'-struct','xroi')   
end
%%
clearvars -except rewrite

%--------------------------------------------------------------------------
function fixExtractedMAT(project_path)

h = waitbar(0,'Project Migration In Progress...');

files = dir(fullfile(project_path,'Log'));

% Find the most recent one to read in rather than passing the date of the
% old one
date = 0;
for i = 1:numel(files)
    if ~isempty(regexpi(files(i).name,'_extractX.mat$'))
        filedate = str2double(strrep(files(i).name,'_extractX.mat',''));

        if filedate > date
            date = filedate;
        end
    end
end

%Try to read in the most current file
try
    xroi = load(fullfile(project_path,'Log',[num2str(date),'_extractX.mat']));
catch err
    error('Issue with reading file in projectMigration')
end

for i = 1:numel(xroi.project_path)
    if ~isempty(xroi.image_file{i})
        s = load(fullfile(xroi.project_patient{i},xroi.image_file{i}));
        
        if isfield(s,'project_path') && ~isempty(s.project_path)
            s.project_path = xroi.project_path{i};
        end
        
        if isfield(s,'project_patient') && ~isempty(s.project_patient)
            s.project_patient = xroi.project_patient{i};
        end
        
        if isfield(s,'project_pinndata') && ~isempty(s.project_pinndata)
            s.project_pinndata = xroi.project_pinndata{i};
        end
        
        if isfield(s,'project_scandata') && ~isempty(s.project_scandata)
            s.project_scandata = xroi.project_scandata{i};
        end
        
        if isfield(s,'project_dosedata') && ~isempty(s.project_dosedata)
            s.project_dosedata = xroi.project_dosedata{i};
        end
        
        if isfield(s,'project_roidata') && ~isempty(s.project_roidata)
            s.project_roidata = xroi.project_roidata{i};
        end

        saveExtractedMAT(xroi.project_patient{i},xroi.image_file{i},s)
    end
    
    if ~isempty(xroi.dose_file{i})
        s = load(fullfile(xroi.project_patient{i},xroi.dose_file{i}));
        
        if isfield(s,'project_path') && ~isempty(s.project_path)
            s.project_path = xroi.project_path{i};
        end
        
        if isfield(s,'project_patient') && ~isempty(s.project_patient)
            s.project_patient = xroi.project_patient{i};
        end
        
        if isfield(s,'project_pinndata') && ~isempty(s.project_pinndata)
            s.project_pinndata = xroi.project_pinndata{i};
        end
        
        if isfield(s,'project_scandata') && ~isempty(s.project_scandata)
            s.project_scandata = xroi.project_scandata{i};
        end
        
        if isfield(s,'project_dosedata') && ~isempty(s.project_dosedata)
            s.project_dosedata = xroi.project_dosedata{i};
        end
        
        if isfield(s,'project_roidata') && ~isempty(s.project_roidata)
            s.project_roidata = xroi.project_roidata{i};
        end

        saveExtractedMAT(xroi.project_patient{i},xroi.dose_file{i},s)
    end
        
    if ~isempty(xroi.roi_file{i})
        s = load(fullfile(xroi.project_patient{i},xroi.roi_file{i}));
        
        if isfield(s,'project_path') && ~isempty(s.project_path)
            s.project_path = xroi.project_path{i};
        end
        
        if isfield(s,'project_patient') && ~isempty(s.project_patient)
            s.project_patient = xroi.project_patient{i};
        end
        
        if isfield(s,'project_pinndata') && ~isempty(s.project_pinndata)
            s.project_pinndata = xroi.project_pinndata{i};
        end
        
        if isfield(s,'project_scandata') && ~isempty(s.project_scandata)
            s.project_scandata = xroi.project_scandata{i};
        end
        
        if isfield(s,'project_dosedata') && ~isempty(s.project_dosedata)
            s.project_dosedata = xroi.project_dosedata{i};
        end
        
        if isfield(s,'project_roidata') && ~isempty(s.project_roidata)
            s.project_roidata = xroi.project_roidata{i};
        end

        saveExtractedMAT(xroi.project_patient{i},xroi.roi_file{i},s)
    end
    
    waitbar(i/numel(xroi.project_path),h) 
end

close(h)

clearvars

%--------------------------------------------------------------------------
function saveExtractedMAT(project_patient,filename,s)
disp([fullfile(project_patient,filename),'...saved!'])
save(fullfile(project_patient,filename),'-struct','s')
