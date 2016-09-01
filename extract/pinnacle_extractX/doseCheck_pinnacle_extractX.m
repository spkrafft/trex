function doseCheck_pinnacle_extractX(extractRead,entry)
%%
%If no dose is selected for the given extractWrite, don't bother doing anything
%else.
if strcmpi(extractRead.dose_name,'') || isempty(extractRead.dose_name)
    %Do nothing
else
    disp(['TREX-RT>> Entry ',num2str(entry),': Checking dose...'])
    
    %Look for previously converted dose data...
    files = dir(extractRead.project_patient);
    found = false;
    for i = 1:numel(files)
        if strcmpi(files(i).name,extractRead.dose_file)
            found = true;
            break
        end
    end
    
    if ~found
        %Do nothing
    else
        %Check the file
        old = load(fullfile(extractRead.project_patient,extractRead.dose_file));
        dose = doseInfo_pinnacle_extractX(extractRead);
        
        good = true;
        
        fields_beam = intersect(fieldnames(old(1).beam),fieldnames(dose(1).beam));
        fields_prescription = intersect(fieldnames(old(1).prescription),fieldnames(dose(1).prescription));
        
        if numel(old.beam) ~= numel(dose.beam) || numel(old.prescription) ~= numel(dose.prescription)
            good = false;
        end
        
        for bCount = 1:numel(old.beam)
            for fCount = 1:numel(fields_beam)
                if ~isequalwithequalnans(old.beam(bCount).(fields_beam{fCount}),dose.beam(bCount).(fields_beam{fCount}))
                    good = false;
                    break
                end
            end
        end
       
        for pCount = 1:numel(old.prescription)
            for fCount = 1:numel(fields_prescription)
                if ~isequalwithequalnans(old.prescription(pCount).(fields_prescription{fCount}),...
                            dose.prescription(pCount).(fields_prescription{fCount}))
                    good = false;
                    break
                end
            end
        end
        
        if ~good
            disp(['TREX-RT>> Entry ',num2str(entry),': Checking dose...file changed!'])
            
            time = datestr(now,'yyyymmddHHMMSS');
            movefile(fullfile(extractRead.project_patient,extractRead.dose_file),fullfile(extractRead.project_patient,[time,'_',extractRead.dose_file]));
                        
            %Also try to delete the previously converted roi data to force the new
            %roi data to be converted
            %Force this to delete in the event that the ROI depends on the dose
            try
                %This will move all of the roi files with the same internal
                %UID to force recalculation of everything
                roifiles = dir(extractRead.project_patient);
                for i = 1:numel(roifiles)
                    if ~isempty(regexpi(roifiles(i).name,[extractRead.roi_internalUID,'.mat$']))
                        movefile(fullfile(extractRead.project_patient,roifiles(i).name),fullfile(extractRead.project_patient,[time,'_',roifiles(i).name]));
                    end
                end
            catch err
            end
            
            %Also rename any previously calculated mapx stuff
            try
                mapfiles = dir(fullfile(extractRead.project_patient,'mapx'));
                for i = 1:numel(mapfiles)
                    if ~isempty(regexpi(mapfiles(i).name,[extractRead.roi_internalUID,'.mat$']))
                        movefile(fullfile(extractRead.project_patient,'mapx',mapfiles(i).name),fullfile(extractRead.project_patient,'mapx',[time,'_',mapfiles(i).name]));
                    end
                end
            catch err
            end
        end
    end
    
    disp(['TREX-RT>> Entry ',num2str(entry),': Checking dose...DONE'])  
end

%%
clearvars
