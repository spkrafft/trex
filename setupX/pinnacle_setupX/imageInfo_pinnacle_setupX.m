function [h] = imageInfo_pinnacle_setupX(h)
%%
if h.export.remote
    cd(h.ftp,h.export.patient_path);
    imageHeaderPath = mget(h.ftp,[h.export.image_name,'.header'],h.export.project_path);
    imageHeaderPath = imageHeaderPath{1};
    
    imageInfoPath = mget(h.ftp,[h.export.image_name,'.ImageInfo'],h.export.project_path);
    imageInfoPath = imageInfoPath{1};    

    cd(h.ftp,h.export.plan_path);
    planPinnaclePath = mget(h.ftp,'plan.Pinnacle',h.export.project_path);
    planPinnaclePath = planPinnaclePath{1};

    cd(h.ftp,h.export.home_path);
else
    copyfile(fullfile(h.export.patient_path,[h.export.image_name,'.header']),h.export.project_path)
    imageHeaderPath = fullfile(h.export.project_path,[h.export.image_name,'.header']);
    
    copyfile(fullfile(h.export.patient_path,[h.export.image_name,'.ImageInfo']),h.export.project_path)
    imageInfoPath = fullfile(h.export.project_path,[h.export.image_name,'.ImageInfo']);
    
    copyfile(fullfile(h.export.plan_path,'plan.Pinnacle'),h.export.project_path)
    planPinnaclePath = fullfile(h.export.project_path,'plan.Pinnacle');
end

fid = fopen(imageHeaderPath);
imageHeader = textscan(fid,'%s','delimiter','\n');
imageHeader = imageHeader{1};
fclose(fid);
delete(imageHeaderPath)

fid = fopen(imageInfoPath);
imageInfo = textscan(fid,'%s','delimiter','\n');
imageInfo = imageInfo{1};
fclose(fid);
delete(imageInfoPath)

fid = fopen(planPinnaclePath);
planPinnacle = textscan(fid,'%s','delimiter','\n');
planPinnacle = planPinnacle{1};
fclose(fid);
delete(planPinnaclePath)

imageInfo = splitParserX(imageInfo,'ImageInfo ={');

h.export.image_seriesUID = textParserX(imageInfo{1},'SeriesUID ');
h.export.image_studyinstanceUID = textParserX(imageInfo{1},'StudyInstanceUID ');
h.export.image_frameUID = textParserX(imageInfo{1},'FrameUID ');
h.export.image_classUID = textParserX(imageInfo{1},'ClassUID ');

h.export.image_xdim = str2double(textParserX(imageHeader,'x_dim '));
h.export.image_ydim = str2double(textParserX(imageHeader,'y_dim '));
h.export.image_zdim = str2double(textParserX(imageHeader,'z_dim '));

h.export.image_bitpix = str2double(textParserX(imageHeader,'bitpix '));
h.export.image_byteorder = logical(str2double(textParserX(imageHeader,'byte_order ')));

h.export.image_xpixdim = str2double(textParserX(imageHeader,'x_pixdim '));
h.export.image_ypixdim = str2double(textParserX(imageHeader,'y_pixdim '));
h.export.image_zpixdim = str2double(textParserX(imageHeader,'z_pixdim '));

h.export.image_startwithdicom = str2double(textParserX(planPinnacle,'StartWithDICOM '));

if h.export.image_startwithdicom == 0 || isnan(h.export.image_startwithdicom) || isempty(h.export.image_startwithdicom)
    h.export.image_xstart = str2double(textParserX(imageHeader,'x_start '));
    h.export.image_ystart = str2double(textParserX(imageHeader,'y_start '));

elseif h.export.image_startwithdicom == 1
    h.export.image_xstart = str2double(textParserX(imageHeader,'x_start_dicom '));
    h.export.image_ystart = str2double(textParserX(imageHeader,'y_start_dicom '));
    
else
    error('huh?')
end

h.export.image_zstart = str2double(textParserX(imageHeader,'z_start '));

h.export.image_patientname = textParserX(imageHeader,'db_name ');
h.export.image_date = textParserX(imageHeader,'date ');
h.export.image_seriesdatetime = textParserX(imageHeader,'SeriesDateTime ');
h.export.image_scannerid = textParserX(imageHeader,'scanner_id ');
h.export.image_patientpos = textParserX(imageHeader,'patient_position ');
h.export.image_manufacturer = textParserX(imageHeader,'manufacturer ');
h.export.image_model = textParserX(imageHeader,'model ');

h.export.image_studyid = textParserX(imageHeader,'study_id ');
h.export.image_examid = textParserX(imageHeader,'exam_id ');
h.export.image_patientid = textParserX(imageHeader,'patient_id ');
h.export.image_modality = textParserX(imageHeader,'modality ');
h.export.image_seriesdesc = textParserX(imageHeader,'Series_Description ');
h.export.image_scanoptions = textParserX(imageHeader,'Scan_Options ');
h.export.image_kvp = textParserX(imageHeader,'KVP ');

h.img.array_xV = h.export.image_xstart : h.export.image_xpixdim : h.export.image_xstart + (h.export.image_xdim-1)*h.export.image_xpixdim;
h.img.array_yV = fliplr(h.export.image_ystart : h.export.image_ypixdim : h.export.image_ystart + (h.export.image_ydim-1)*h.export.image_ypixdim);

h.img.array_zV = zeros(numel(imageInfo),1);
for i = 1:numel(imageInfo)
    h.img.array_zV(i,1) = str2double(textParserX(imageInfo{i},'TablePosition = '));
end

clear imageHeader
clear imageInfo
clear planPinnacle

%%
clearvars -except h
