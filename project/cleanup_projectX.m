function cleanup_projectX(project_path)
%Function to remove all of the Raw Data directories from a chosen Project

list = dir(project_path);

w = waitbar(0,'Please wait...');
steps = numel(list);

for i = 1:numel(list)
    if list(i).isdir && numel(list(i).name) > 2
        path = fullfile(project_path,list(i).name,'Pinnacle Data');
        path_exist = exist(path,'dir');
        
        if path_exist == 7
            stat = rmdir(path,'s');
            
            if stat == 1
                disp(['TREX-RT>> ',fullfile(project_path,list(i).name,'Pinnacle Data'),' deleted'])
            else
                disp(['TREX-RT>> ***',fullfile(project_path,list(i).name,'Pinnacle Data'),' failed to delete'])
            end
        end
    end

    waitbar(i/steps,w)
end

close(w)
