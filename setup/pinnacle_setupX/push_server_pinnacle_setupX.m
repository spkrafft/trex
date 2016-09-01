function [h] = push_server_pinnacle_setupX(h)
%%
h = suspendhandles_pinnacle_setupX(h);

%%%GET INSTITUTION INFO 
if h.export.remote
    %Get the FTP server username and password
%     prompt = {'Username:','Password:'};
    dlg_title = 'FTP Connection';
%     num_lines = 1;
%     answer = inputdlg(prompt,dlg_title,num_lines);
%     h.export.server_user = answer{1};
%     h.export.server_pass = answer{2};
    
    [h.export.server_user, h.export.server_pass] = logindlg('Title',dlg_title);
    
    disp('TREX-RT>> Connecting...');
    disp(['TREX-RT>> Server: ',h.export.server_name,', Username: ',h.export.server_user,', Password: ',h.export.server_pass]);

    %Try to connect to the server
    try
        h.ftp = ftp(h.export.server_name,h.export.server_user,h.export.server_pass);
    catch err
        
        disp('TREX-RT>> Connection Aborted!');

        try
            close(h.ftp);
        catch err
        end

        return
    end

    disp('TREX-RT>> Connected!');

    %Set the directory which contains all of the pinnacle data
    if strcmpi(h.export.server_user,'pinnbeta')
        h.export.home_path = '/pinnacle_patient_expansion/BetaPatients/';
    else
        h.export.home_path = '/pinnacle_patient_expansion/NewPatients/';
    end

else
    h.export.home_path = uigetdir(h.export.project_path,'Select the home Pinnacle directory (i.e. BetaPatients or NewPatients directory)');   
end

disp(['TREX-RT>> Home Directory: ',h.export.home_path]);

%Get the list of institutions and initialize
if h.export.remote
    list = dir(h.ftp,h.export.home_path);
else
    list = dir(h.export.home_path);
end

h.institution_pathlist = cell(0);
h.institution_dirlist = cell(0);

% h.institution_namelist = cell(0);
% h.institution_streetlist = cell(0);
% h.institution_street2list = cell(0);

disp('TREX-RT>> Getting institution names...');

%Cycle through each file/directory in the home directory...
for i = 1:numel(list)
    %...stop if it is one of the institutions
    if ~isempty(regexpi(list(i).name,'Institution_[0-9]')) && list(i).isdir
        if h.export.remote
            h.institution_pathlist{end+1,1} = [h.export.home_path,'/',list(i).name,'/'];
        else
            h.institution_pathlist{end+1,1} = fullfile(h.export.home_path,list(i).name);
        end
        h.institution_dirlist{end+1,1} = list(i).name;
        
%         %Get the list of files within the institution directory and transfer the
%         %institution file to the project directory
%         if h.export.remote
%             cd(h.ftp,h.institution_pathlist{end,1});
%             inst_file = mget(h.ftp,'Institution',h.export.project_path);
%             inst_file = inst_file{1};
%             cd(h.ftp,h.export.home_path);
%         else
%             copyfile(fullfile(h.institution_pathlist{end,1},'Institution'),h.export.project_path);
%             inst_file = fullfile(h.export.project_path,'Institution');
%         end
% 
%         %Open, read, and close the institution file
%         fid = fopen(inst_file);
%         temp_institution = textscan(fid,'%s','delimiter','\n');
%         temp_institution = temp_institution{1};
%         fclose(fid);
% 
%         h.institution_namelist{end+1,1} = textParserX(temp_institution,'Name ');
%         h.institution_streetlist{end+1,1} = textParserX(temp_institution,'StreetAddress ');
%         h.institution_street2list{end+1,1} = textParserX(temp_institution,'StreetAddress2 ');
% 
%         clear temp_institution
%         delete(inst_file)
    end
end
clear list

disp(['TREX-RT>> Detected ',num2str(numel(h.institution_dirlist)),' unique institutions!']);

restorehandles_pinnacle_setupX(h)

if numel(h.institution_dirlist) > 0
            
    set(h.drop_institution,'Enable','on')
    set(h.drop_institution,'String',h.institution_dirlist)

    disp('TREX-RT>> Institution drop down menu populated. Please select an institution.');
else
    disp('TREX-RT>> No available institution data. Please select a different server or login username.');
    msgbox('No available institution data. Please select a different server or login username.','SetupX: Warning','error')
end

%%
clearvars -except h
