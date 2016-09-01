function data_exportX(project_path, output_path)

[~,project_name] = fileparts(project_path);
output_dir = [datestr(now,'yyyymmdd'),' ',project_name];
copyfile(fullfile(project_path,'*.mat'),fullfile(output_path,output_dir))
