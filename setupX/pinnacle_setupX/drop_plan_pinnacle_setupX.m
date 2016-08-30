function [h] = drop_plan_pinnacle_setupX(h)
%%
set(h.push_add,'Enable','off')
set(h.push_remove,'Enable','off')

h = handlesoff_pinnacle_setupX(h,'image');
h = handlesoff_pinnacle_setupX(h,'roi');
h = handlesoff_pinnacle_setupX(h,'dose');

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

h.export = resetexport_pinnacle_setupX(h.export,'plan');
h.export = resetexport_pinnacle_setupX(h.export,'image');
h.export = resetexport_pinnacle_setupX(h.export,'roi');
h.export = resetexport_pinnacle_setupX(h.export,'dose');

h.export.plan_path = h.plan_pathlist{get(h.drop_plan,'Value')};
h.export.plan_dir = h.plan_dirlist{get(h.drop_plan,'Value')};
h.export.plan_id = h.plan_idlist{get(h.drop_plan,'Value')};
h.export.plan_name = h.plan_namelist{get(h.drop_plan,'Value')};

disp('TREX-RT>> Gathering plan info...');
disp(['TREX-RT>> ',h.export.plan_dir,': ',h.export.plan_name]);
        
set(h.push_plan,'Enable','on')

%%
clearvars -except h
