function [h] = start_doseX(h)
%%
set(h.push_start,'Enable','off')
start = tic;

remove_doseX(h.project_path)

disp('TREX-RT>> Dose data extraction started...')

%% Run each module
for i = 1:numel(h.module_names)
    module = h.module_names{i};
    
    if strcmpi(h.(module).toggle,'on')
        [h] = startmodule_doseX(h,module);
    end
    
    pause(0.001)
end

%%
set(h.text_wait2,'String','Dose extraction complete!')
drawnow; pause(0.001);
disp('TREX-RT>> Dose Data Extraction Complete!')
disp(['TREX-RT>> Total DoseX run time: ',num2str(toc(start)),' seconds'])

%%
clearvars -except h hObject
