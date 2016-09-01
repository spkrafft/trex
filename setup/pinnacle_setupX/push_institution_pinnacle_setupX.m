function [h] = push_institution_pinnacle_setupX(h)
%%
h = suspendhandles_pinnacle_setupX(h);

disp('TREX-RT>> Institution selected!');
disp(['TREX-RT>> Institution Path: ',h.export.institution_path]);

h.export.institution_path = [h.export.institution_path,'/Mount_0/'];

%Get the list of patients and initialize
if h.export.remote
    list = dir(h.ftp,h.export.institution_path);
else
    list = dir(h.export.institution_path);
end
h.patient_pathlist = cell(0);
h.patient_dirlist = cell(0);

mrnlist = cell(0);
namelist = cell(0);
stringlist = cell(0);

disp('TREX-RT>> Getting patient data...');

splitInstitution = splitParserX(h.filedata.institution,'PatientLite ={');

for i = 1:numel(splitInstitution)
    desc = textParserX(splitInstitution{i},'FormattedDescription =');
    ind = regexpi(desc,'&[0-9]');
    mrn{i} = desc(ind(1)+1:ind(1)+6);
    name{i} = strrep(desc(1:ind(1)),'&',' ');
    patientid{i} = textParserX(splitInstitution{i},'PatientID =');
end

%Cycle through each file/directory in the institution directory...
for i = 1:numel(list)
    %...stop if it is one of the patients
    if ~isempty(regexpi(list(i).name,'^Patient_[0-9]')) && list(i).isdir
        if h.export.remote
            h.patient_pathlist{end+1,1} = [h.export.institution_path,'/',list(i).name,'/'];
        else
            h.patient_pathlist{end+1,1} = fullfile(h.export.institution_path,list(i).name);
        end
        h.patient_dirlist{end+1,1} = list(i).name;
        
        ind = strcmpi(patientid,strrep(list(i).name,'Patient_',''));
        
        mrnlist{end+1,1} = mrn{ind};
        namelist{end+1,1} = name{ind};
        
        stringlist{end+1,1} = [mrnlist{end,1},' ',namelist{end,1}];
        
    end
end
clear list

[~,ind] = sort(mrnlist);
h.patient_stringlist = stringlist(ind);
h.patient_pathlist = h.patient_pathlist(ind);
h.patient_dirlist = h.patient_dirlist(ind);

disp(['TREX-RT>> Detected ',num2str(numel(h.patient_dirlist)),' unique patients!']);

restorehandles_pinnacle_setupX(h)

if numel(h.patient_dirlist) > 0
    set(h.drop_patient,'Enable','on')
    set(h.drop_patient,'String',h.patient_stringlist)

    disp('TREX-RT>> Patient drop down menu populated. Please select an patient.');
else
    disp('TREX-RT>> No available patient data. Please select a different server/username/institution.');
    msgbox('No available patient data. Please select a different server/username/institution.','Warning: SetupX','error');
end

%%
clearvars -except h
