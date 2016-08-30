function restorehandles_pinnacle_setupX(h)
%%
for i = 1:numel(h.h_names)
    set(h.(h.h_names{i}),'Enable',h.suspend.(h.h_names{i}));
end

drawnow; pause(0.001);
