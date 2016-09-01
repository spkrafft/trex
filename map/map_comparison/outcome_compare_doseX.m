function [out,ccc,spear] = outcome_compare_doseX(project_path,patient_mrn,outcome)

%%
[extractRead] = read_extractX(project_path,false);

fields = fieldnames(extractRead);

%%
%Patient mrns to keep
[~,ind_keep] = intersect(extractRead.patient_mrn, patient_mrn);
for fCount = 1:numel(fields)
    extractRead.(fields{fCount}) = extractRead.(fields{fCount})(ind_keep,:);
end

% isequal(doseRead.patient_mrn,patient.mrn)

%%
out.all = [];
mask_all = [];

for entry = 1:numel(extractRead.patient_mrn)
    filepath = fullfile(extractRead.project_patient{entry}, extractRead.dose_file{entry});
    dose = load(filepath,'array');
    out.all(:,end+1) = dose.array(:);  

    filepath = fullfile(extractRead.project_patient{entry}, extractRead.roi_file{entry});
    mask = load(filepath,'mask');
    mask_all(:,end+1) = mask.mask(:);
end

%%
mask_all = double(mask_all);
mask_all(mask_all == 0) = nan;
out.all = out.all.*mask_all;

%%
%Require at least 75% of patients to have a non-nan value
out.all(sum(isnan(out.all),2)/size(out.all,2) >= 0.75, :) = nan;

%%
out.all_true = out.all(:, outcome);
out.all_false = out.all(:, ~outcome);

%MEAN
% out.true = nanmean(out.all_true,2);
% out.false = nanmean(out.all_false,2);

%MEDIAN
out.true = nanmedian(out.all_true,2);
out.false = nanmedian(out.all_false,2);

out.true = reshape(out.true,extractRead.image_ydim(1),extractRead.image_xdim(1),extractRead.image_zdim(1));
out.false = reshape(out.false,extractRead.image_ydim(1),extractRead.image_xdim(1),extractRead.image_zdim(1));
out.diff = out.true - out.false;

%%
out.spearman = [];
for i = 1:size(out.all,1)
    out.spearman(i,1) = corr(out.all(i,:)',outcome,'type','Spearman','rows','complete');
    [~,out.ttest(i,1)] = ttest2(out.all(i,outcome)',out.all(i,~outcome)');
end

out.spearman = reshape(out.spearman,extractRead.image_ydim(1),extractRead.image_xdim(1),extractRead.image_zdim(1));
out.ttest = reshape(out.ttest,extractRead.image_ydim(1),extractRead.image_xdim(1),extractRead.image_zdim(1));

%%
ccc = ccc_mapX(out.true,out.false);
spear = spearman_mapX(out.true,out.false);

%%
clearvars -except out ccc spear
