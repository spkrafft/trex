function [ccc, spear, mapRead] = compare_ctX(varargin)

[project_path,module,block_size,overlap,shift,preprocess,bd,dist,offset] = ParseInputs(varargin{:});

%%
[mapRead] = read_mapX(project_path,module);

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
[mrn,~,group_mrn] = unique(mapRead.patient_mrn);

if numel(mrn) ~= numel(group_mrn)/2
    error('whoops')
end

% ssim = [];
% psnr = [];
ccc = [];
spear = [];

%%
for entry = 1:numel(mrn)
    disp(mrn(entry))
    
    ind = find(group_mrn == entry);
    ind1 = ind(1);
    ind2 = ind(2);
        
        filepath1 = fullfile(mapRead.project_patient{ind1}, 'mapx', mapRead.map_file{ind1});
        map1 = load(filepath1);
        array1 = map1.I;
        mask1 = load(filepath1,'mask');
        mask1 = mask1.mask;
                
        filepath2 = fullfile(mapRead.project_patient{ind2}, 'mapx', mapRead.map_file{ind2});
        map2 = load(filepath2);
        array2 = map2.I;
%         mask2 = load(filepath2,'mask');
%         mask2 = mask2.mask;

        if all(isnan(array1(:))) || all(isnan(array2(:)))
            continue
        end

        array2 = imresize3DX(array2,[mapRead.image_xpixdim(ind2),mapRead.image_ypixdim(ind2),mapRead.image_zpixdim(ind2)],size(array1),'linear');
        %mask2 = imresize3DX(mask2,[mapRead.image_xpixdim(ind2),mapRead.image_ypixdim(ind2),mapRead.image_zpixdim(ind2)],size(array1),'linear');
        
        mask1 = double(mask1);
        mask1(mask1==0) = NaN;
        array2 = mask1.*array2;
        
%         ssim.(stat_names{sCount})(entry,:) = [mrn(entry), ssim_mapX(array1,array2)];
%         psnr.(stat_names{sCount})(entry,:) = [mrn(entry), psnr_mapX(array1,array2)];
        ccc.I(entry,:) = [mrn(entry), ccc_mapX(array1,array2)];
        spear.I(entry,:) = [mrn(entry), spearman_mapX(array1,array2)];
        
        clear array1
        clear array2
        clear mask1
end

clearvars -except ccc spear mapRead

%-----------------------------------------------------------------------------
function [project_path,module,block_size,overlap,shift,preprocess,bd,dist,offset] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(2,4,nargin,mfilename);
else
    narginchk(2,4);
end

%Check project_path
project_path = varargin{1};
validateattributes(project_path,{'char'},{},mfilename,'project_path',1);

module = varargin{2};

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
clearvars -except project_path module block_size overlap shift preprocess bd dist offset
