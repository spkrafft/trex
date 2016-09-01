function cleanup_logX(project_path)

%%
modules = {'setup',...
           'extract'};
       
dose = parameterfields_doseX([]);
tex = parameterfields_textureX([]);  
map = parameterfields_mapX([]);      

modules = [modules,strcat(dose.module_names,'_dose'),strcat(tex.module_names,'_texture'),strcat(map.module_names,'_map')];
           
rundata = cell(0);
for i = 1:numel(modules)
    date = getDate_logX(project_path,modules{i});
    rundata{end+1,1} = modules{i};
    rundata{end,2} = date;
end
%%
filenames = cell(0);
list = dir(fullfile(project_path,'Log'));
for i = 1:numel(list)
    if ~isempty(regexpi(list(i).name,'.mat$')) || ~isempty(regexpi(list(i).name,'.xlog$'))
        filenames{end+1,1} = list(i).name;
    end
end

%%
keep = false(size(filenames));
for i = 1:size(rundata,1)    
    if rundata{i,2} ~= 0
        keep = ~cellfun(@isempty,regexpi(filenames,[num2str(rundata{i,2}),'_',rundata{i,1},'(\w*)X.mat'])) | keep;
    end
end

%%
[s,mess,messid] = mkdir(fullfile(project_path,'Log'),'old');

for i = 1:numel(keep)
    if ~keep(i)
        %filenames{i}
        movefile(fullfile(project_path,'Log',filenames{i}),fullfile(project_path,'Log','old',filenames{i}))
    end
end

%%
clearvars