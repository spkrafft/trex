function [extractWrite] = validate_pinnacle_extractX(extractWrite,entry)
%%
%Try to connect to server if it is remote pinnacle
if extractWrite.remote
    try
        extractWrite.ftp = ftp(extractWrite.server_name,extractWrite.server_user,extractWrite.server_pass);
    catch err
        disp(['TREX-RT>> Entry ',num2str(entry),': ','Server connection could not be established!']);
        return
    end
end

%Try to find patient directory
if extractWrite.remote
    try
        cd(extractWrite.ftp,extractWrite.patient_path);
    catch err
        disp(['TREX-RT>> Entry ',num2str(entry),': ','Associated patient directory not found!']);
        return
    end
else
    if exist(extractWrite.patient_path,'dir') ~= 7
        disp(['TREX-RT>> Entry ',num2str(entry),': ','Associated patient directory not found!']);
        return
    end
end

%Make sure that the plan path exists
if extractWrite.remote
    try
        cd(extractWrite.ftp,extractWrite.plan_path);
    catch err
        disp(['TREX-RT>> Entry ',num2str(entry),': ','Associated plan not found!']);
        return
    end
else
    if exist(extractWrite.plan_path,'dir') ~= 7
        disp(['TREX-RT>> Entry ',num2str(entry),': ','Associated plan not found!']);
        return
    end
end

extractWrite.validated = true;

disp(['TREX-RT>> Entry ',num2str(entry),': ','Validated!']);

%%
clearvars -except extractWrite
