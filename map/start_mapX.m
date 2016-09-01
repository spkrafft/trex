function [h] = start_mapX(h)
%%
set(h.push_start,'Enable','off')
start = tic;

disp('TREX-RT>> Texture map extraction started...')

%% Run each module
for i = 1:numel(h.module_names)
    module = h.module_names{i};
    if strcmpi(h.(module).toggle,'on')
        h = startmodule_mapX(h,module);
    end
    pause(0.001)
end

%%
set(h.text_wait2,'String','Texture map extraction complete!')
drawnow; pause(0.001);
disp('TREX-RT>> Texture map Extraction Complete!')
disp(['TREX-RT>> Total MapX run time: ',num2str(toc(start)),' seconds'])

%%
clearvars -except h
