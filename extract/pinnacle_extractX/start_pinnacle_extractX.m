function [h] = start_pinnacle_extractX(h)
%%
set(h.push_start,'Enable','off')

h.now = datestr(now,'yyyymmddHHMMSS');
diary(fullfile(h.project_path,'Log',[h.now,'_extractX.xlog']))
%%
extractWrite = [];
num_setup = numel(h.setupRead.project_path);
fields = fieldnames(h.setupRead);
for i = 1:numel(fields)
    extractWrite.(fields{i}) = h.setupRead.(fields{i});
end

s.trex_extractver = cell(num_setup,1);
s.ftp = cell(num_setup,1);
s.validated = false(num_setup,1);
s.dlImage = false(num_setup,1);
s.dlImage_datestr = repmat({'0'},num_setup,1);
s.dlDose = false(num_setup,1);
s.dlDose_datestr = repmat({'0'},num_setup,1);
s.dlROI = false(num_setup,1);
s.dlROI_datestr = repmat({'0'},num_setup,1);
s.convertImage = false(num_setup,1);
s.convertImage_datestr = repmat({'0'},num_setup,1);
s.convertDose = false(num_setup,1);
s.convertDose_datestr = repmat({'0'},num_setup,1);
s.convertROI = false(num_setup,1);
s.convertROI_datestr = repmat({'0'},num_setup,1);
s.project_patient = cell(num_setup,1);
s.project_pinndata = cell(num_setup,1);
s.project_scandata = cell(num_setup,1);
s.project_dosedata = cell(num_setup,1);
s.project_roidata = cell(num_setup,1);
s.image_file = cell(num_setup,1);
s.dose_file = cell(num_setup,1);
s.roi_file = cell(num_setup,1);

new_fields = fieldnames(s);

for i = 1:numel(new_fields)
    extractWrite.(new_fields{i}) = s.(new_fields{i});
end
e_fields = fieldnames(extractWrite);

extractRead = read_extractX(h.project_path);
if isempty(extractRead)
    extractRead = extractWrite;
end
%%
disp('TREX-RT>> Extraction started...')

mainDir = fileparts(which('TREX'));
ver = regexp(mainDir, filesep, 'split');

for entry = 1:num_setup
%%
    %Prep extractRead_entry
    extractRead_entry = [];
      
    ind_image_internalUID = strcmpi(extractRead.image_internalUID,extractWrite.image_internalUID{entry});
   
    ind_dose_internalUID = strcmpi(extractRead.dose_internalUID,extractWrite.dose_internalUID{entry});
    ind_dose_internalUID_empty = cellfun(@isempty,extractRead.dose_internalUID);
    
    ind_roi_internalUID = strcmpi(extractRead.roi_internalUID,extractWrite.roi_internalUID{entry});
    ind_roi_name = strcmpi(extractRead.roi_name,extractWrite.roi_name{entry});
    
    ind = ind_image_internalUID & (ind_dose_internalUID | ind_dose_internalUID_empty) & ind_roi_internalUID & ind_roi_name;  

    if sum(ind) == 1
        for fCount = 1:numel(e_fields)
            if iscell(extractRead.(e_fields{fCount}))
                extractRead_entry.(e_fields{fCount}) = extractRead.(e_fields{fCount}){ind,:};
            else
                extractRead_entry.(e_fields{fCount}) = extractRead.(e_fields{fCount})(ind,:);
            end
        end
    elseif sum(ind) == 0
        for fCount = 1:numel(e_fields)
            extractRead_entry.(e_fields{fCount}) = [];
        end
    else 
        %More than one entry matches...
        error('here')
    end
 
    %Prep extractWrite_entry
    extractWrite_entry = [];
    for fCount = 1:numel(e_fields)
        if iscell(extractWrite.(e_fields{fCount}))
            extractWrite_entry.(e_fields{fCount}) = extractWrite.(e_fields{fCount}){entry,:};
        else
            extractWrite_entry.(e_fields{fCount}) = extractWrite.(e_fields{fCount})(entry,:);
        end
    end
%%
    set(h.text_wait2,'String',['Extracting entry ',num2str(entry),'...'])
    
    drawnow; pause(0.001);

    extractWrite_entry.trex_extractver = ver{end};
%%   
    if extractWrite_entry.pinnacle

        extractWrite_entry = validate_pinnacle_extractX(extractWrite_entry,entry);

        if extractWrite_entry.validated
            extractWrite_entry = imageDownload_pinnacle_extractX(extractWrite_entry,extractRead_entry,entry);
            extractWrite_entry = doseDownload_pinnacle_extractX(extractWrite_entry,extractRead_entry,entry);
            extractWrite_entry = roiDownload_pinnacle_extractX(extractWrite_entry,extractRead_entry,entry);

            if ~isempty(extractRead_entry.project_patient)
                doseCheck_pinnacle_extractX(extractRead_entry,entry)
                roiCheck_pinnacle_extractX(extractRead_entry,entry)
            end
            
            extractWrite_entry = imageConvert_pinnacle_extractX(extractWrite_entry,extractRead_entry,entry);
            extractWrite_entry = doseConvert_pinnacle_extractX(extractWrite_entry,extractRead_entry,entry);
            extractWrite_entry = roiConvert_pinnacle_extractX(extractWrite_entry,extractRead_entry,entry);
        end
    end
    
    %Send new entry data back to extractWrite
    for fCount = 1:numel(new_fields)
        if isempty(extractWrite_entry.(new_fields{fCount}))
            
        elseif isnumeric(extractWrite_entry.(new_fields{fCount})) || islogical(extractWrite_entry.(new_fields{fCount}))
            extractWrite.(new_fields{fCount})(entry,:) = extractWrite_entry.(new_fields{fCount});
        elseif ischar((extractWrite_entry.(new_fields{fCount})))
            extractWrite.(new_fields{fCount}){entry} = extractWrite_entry.(new_fields{fCount});
        elseif isobject((extractWrite_entry.(new_fields{fCount})))
            extractWrite.(new_fields{fCount}){entry} = {extractWrite_entry.(new_fields{fCount})};
        else
            error('here')
        end
    end

    progress = entry/num_setup;

    drawnow; pause(0.001);
    
    set(h.patch_wait,'XData',[0 0 progress progress])
    set(h.text_wait,'String',sprintf('%.0f%%',progress*100))
end

disp('TREX-RT>> Extraction complete!')
set(h.text_wait2,'String','Extraction complete!')

filename = [h.now,'_extractX.mat'];
save(fullfile(h.project_path,'Log',filename),'-struct','extractWrite')

disp(['TREX-RT>> extractX.mat copied to project log directory: ',filename]);

diary off
disp(['TREX-RT>> Log file: ',h.now,'_extractX.xlog'])

%%
clearvars -except h hObject
