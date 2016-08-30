function [h] = push_patient_pinnacle_setupX(h)
%%
h = suspendhandles_pinnacle_setupX(h);

disp('TREX-RT>> Patient selected!');
disp(['TREX-RT>> Patient Directory: ',h.export.patient_path]);

%Get the list of plans and initialize
if h.export.remote
    list = dir(h.ftp,h.export.patient_path);
else
    list = dir(h.export.patient_path);
end

h.plan_pathlist = cell(0);
h.plan_dirlist = cell(0);
h.plan_idlist = cell(0);
h.plan_namelist = cell(0);

disp('TREX-RT>> Getting available plan names...');

%Cycle through each file/directory in the patient directory...
for i = 1:numel(list)
    %...stop if it is one of the plans
    if ~isempty(regexpi(list(i).name,'^Plan_[0-9]')) && list(i).isdir
        if h.export.remote
            h.plan_pathlist{end+1,1} = [h.export.patient_path,'/',list(i).name,'/'];
        else
            h.plan_pathlist{end+1,1} = fullfile(h.export.patient_path,list(i).name);
        end
        h.plan_dirlist{end+1,1} = list(i).name;
        h.plan_idlist{end+1,1} = list(i).name(6:end);
    end
end
clear list

h.filedata.plandata = splitParserX(h.filedata.patient,'Plan ');

for i = 1:numel(h.plan_dirlist)
    for cellInd = 1:numel(h.filedata.plandata)
        planid = textParserX(h.filedata.plandata{cellInd},'PlanID ');
        
        if strcmpi(h.plan_idlist{i},planid)
            h.plan_namelist{end+1,1} = textParserX(h.filedata.plandata{cellInd},'PlanName ');
            break
        end
        clear planid
    end
end

disp(['TREX-RT>> Detected ',num2str(numel(h.plan_dirlist)),' unique plans!']);

restorehandles_pinnacle_setupX(h)

if numel(h.plan_dirlist) > 0
    h.plan_stringlist = strcat(h.plan_dirlist,repmat({': '},numel(h.plan_dirlist),1),h.plan_namelist);

    set(h.drop_plan,'Enable','on')
    set(h.drop_plan,'String',h.plan_stringlist)

    disp('TREX-RT>> Plan drop down menu populated. Please select an plan.');
else
    disp('TREX-RT>> No available plan data. Please select a different server/username/institution/plan.');
    msgbox('No available plan data. Please select a different server/username/institution/plan.','Warning: SetupX','error');
end

h.filedata = rmfield(h.filedata,'patient');

%%
clearvars -except h
