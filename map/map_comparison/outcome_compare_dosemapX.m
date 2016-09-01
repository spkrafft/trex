function [out,ccc,spear] = outcome_compare_dosemapX(project_path,module,feature,patient_mrn,outcome,varargin)

[block_size,overlap,shift,preprocess,bd,dist,offset] = ParseInputs(varargin{:});

%%
[mapRead] = read_mapX(project_path,module,false);

if isfield(mapRead,'parameter_block_size')
    ind_block_size = strcmpi(mapRead.parameter_block_size,block_size);
else
    ind_block_size = true(size(mapRead.patient_mrn));
end

if isfield(mapRead,'parameter_overlap')
    ind_overlap = strcmpi(mapRead.parameter_overlap,overlap);
else
    ind_overlap = true(size(mapRead.patient_mrn));
end

if isfield(mapRead,'parameter_shift')
    ind_shift = strcmpi(mapRead.parameter_shift,shift);
else
    ind_shift = true(size(mapRead.patient_mrn));
end

if isfield(mapRead,'parameter_preprocess')
    ind_preprocess = strcmpi(mapRead.parameter_preprocess,preprocess);
else
    ind_preprocess = true(size(mapRead.patient_mrn));
end

if isfield(mapRead,'parameter_bd')
    ind_bd = strcmpi(mapRead.parameter_bd,bd);
else
    ind_bd = true(size(mapRead.patient_mrn));
end

if isfield(mapRead,'parameter_dist')
    ind_dist = strcmpi(mapRead.parameter_dist,dist);
else
    ind_dist = true(size(mapRead.patient_mrn));
end

if isfield(mapRead,'parameter_offset')
    ind_offset = strcmpi(mapRead.parameter_offset,offset);
else
    ind_offset = true(size(mapRead.patient_mrn));
end

ind_keep = ind_block_size & ind_overlap & ind_shift & ind_preprocess & ind_bd & ind_dist & ind_offset;

fields = fieldnames(mapRead);
for fCount = 1:numel(fields)
    mapRead.(fields{fCount}) = mapRead.(fields{fCount})(ind_keep,:);
end

%%
%Patient mrns to keep
[~,ind_keep] = intersect(mapRead.patient_mrn, patient_mrn);
for fCount = 1:numel(fields)
    mapRead.(fields{fCount}) = mapRead.(fields{fCount})(ind_keep,:);
end

% isequal(mapRead.patient_mrn,patient.mrn)

%%
out.all = [];
dose_all = [];

for entry = 1:numel(mapRead.patient_mrn)
    filepath = fullfile(mapRead.project_patient{entry}, 'mapx', mapRead.map_file{entry});
    map = load(filepath,feature);
    out.all(:,end+1) = percentile_mapX(map.(feature)); 
    
    filepath = fullfile(mapRead.project_patient{entry}, mapRead.dose_file{entry});
    dose = load(filepath,'array');
    dose_all(:,end+1) = dose.array(:);  
end

%%
out.all = out.all.*dose_all;

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

out.true = reshape(out.true,mapRead.image_ydim(1),mapRead.image_xdim(1),mapRead.image_zdim(1));
out.false = reshape(out.false,mapRead.image_ydim(1),mapRead.image_xdim(1),mapRead.image_zdim(1));
out.diff = out.true - out.false;

%%
out.spearman = [];
out.ttest = [];
for i = 1:size(out.all,1)
    out.spearman(i,1) = corr(out.all(i,:)',outcome,'type','Spearman','rows','complete');
    [~,out.ttest(i,1)] = ttest2(out.all(i,outcome)',out.all(i,~outcome)');
end

out.spearman = reshape(out.spearman,mapRead.image_ydim(1),mapRead.image_xdim(1),mapRead.image_zdim(1));
out.ttest = reshape(out.ttest,mapRead.image_ydim(1),mapRead.image_xdim(1),mapRead.image_zdim(1));

%%
ccc = ccc_mapX(out.true,out.false);
spear = spearman_mapX(out.true,out.false);

%%
clearvars -except out ccc spear

%-----------------------------------------------------------------------------
function [block_size,overlap,shift,preprocess,bd,dist,offset] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(0,14,nargin,mfilename);
else
    narginchk(0,14);
end

%%
block_size = '31';
overlap = '15';
shift = '0';
preprocess = 'None';
bd = '8';
%gl = [0 4095];
dist = '1';
offset = '2D';

%%
%Parse Input Arguments
if nargin > 2
    for k = 3:2:nargin

        param = lower(varargin{k});
        inputStr = validatestring(param, paramStrings, mfilename, 'PARAM', k);
        idx = k + 1;  %Advance index to the VALUE portion of the input.
        if idx > nargin
          error(message('::missingParameterValue', inputStr));        
        end

        switch (inputStr)
            case 'block_size'
                block_size = varargin{idx};
            case 'overlap'
                overlap = varargin{idx};
            case 'shift'
                shift = varargin{idx};
            case 'preprocess'
                preprocess = varargin{idx};
            case 'bd'
                bd = varargin{idx};
            case 'dist'
                dist = varargin{idx};
            case 'offset'
                offset = varargin{idx};
        end
    end
end

%%
clearvars -except block_size overlap shift preprocess bd dist offset
