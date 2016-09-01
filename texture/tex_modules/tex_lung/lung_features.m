function [stats] = lung_features(varargin)
%LUNG_FEATURES Compute lung specific features
%   [STATS] = LUNG_FEATURES(I,SIZ_VOX)
%
%   Parameters include:
%  
%   'I'         Self explanatory
%
%   'siz_vox'   (Optional) Size of voxel dimensions [x, y, z] in mm
%
%   Notes
%   -----
%   
%   References
%   ----------
%   [1] Xu, Ye, et al. "Sensitivity and specificity of 3-D texture analysis of lung parenchyma is better than 2-D for discrimination of lung pathology in stage 0 COPD." Medical Imaging. International Society for Optics and Photonics, 2005.
%   [2] Yuan, Ren, et al. "Quantification of lung surface area using computed tomography." Respiratory research 11.1 (2010): 153.
%   [3] Muller, N. L. "" Density mask". An objective method to quantitate emphysema using computed tomography." Chest 94 (1988): 782-787.
%   [4] Gierada, David S., et al. "Patient selection for lung volume reduction surgery: an objective model based on prior clinical decisions and quantitative CT analysis." CHEST Journal 117.4 (2000): 991-998.
%   [5] Hayhurst, M. D., et al. "Diagnosis of pulmonary emphysema by computerised tomography." The Lancet 324.8398 (1984): 320-322.
%   [6] Coxson, Harvey O., et al. "A quantification of the lung surface area in emphysema using computed tomography." American journal of respiratory and critical care medicine 159.3 (1999): 851-856.
%   [7] Mishima, Michiaki, et al. "Complexity of terminal airspace geometry assessed by lung computed tomography in normal subjects and patients with chronic obstructive pulmonary disease." Proceedings of the National Academy of Sciences 96.16 (1999): 8829-8834.
%   [8] Coxson, H. O., et al. "Selection of patients for lung volume reduction surgery using a power law analysis of the computed tomographic scan." Thorax 58.6 (2003): 510-514.
% 
%   $SPK

%%
[I,siz_vox,dummy] = ParseInputs(varargin{:});

%%
vol_vox = siz_vox(1)*siz_vox(2)*siz_vox(3);

volume = sum(~isnan(I(:)))*vol_vox;

I = I-1000; %Should convert voxel values to actual HU, zero is then water, -1000 air.

% Mode [1]
stats.Mode = mode(I(:));

% Boundary between normal and mildy emphysematous [2]
stats.LAA856 = sum(I(:) < -856)*vol_vox;
stats.LAA856Per = stats.LAA856/volume;

% Threshold of normal [1]
stats.LAA864 = sum(I(:) < -864)*vol_vox;
stats.LAA864Per = stats.LAA864/volume;

% Threshold of emphysema [4]
stats.LAA900 = sum(I(:) < -900)*vol_vox; 
stats.LAA900Per = stats.LAA900/volume;

% Threshold of emphysema [1,3,6]
stats.LAA910 = sum(I(:) < -910)*vol_vox; 
stats.LAA910Per = stats.LAA910/volume;

% Severe emphysema [4,7]
stats.LAA960 = sum(I(:) < -960)*vol_vox;
stats.LAA960Per = stats.LAA960/volume;

%Reserve/Normal lung tissue [4]
stats.Reserve = sum(I(:) > -850 & I(:) < -701)*vol_vox;
stats.ReservePer = stats.Reserve/volume;

%Upper/Lower/Ratio Emphysema [4]
upper = 1:ceil(size(I,3)/2);
lower = (ceil(size(I,3)/2)+1):size(I,3);

I_upper = I(:,:,upper);
I_lower = I(:,:,lower);
 
stats.Upper960 = sum(I_upper(:) < -960)*vol_vox;
stats.Upper960Per = stats.Upper960/sum(~isnan(I_upper(:)));

stats.Lower960 = sum(I_lower(:) < -960)*vol_vox;
stats.Lower960Per = stats.Lower960/sum(~isnan(I_lower(:)));

stats.Upper960Lower960 = stats.Upper960Per/stats.Lower960Per;
if isinf(stats.Upper960Lower960) || isnan(stats.Upper960Lower960)
    stats.Upper960Lower960 = 0;
end

%% Cluster stuff [ref 7 -> -960, ref 8 -> -910]

stats.Number910 = 0;
stats.MeanVol910 = 0;
stats.StdVol910 = 0;
stats.D910 = 0;
stats.K910 = 0;

stats.Number960 = 0;
stats.MeanVol960 = 0;
stats.StdVol960 = 0;
stats.D960 = 0;
stats.K960 = 0;

if ~dummy
    %ref 8 -> -910
    mask910  = I < -910;
    if sum(mask910(:)) > 0
        s = regionprops(mask910,'area');

        vol = nan(size(s));
        for i = 1:numel(s)
            vol(i) = s(i).Area*vol_vox;
        end

        stats.Number910 = numel(s);
        stats.MeanVol910 = mean(vol);
        stats.StdVol910 = std(vol);

        [f,les_size] = ecdf(vol);
        cum_num_les = round((1-f)*numel(vol));

        %logY = LogK - D*logA
        A = log10(les_size(1:end-1));
        Y = log10(cum_num_les(1:end-1));
        [p,~,mu] = polyfit(A,Y,1); %scale to avoid badly conditioned
        if ~isnan(p(1))
            f = polyval(p,A,[],mu);
            p = polyfit(A,f,1);
        end
        stats.D910 = p(1);
        stats.K910 = p(2);
    end

    %ref 7 -> -960,
    mask960  = I < -960;
    if sum(mask960(:)) > 0
        s = regionprops(mask960,'area');

        vol = nan(size(s));
        for i = 1:numel(s)
            vol(i) = s(i).Area*vol_vox;
        end

        stats.Number960 = numel(s);
        stats.MeanVol960 = mean(vol);
        stats.StdVol960 = std(vol);

        [f,les_size] = ecdf(vol);
        cum_num_les = round((1-f)*numel(vol));

        %logY = LogK - D*logA
        A = log10(les_size(1:end-1));
        Y = log10(cum_num_les(1:end-1));
        [p,~,mu] = polyfit(A,Y,1); %scale to avoid badly conditioned
        if ~isnan(p(1))
            f = polyval(p,A,[],mu);
            p = polyfit(A,f,1);
        end
        stats.D960 = p(1);
        stats.K960 = p(2);
    end
end

%%
clearvars -except stats

%--------------------------------------------------------------------------
function [I,siz_vox,dummy] = ParseInputs(varargin)

if verLessThan('matlab','7.13')
    iptchecknargin(1,2,nargin,mfilename);
else
    narginchk(1,2);
end

dummy = false;

% Check scanArray
I = varargin{1};
validateattributes(I,{'numeric'},{'real','nonsparse'},mfilename,'I',1);
if ndims(I) > 3
  error(message('images:lung_features:invalidSizeForI'))
end

if isscalar(I)
    I = padarray(I,[1 1 1]);
    dummy = true;
end

% Assign Defaults
siz_vox = ones(size(I));

% Parse Input Arguments
if nargin ~= 1
    siz_vox = varargin{2};
    validateattributes(siz_vox,{'numeric'},{'real','nonsparse','vector','size',[1,3]},mfilename,'SIZ_VOX',2);
end

%%
clearvars -except I siz_vox dummy
