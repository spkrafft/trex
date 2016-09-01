function [extractWrite] = roiConvert_pinnacle_extractX(extractWrite,extractRead,entry)
%%
%Look for the converted roi file
files = dir(extractWrite.project_patient);

found = false;
for i = 1:numel(files)
    if strcmpi(files(i).name,extractWrite.roi_file)
        found = true;
        break
    end
end

%If not found, then convert it...
if ~found
    disp(['TREX-RT>> Entry ',num2str(entry),': Reading ROI data...'])    
    
    roi = roi2Mask_pinnacle_extractX(extractWrite,entry);
    
    extractWrite.convertROI = true;
    extractWrite.convertROI_datestr = datestr(now,'yyyymmddHHMMSS');
            
    save(fullfile(extractWrite.project_patient,extractWrite.roi_file),'-struct','roi')
    save(fullfile(extractWrite.project_patient,extractWrite.roi_file),'-struct','extractWrite','-append')

    disp(['TREX-RT>> Entry ',num2str(entry),': ROI mask saved ',extractWrite.roi_file])
else
    extractWrite.convertROI = true;
    extractWrite.convertROI_datestr = extractRead.convertROI_datestr;    
end

%%
clearvars -except extractWrite
