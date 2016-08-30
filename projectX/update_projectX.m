function update_projectX(varargin)
%%
% if ~isempty(varargin)
%     project_path = varargin{1};
% else
%     project_path = uigetdir(pwd,'Select Project Directory');
% end

% %%
% remove_textureX(project_path)
% if exist(fullfile(project_path,'SHAPE.mat'),'file') == 2
%     delete(fullfile(project_path,'SHAPE.mat'))
% end
% 
% remove_doseX(project_path)
% if exist(fullfile(project_path,'DMH.mat'),'file') == 2
%     delete(fullfile(project_path,'DMH.mat'))
% end
% 
% %%
% try
%     [moduleRead,filename] = read_doseX(project_path,'dvh');
%     moduleRead = rmfield(moduleRead,'feature_NumVoxels');
%     save(fullfile(project_path,'Log',filename),'-struct','moduleRead')
% catch err
%     
% end

%%
% try
%     [moduleRead,filename] = read_textureX(project_path,'lung');
%     delete(fullfile(project_path,'Log',filename))
% catch err
%     
% end

%%
% h = waitbar(0,'Project Update In Progress...');
% 
% %%
% close(h)
% 
% clear

