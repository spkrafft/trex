function [h] = drop_dose_pinnacle_setupX(h)
%%
set(h.push_doseinfo,'Enable','off')
set(h.menu_doseinfo,'Enable','off')

set(h.push_displaydose,'Enable','off')
set(h.push_displaydose,'Value',0)
set(h.menu_displaydose,'Enable','off')
set(h.menu_displaydose,'Checked','off')

h.dosetoggle = false;
h.dose = [];

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

h.export.dose_name = h.dose_namelist{get(h.drop_dose,'Value')};
h.export.dose_internalUID = dicomuid;

h = suspendhandles_pinnacle_setupX(h);

if ~strcmpi(h.export.dose_name,'')
    disp('TREX-RT>> Checking dose array data...');
    h = doseInfo_pinnacle_setupX(h); %This makes call to readDose as well
end

restorehandles_pinnacle_setupX(h)

if isempty(h.dose)
    h.export.dose_name = [];
    h.export.dose_internalUID = [];
    
    set(h.drop_dose,'Value',1)
else
    disp(['TREX-RT>> Selected Dose Trial: ',h.export.dose_name]);
    
    set(h.push_doseinfo,'Enable','on')
    set(h.menu_doseinfo,'Enable','on')
    set(h.push_displaydose,'Enable','on')
    set(h.menu_displaydose,'Enable','on')
end

%%
clearvars -except h
