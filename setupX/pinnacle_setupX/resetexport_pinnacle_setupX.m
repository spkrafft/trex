function [h] = resetexport_pinnacle_setupX(h,field)
%%
names = fieldnames(h);

if strcmpi(field,'project')
    h.project_path = [];
elseif strcmpi(field,'server')
    h.server_name = [];
    h.server_user = [];
    h.server_pass = [];
    h.remote = [];
    h.pinnacle = [];
elseif strcmpi(field,'home')
    h.home_path = [];
elseif strcmpi(field,'institution')
%     h.institution_path = [];
%     h.institution_dir = [];
%     h.institution_name = [];
%     h.institution_street = [];
%     h.institution_street2 = [];
    
    ind = find(~cellfun(@isempty,regexpi(names,'^institution_')));
    for i = 1:numel(ind)
        h.(names{ind(i)}) = [];
    end
elseif strcmpi(field,'patient')
%     h.patient_path = [];
%     h.patient_dir = [];
%     h.patient_name = [];
%     h.patient_mrn = [];
%     
    ind = find(~cellfun(@isempty,regexpi(names,'^patient_')));
    for i = 1:numel(ind)
        h.(names{ind(i)}) = [];
    end
elseif strcmpi(field,'plan')
%     h.plan_path = [];
%     h.plan_dir = [];
%     h.plan_id = [];
%     h.plan_name = [];
        
    ind = find(~cellfun(@isempty,regexpi(names,'^plan_')));
    for i = 1:numel(ind)
        h.(names{ind(i)}) = [];
    end
elseif strcmpi(field,'image')
%     h.image_id = [];
%     h.image_name = [];
%     h.image_internalUID = [];
%     h.image_seriesUID = [];
%     h.image_studyinstanceUID = [];
%     h.image_frameUID = [];
%     h.image_classUID = [];
%     h.image_startwithdicom = [];
%     h.image_xdim = [];
%     h.image_ydim = [];
%     h.image_zdim = [];
%     h.image_bitpix = [];
%     h.image_byteorder = [];
%     h.image_xpixdim = [];
%     h.image_ypixdim = [];
%     h.image_zpixdim = [];
%     h.image_xstart = [];
%     h.image_ystart = [];
%     h.image_zstart = [];
%     h.image_patientname = [];
%     h.image_date = [];
%     h.image_scannerid = [];
%     h.image_patientpos = [];
%     h.image_manufacturer = [];
%     h.image_model = [];
%     h.image_studyid = [];
%     h.image_examid = [];
%     h.image_patientid = [];
%     h.image_modality = [];
%     h.image_seriesdesc = [];
%     h.image_scanoptions = [];
%     h.image_kvp = [];
%     h.image_dicompath = [];
%     h.image_type = [];
%     h.image_time = [];
%     h.image_insitution = [];
%     h.image_stationname = [];
%     h.image_studydesc = [];
%     h.image_softwarever = [];
%     h.image_protocol = [];
%     h.image_exposuretime = [];
%     h.image_tubecurrent = [];
%     h.image_exposure = [];
%     h.image_filter = [];
%     h.image_focalspot = [];
%     h.image_convolutionkernel = [];
%     h.image_rescaleintercept = [];
%     h.image_rescaleslope = [];

    ind = find(~cellfun(@isempty,regexpi(names,'^image_')));
    for i = 1:numel(ind)
        h.(names{ind(i)}) = [];
    end
    
    ind = find(~cellfun(@isempty,regexpi(names,'^dicom_')));
    for i = 1:numel(ind)
        h.(names{ind(i)}) = [];
    end
elseif strcmpi(field,'roi')
%     h.roi_name = [];
%     h.roi_internalUID = [];
%     h.roi_source = [];
%     h.roi_int = [];
%     h.roi_ext = [];
    
    ind = find(~cellfun(@isempty,regexpi(names,'^roi_')));
    for i = 1:numel(ind)
        h.(names{ind(i)}) = [];
    end
elseif strcmpi(field,'dose')
%     h.dose_name = [];
%     h.dose_internalUID = [];
    
    ind = find(~cellfun(@isempty,regexpi(names,'^dose_')));
    for i = 1:numel(ind)
        h.(names{ind(i)}) = [];
    end
end
