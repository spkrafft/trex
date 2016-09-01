function projectmodules_copyX(project_path,dest_path)
%%
if isempty(project_path)
    project_path = uigetdir;
end

[~,project_name] = fileparts(project_path);

try
    mkdir(fullfile(dest_path,project_name))
    copyfile(fullfile(project_path,'*.mat'),...
             fullfile(dest_path,project_name))

    mkdir(fullfile(dest_path,project_name,'Log'))
    copyfile(fullfile(project_path,'Log'),...
             fullfile(dest_path,project_name,'Log'))
catch
    
end
