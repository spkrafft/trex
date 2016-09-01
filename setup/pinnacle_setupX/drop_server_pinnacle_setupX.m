function h = drop_server_pinnacle_setupX(h)
%%
set(h.push_add,'Enable','off')
set(h.push_remove,'Enable','off')

h = handlesoff_pinnacle_setupX(h,'institution');
h = handlesoff_pinnacle_setupX(h,'patient');
h = handlesoff_pinnacle_setupX(h,'plan');
h = handlesoff_pinnacle_setupX(h,'image');
h = handlesoff_pinnacle_setupX(h,'roi');
h = handlesoff_pinnacle_setupX(h,'dose');

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

h.export = resetexport_pinnacle_setupX(h.export,'institution');
h.export = resetexport_pinnacle_setupX(h.export,'patient');
h.export = resetexport_pinnacle_setupX(h.export,'plan');
h.export = resetexport_pinnacle_setupX(h.export,'image');
h.export = resetexport_pinnacle_setupX(h.export,'roi');
h.export = resetexport_pinnacle_setupX(h.export,'dose');

contents = cellstr(get(h.drop_server,'String'));
h.export.server_name = contents{get(h.drop_server,'Value')};

%Enables the connect button depending on the selection
if strcmpi(h.export.server_name,'')
    set(h.push_server,'Enable','off')    
elseif strcmpi(h.export.server_name,'Local Pinnacle')
    h.export.server_user = 'username';
    h.export.server_pass = 'password';
    
    set(h.push_server,'Enable','on')
    h.export.remote = false;
    h.export.pinnacle = true;
else
    set(h.push_server,'Enable','on')
    h.export.remote = true;
    h.export.pinnacle = true;
end

disp(['TREX-RT>> Server: ',h.export.server_name]);

%%
clearvars -except h
