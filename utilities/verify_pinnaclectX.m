function [out] = verify_pinnaclectX(dicom_data,trexproj_dir)

extractRead = read_extractX(trexproj_dir);

% Find the unique scans in the project...
[~,ind] = unique(extractRead.image_seriesUID);
f_names = fieldnames(extractRead);
for i = 1:numel(f_names)
    extractRead.(f_names{i}) = extractRead.(f_names{i})(ind);
end

% out = [];
% out.mrn = nan(numel(extractRead.patient_mrn),1);
% out.uid = cell(numel(extractRead.patient_mrn),1);
% out.median = cell(numel(extractRead.patient_mrn),1);
% out.mean = cell(numel(extractRead.patient_mrn),1);
% out.max = cell(numel(extractRead.patient_mrn),1);

w = waitbar(0,'Verifying Pinnacle CT Number...');

parfor i = 1:numel(extractRead.patient_mrn)
%     waitbar(i/numel(extractRead.patient_mrn),w);
    disp(i)
    pinn = load(fullfile(extractRead.project_patient{i},extractRead.image_file{i}));
    img1 = double(pinn.array);
    
    img2 = readImg_dicomX(dicom_data,pinn.image_seriesUID);
    
    out(i).mrn = extractRead.patient_mrn(i);
    out(i).uid = pinn.image_seriesUID;
   
    if isnan(img2)
        out(i).median = 'no matching dicom';
        out(i).mean = 'no matching dicom';
        out(i).max = 'no matching dicom';
    elseif ~all(size(img1) == size(img2))
        out(i).median = 'dimensions differ';
        out(i).mean = 'dimensions differ';
        out(i).max = 'dimensions differ';
    else
        d = img2 - img1;
        
        out(i).median = median(d(:));
        out(i).mean = mean(d(:));
        out(i).max = max(d(:));
    end
end

close(w)

clearvars -except out
