function [h] = suspendhandles_pinnacle_setupX(h)
%%
h.suspend = [];
for i = 1:numel(h.h_names)
    h.suspend.(h.h_names{i}) = get(h.(h.h_names{i}),'Enable');
    set(h.(h.h_names{i}),'Enable','off');
end

drawnow; pause(0.001);

%%
clearvars -except h
