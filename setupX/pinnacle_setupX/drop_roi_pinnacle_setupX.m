function [h] = drop_roi_pinnacle_setupX(h)
%%
set(h.push_add,'Enable','off')
set(h.push_remove,'Enable','off')

h.roitoggle_curve = false;
h.roi.curvedata = [];

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

h.export.roi_name = h.roi_namelist{get(h.drop_roi,'Value')};
h.export.roi_source = h.export.roi_name;
h.export.roi_int = [];
h.export.roi_ext = [];

disp(['TREX-RT>> Selected ROI: ',h.export.roi_name]);

set(h.push_displaycurveroi,'Enable','on')
set(h.menu_displaycurveroi,'Enable','on')
set(h.push_add,'Enable','on')

set(h.menu_script,'Enable','on')

%%
clearvars -except h
