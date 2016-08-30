function move_mapX(project_dir,new_dir)

dir_list = dir(project_dir);

[~,project_name] = fileparts(project_dir);

for i = 1:numel(dir_list)
    if dir_list(i).isdir
        
        list = dir(fullfile(project_dir,dir_list(i).name));
        
        if sum(strcmpi({list.name},'mapx')) == 1
            movefile(fullfile(project_dir,dir_list(i).name,'mapx'),fullfile(new_dir,project_name,dir_list(i).name,'mapx'))
        end
    end
end