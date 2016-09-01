function [h] = drop_institution_pinnacle_setupX(h)
%%
set(h.push_add,'Enable','off')
set(h.push_remove,'Enable','off')

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

disp('TREX-RT>> Gathering institution info...')

h.export.institution_path = h.institution_pathlist{get(h.drop_institution,'Value')};
h.export.institution_dir = h.institution_dirlist{get(h.drop_institution,'Value')};

h = suspendhandles_pinnacle_setupX(h);

%Get the list of files within the institution directory and transfer the
%institution file to the project directory
if h.export.remote
    cd(h.ftp,h.export.institution_path);
    drawnow; pause(0.1);
    inst_file = mget(h.ftp,'Institution',h.export.project_path);
    inst_file = inst_file{1};
    cd(h.ftp,h.export.home_path);
else
    copyfile(fullfile(h.export.institution_path,'Institution'),h.export.project_path);
    inst_file = fullfile(h.export.project_path,'Institution');
end

%Open, read, and close the institution file
fid = fopen(inst_file);
h.filedata.institution = textscan(fid,'%s','delimiter','\n');
h.filedata.institution = h.filedata.institution{1};
fclose(fid);

h.export.institution_name = textParserX(h.filedata.institution,'Name ');
h.export.institution_street = textParserX(h.filedata.institution,'StreetAddress ');
h.export.institution_street2 = textParserX(h.filedata.institution,'StreetAddress2 ');

%clear institution
delete(inst_file)

restorehandles_pinnacle_setupX(h)

disp(['TREX-RT>> ',h.export.institution_dir,': ',h.export.institution_name,', ',h.export.institution_street,', ',h.export.institution_street2]);

set(h.push_institution,'Enable','on')

%%
clearvars -except h
