function [extractWrite] = doseConvert_pinnacle_extractX(extractWrite,extractRead,entry)
%%
if strcmpi(extractWrite.dose_name,'') || isempty(extractWrite.dose_name)
    
else
    %Look for the converted image
    files = dir(extractWrite.project_patient);

    found = false;
    for i = 1:numel(files)
        if strcmpi(files(i).name,extractWrite.dose_file)
            found = true;
            break
        end
    end

    %If not found, then convert it...
    if ~found
        disp(['TREX-RT>> Entry ',num2str(entry),': Reading dose data...'])       

        dose = doseInfo_pinnacle_extractX(extractWrite);
        dose = doseMachineInfo_pinnacle_extractX(extractWrite,dose);
        dose = doseRead_pinnacle_extractX(extractWrite,dose);
        dose = doseInterp_pinnacle_extractX(extractWrite,entry,dose);

        extractWrite.convertDose = true;
        extractWrite.convertDose_datestr = datestr(now,'yyyymmddHHMMSS');
        
        save(fullfile(extractWrite.project_patient,extractWrite.dose_file),'-struct','dose')
        save(fullfile(extractWrite.project_patient,extractWrite.dose_file),'-struct','extractWrite','-append')

        disp(['TREX-RT>> Entry ',num2str(entry),': Dose data saved ',extractWrite.dose_file])
    else
        extractWrite.convertDose = true;
        extractWrite.convertDose_datestr = extractRead.convertDose_datestr;
    end
end

%%
clearvars -except extractWrite
