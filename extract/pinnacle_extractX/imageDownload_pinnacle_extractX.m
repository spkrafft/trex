function [extractWrite] = imageDownload_pinnacle_extractX(extractWrite,extractRead,entry)
%%
extractWrite.project_patient = fullfile(extractWrite.project_path,num2str(extractWrite.patient_mrn));
extractWrite.project_pinndata = fullfile(extractWrite.project_patient,'Pinnacle Data');
extractWrite.project_scandata = fullfile(extractWrite.project_pinndata,['CT.',extractWrite.image_internalUID]);
extractWrite.image_file = ['CT.',extractWrite.image_internalUID,'.mat'];

%Check for the necessary folders
[s,mess,messid] = mkdir(extractWrite.project_path,num2str(extractWrite.patient_mrn));
disp(['TREX-RT>> Entry ',num2str(entry),': Patient directory ',extractWrite.project_patient]);

[s,mess,messid] = mkdir(extractWrite.project_patient,'Pinnacle Data');
disp(['TREX-RT>> Entry ',num2str(entry),': Pinnacle data directory ',extractWrite.project_pinndata]);

[s,mess,messid] = mkdir(extractWrite.project_pinndata,['CT.',extractWrite.image_internalUID]);
disp(['TREX-RT>> Entry ',num2str(entry),': Scan data directory ',extractWrite.project_scandata]);

%Check for the image files
files = dir(extractWrite.project_scandata);

found = false;
for i = 1:numel(files)
    if ~isempty(regexpi(files(i).name,[extractWrite.image_name,'\w*']))
        found = true;
        break
    end
end

%Download/copy if it doesn't exist
if ~found
    if extractWrite.remote
        extractWrite.ftp = ftp(extractWrite.server_name,extractWrite.server_user,extractWrite.server_pass);                
        cd(extractWrite.ftp,extractWrite.patient_path);

        mget(extractWrite.ftp,[extractWrite.image_name,'.header'],extractWrite.project_scandata);
        mget(extractWrite.ftp,[extractWrite.image_name,'.ImageInfo'],extractWrite.project_scandata);
        mget(extractWrite.ftp,[extractWrite.image_name,'.ImageSet'],extractWrite.project_scandata);
        mget(extractWrite.ftp,[extractWrite.image_name,'.img'],extractWrite.project_scandata);

        DICOMlist = dir(extractWrite.ftp,extractWrite.patient_path);

        for i = 1:numel(DICOMlist)
            if strcmpi(DICOMlist(i).name,[extractWrite.image_name,'.DICOM']) && DICOMlist(i).isdir
                mget(extractWrite.ftp,[extractWrite.image_name,'.DICOM'],extractWrite.project_scandata);
                break
            end
        end

        close(extractWrite.ftp);
    else
        copyfile(fullfile(extractWrite.patient_path,[extractWrite.image_name,'.header']),extractWrite.project_scandata);
        copyfile(fullfile(extractWrite.patient_path,[extractWrite.image_name,'.ImageInfo']),extractWrite.project_scandata);
        copyfile(fullfile(extractWrite.patient_path,[extractWrite.image_name,'.ImageSet']),extractWrite.project_scandata);
        copyfile(fullfile(extractWrite.patient_path,[extractWrite.image_name,'.img']),extractWrite.project_scandata);

        DICOMlist = dir(extractWrite.patient_path);

        for i = 1:numel(DICOMlist)
            if strcmpi(DICOMlist(i).name,[extractWrite.image_name,'.DICOM']) && DICOMlist(i).isdir
                copyfile(fullfile(extractWrite.patient_path,[extractWrite.image_name,'.DICOM']),fullfile(extractWrite.project_scandata,[extractWrite.image_name,'.DICOM']));
                break
            end
        end
    end

    extractWrite.dlImage = true;
    extractWrite.dlImage_datestr = datestr(now,'yyyymmddHHMMSS');
    disp(['TREX-RT>> Entry ',num2str(entry),': Image data downloaded/copied to ',extractWrite.project_scandata]);
else
    extractWrite.dlImage = true;
    extractWrite.dlImage_datestr = extractRead.dlImage_datestr;
end
      
%%
clearvars -except extractWrite
