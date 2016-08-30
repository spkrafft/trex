function [extractWrite] = doseDownload_pinnacle_extractX(extractWrite,extractRead,entry)
%%
%If no dose is selected for the given extractWrite, don't bother doing anything
%else.
if strcmpi(extractWrite.dose_name,'') || isempty(extractWrite.dose_name)
    
else
    extractWrite.project_dosedata = fullfile(extractWrite.project_pinndata,['DOSE.',extractWrite.dose_internalUID]);
    extractWrite.dose_file = ['DOSE.',extractWrite.dose_internalUID,'.mat'];

    [s,mess,messid] = mkdir(extractWrite.project_pinndata,['DOSE.',extractWrite.dose_internalUID]);
    disp(['TREX-RT>> Entry ',num2str(entry),': ','Dose data directory ',extractWrite.project_dosedata]);
    
    %Look for previously downloaded trial data...
    files = dir(extractWrite.project_dosedata);
    found = false;
    for i = 1:numel(files)
        if strcmpi(files(i).name,'plan.Trial')
            found = true;
            break
        end
    end
    
    %If trial data has already been downloaded...
    if found
        %Read the previously downloaded data...
        fid = fopen(fullfile(extractWrite.project_dosedata,'plan.Trial'));
        trial = textscan(fid,'%s','delimiter','\n');
        trial = trial{1};
        fclose(fid);
        
        fid = fopen(fullfile(extractWrite.project_dosedata,'plan.Pinnacle.Machines'));
        machine = textscan(fid,'%s','delimiter','\n');
        machine = machine{1};
        fclose(fid);

        %Download/copy the new trial data...
        if extractWrite.remote
            extractWrite.ftp = ftp(extractWrite.server_name,extractWrite.server_user,extractWrite.server_pass);
            cd(extractWrite.ftp,extractWrite.plan_path);

            dlPath1 = mget(extractWrite.ftp,'plan.Trial',extractWrite.project_path);
            dlPath1 = dlPath1{1};
            
            dlPath2 = mget(extractWrite.ftp,'plan.Pinnacle.Machines',extractWrite.project_path);
            dlPath2 = dlPath2{1};
            
            close(extractWrite.ftp);
        else
            copyfile(fullfile(extractWrite.plan_path,'plan.Trial'),extractWrite.project_path);
            dlPath1 = fullfile(extractWrite.project_path,'plan.Trial');
            
            copyfile(fullfile(extractWrite.plan_path,'plan.Pinnacle.Machines'),extractWrite.project_path);
            dlPath2 = fullfile(extractWrite.project_path,'plan.Pinnacle.Machines');
        end
        
        %...and read it
        fid = fopen(dlPath1);
        dlTrial = textscan(fid,'%s','delimiter','\n');
        dlTrial = dlTrial{1};
        fclose(fid);
        
        delete(dlPath1)
        
        fid = fopen(dlPath2);
        dlMachine = textscan(fid,'%s','delimiter','\n');
        dlMachine = dlMachine{1};
        fclose(fid);
        
        delete(dlPath2)     

        trial = splitParserX(trial,'Trial ={');
        for i = 1:numel(trial)
            if strcmpi(textParserX(trial{i},'Name ='),extractWrite.dose_name)
            	break
            end
        end
        trial = trial{i};
        
        dlTrial = splitParserX(dlTrial,'Trial ={');
        for i = 1:numel(dlTrial)
            if strcmpi(textParserX(dlTrial{i},'Name ='),extractWrite.dose_name)
            	break
            end
        end
        dlTrial = dlTrial{i};

        %Compare the previous trial data to the downloaded data and if they
        %are not the same then...
        if ~isequal(trial,dlTrial) || ~isequal(machine,dlMachine)
            found = false;
            time = datestr(now,'yyyymmddHHMMSS');
            %Find all of the previous trial data files and rename them
            %(just by appending the time). I want to save these rather than
            %delete them in case we need to revert back to the original
            %data for whatever reason.
            for i = 1:numel(files)
                if ~isempty(regexpi(files(i).name,'^plan.Trial')) || ~isempty(regexpi(files(i).name,'^plan.Pinnacle.Machines'))
                    movefile(fullfile(extractWrite.project_dosedata,files(i).name),fullfile(extractWrite.project_dosedata,[time,'_',files(i).name]));
                end
            end
            
            %Also try to rename the previously converted dose data to force the new
            %trial data to be converted
            try
                movefile(fullfile(extractWrite.project_patient,extractWrite.dose_file),fullfile(extractWrite.project_patient,[time,'_',extractWrite.dose_file]));
            catch err
            end
            
            %Also try to delete the previously converted roi data to force the new
            %roi data to be converted
            %Force this to delete in the event that the ROI depends on the dose
            try
                %This will move all of the roi files with the same internal
                %UID to force recalculation of everything
                roifiles = dir(extractWrite.project_patient);
                for i = 1:numel(roifiles)
                    if ~isempty(regexpi(roifiles(i).name,[extractWrite.roi_internalUID,'.mat$']))
                        movefile(fullfile(extractWrite.project_patient,roifiles(i).name),fullfile(extractWrite.project_patient,[time,'_',roifiles(i).name]));
                    end
                end
            catch err
            end
            
            %Also rename any previously calculated mapx stuff
            try
                mapfiles = dir(fullfile(extractWrite.project_patient,'mapx'));
                for i = 1:numel(mapfiles)
                    if ~isempty(regexpi(mapfiles(i).name,[extractWrite.roi_internalUID,'.mat$']))
                        movefile(fullfile(extractWrite.project_patient,'mapx',mapfiles(i).name),fullfile(extractWrite.project_patient,'mapx',[time,'_',mapfiles(i).name]));
                    end
                end
            catch err
            end
            
            disp(['TREX-RT>> Entry ',num2str(entry),': Dose data has changed']);
        else      
            extractWrite.dlDose = true;
            extractWrite.dlDose_datestr = extractRead.dlDose_datestr;
        end
    end
    
    %Download/copy if it doesn't exist
    if ~found
        %Download the plan.Trial file
        if extractWrite.remote
            extractWrite.ftp = ftp(extractWrite.server_name,extractWrite.server_user,extractWrite.server_pass);
            cd(extractWrite.ftp,extractWrite.plan_path);

            trialPath = mget(extractWrite.ftp,'plan.Trial',extractWrite.project_dosedata);
            trialPath = trialPath{1};
            
            close(extractWrite.ftp);
        else
            copyfile(fullfile(extractWrite.plan_path,'plan.Trial'),extractWrite.project_dosedata);
            trialPath = fullfile(extractWrite.project_dosedata,'plan.Trial');
        end
        
        %Download the plan.Pinnacle.Machines file
        if extractWrite.remote
            extractWrite.ftp = ftp(extractWrite.server_name,extractWrite.server_user,extractWrite.server_pass);
            cd(extractWrite.ftp,extractWrite.plan_path);

            machinePath = mget(extractWrite.ftp,'plan.Pinnacle.Machines',extractWrite.project_dosedata);
            machinePath = machinePath{1};
            
            close(extractWrite.ftp);
        else
            copyfile(fullfile(extractWrite.plan_path,'plan.Pinnacle.Machines'),extractWrite.project_dosedata);
            machinePath = fullfile(extractWrite.project_dosedata,'plan.Pinnacle.Machines');
        end
        
        %Read the plan.Trial file...
        fid = fopen(trialPath);
        trial = textscan(fid,'%s','delimiter','\n');
        trial = trial{1};
        fclose(fid);

        %...and find the data for the selected trial
        trialdata = splitParserX(trial,'Trial ={');

        for cellInd = 1:numel(trialdata)
            name = textParserX(trialdata{cellInd},'Name ');
            if strcmpi(extractWrite.dose_name,name)
                break
            end 
        end
        
        trialdata = trialdata{cellInd};
 
        %Then read the beam data for the selected trial...
        beams = splitParserX(trialdata,'Beam ={');
        for i = 1:numel(beams)
            filename = textParserX(beams{i},'DoseVolume ');
            filename = filename(regexpi(filename,'[0-9]'));

            while length(filename) < 3
                filename = ['0',filename];
            end

            filename = ['plan.Trial.binary.',filename];
            
            %...and download the correct binary file for each beam
            if extractWrite.remote
                extractWrite.ftp = ftp(extractWrite.server_name,extractWrite.server_user,extractWrite.server_pass);
                cd(extractWrite.ftp,extractWrite.plan_path);
                
                mget(extractWrite.ftp,filename,extractWrite.project_dosedata);
                
                close(extractWrite.ftp);
            else
                copyfile(fullfile(extractWrite.plan_path,filename),extractWrite.project_dosedata);
            end            
        end
        
        extractWrite.dlDose = true;
        extractWrite.dlDose_datestr = datestr(now,'yyyymmddHHMMSS');
        disp(['TREX-RT>> Entry ',num2str(entry),': Dose data downloaded/copied to ',extractWrite.project_dosedata]);
    end
end 

%%
clearvars -except extractWrite
