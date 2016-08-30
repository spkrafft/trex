function remove_textureX(project_path)
%% Remove each module.mat
h = parameterfields_textureX();
for i = 1:numel(h.module_names)
    filename = [upper(h.module_names{i}),'.mat'];
    if exist(fullfile(project_path,filename),'file') == 2
        delete(fullfile(project_path,filename))
    end
end
%%
clearvars

