function [h] = start_textureX(h)
%%
set(h.push_start,'Enable','off')
start = tic;

remove_textureX(h.project_path)

disp('TREX-RT>> Texture data extraction started...')

%% Run each module
for i = 1:numel(h.module_names)
    module = h.module_names{i};
    if strcmpi(h.(module).toggle,'on')
        [h] = startmodule_textureX(h,module);
    end
    pause(1)
end

%%
set(h.text_wait2,'String','Texture extraction complete!')
drawnow; pause(0.1);
disp('TREX-RT>> Texture Data Extraction Complete!')
disp(['TREX-RT>> Total TextureX run time: ',num2str(toc(start)),' seconds'])

%%
clearvars -except h hObject

