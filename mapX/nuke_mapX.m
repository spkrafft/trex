function nuke_mapX(project_dir)

dir_list = dir(project_dir);

for i = 1:numel(dir_list)
    if dir_list(i).isdir
        
        list = dir(fullfile(project_dir,dir_list(i).name));
        
        if sum(strcmpi({list.name},'mapx')) == 1
            rmdir(fullfile(project_dir,dir_list(i).name,'mapx'),'s')
        end
    end
end