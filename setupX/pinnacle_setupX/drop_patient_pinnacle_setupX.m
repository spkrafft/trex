function [h] = drop_patient_pinnacle_setupX(h)
%%
set(h.push_add,'Enable','off')
set(h.push_remove,'Enable','off')

h = handlesoff_pinnacle_setupX(h,'plan');
h = handlesoff_pinnacle_setupX(h,'image');
h = handlesoff_pinnacle_setupX(h,'roi');
h = handlesoff_pinnacle_setupX(h,'dose');

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

h.export = resetexport_pinnacle_setupX(h.export,'patient');
h.export = resetexport_pinnacle_setupX(h.export,'plan');
h.export = resetexport_pinnacle_setupX(h.export,'image');
h.export = resetexport_pinnacle_setupX(h.export,'roi');
h.export = resetexport_pinnacle_setupX(h.export,'dose');

disp('TREX-RT>> Gathering patient info...')

h.export.patient_path = h.patient_pathlist{get(h.drop_patient,'Value')};
h.export.patient_dir = h.patient_dirlist{get(h.drop_patient,'Value')};

h = suspendhandles_pinnacle_setupX(h);

%Get the list of files within the patient directory and transfer the
%patient file to the project directory
if h.export.remote
    cd(h.ftp,h.export.patient_path);
    drawnow; pause(0.1);
    pat_file = mget(h.ftp,'Patient',h.export.project_path);
    pat_file = pat_file{1};
    cd(h.ftp,h.export.home_path);
else
    copyfile(fullfile(h.export.patient_path,'Patient'),h.export.project_path);
    pat_file = fullfile(h.export.project_path,'Patient');
end

%Open, read, and close the patient file
fid = fopen(pat_file);
h.filedata.patient = textscan(fid,'%s','delimiter','\n');
h.filedata.patient = h.filedata.patient{1};
fclose(fid);

last = textParserX(h.filedata.patient,'LastName ');
first = textParserX(h.filedata.patient,'FirstName ');
h.export.patient_name = [last,', ',first];
h.export.patient_mrn = str2double(textParserX(h.filedata.patient,'MedicalRecordNumber '));

delete(pat_file)

restorehandles_pinnacle_setupX(h)

disp(['TREX-RT>> ',h.export.patient_dir,': ',h.export.patient_name,', ',num2str(h.export.patient_mrn)]);

set(h.push_patient,'Enable','on')
      
%%
clearvars -except h
