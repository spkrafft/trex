function [stats] = laws2D_features(varargin)
%LAWS2D_FEATURES 
%   [STATS] = LAWS2D_FEATURES(IMG,MASK)
%
%   Parameters include:
%  
%   'img'       Self explanatory
%
%   'mask'      (Optional) Self explanatory
%
%   Notes
%   -----
%   Not explicitly forcing histogram equalization as Laws originally
%   proposed. Could apply this beforehand if desired, but seems unnecessary
%   when working with CT datasets acquired and reconstructed under similar
%   conditions.
%   Also did not apply an additional neighborhood "texture energy" filter
%   as seems to be suggested in the original text. Output is just the
%   filtered image.
%
%   References
%   ----------
%   [1] Laws, Kenneth I. Textured image segmentation. No. USCIPI-940. University of Southern California Los Angeles Image Processing INST, 1980.
%
%   $SPK

%%
[img,mask] = ParseInputs(varargin{:});

%%
stats = [];

lf.L5 = [1 4 6 4 1];
lf.E5 = [-1 -2 0 2 1];
lf.S5 = [-1 0 2 0 -1];
lf.W5 = [-1 2 0 -2 1];
lf.R5 = [1 -4 6 -4 1];

filters = fieldnames(lf);

for i = 1:numel(filters)
    for j = i:numel(filters)
        
        filter_name = [filters{i},filters{j}];
        
        f = lf.(filters{i})'*lf.(filters{j});
        g = lf.(filters{j})'*lf.(filters{i}); 
        
        J1 = imfilter(img,f,'conv');
        J2 = imfilter(img,g,'conv');

        J = (J1+J2)/2;
        J(mask==0) = nan;

        stats_current = calc_features(J);
        
        sNames = fieldnames(stats_current);
        
        for sCount = 1:numel(sNames)
            stats.([filter_name,'_',sNames{sCount}]) = stats_current.(sNames{sCount});
        end
    end
end

%%
clearvars -except stats

%--------------------------------------------------------------------------
function [stats] = calc_features(I)
%% Vectorize I and remove all NaNs, which are outside the region of interest
I = I(:);
I(isnan(I)) = [];

stats.Mean = mean(I);
stats.Variance = var(I);
stats.Skewness = skewness(I);
stats.Kurtosis = kurtosis(I);
[stats.Entropy, stats.Uniformity] = entropyanduniformity(I);
stats.Energy = sum(I(:).^2);
stats.RMS = sqrt(stats.Energy/numel(I));

%%
clearvars -except stats

%--------------------------------------------------------------------------
function [entropy, uniformity] = entropyanduniformity(I)
%% Change the image bit depth to 8 to be consistent with MATLAB built-in function
nl = 256;
gl = [0, 4095];
slope = nl/(gl(2)-gl(1));
intercept = 1-(slope*(gl(1)));
I = floor(imlincomb(slope,I,intercept,'double'));
I(I > nl) = nl;
I(I < 1) = 1;
I = I-1;
I = uint8(I);

% calculate histogram counts
p = imhist(I(:));

% remove zero entries in p 
p(p==0) = [];

% normalize p so that sum(p) is one.
p = p./numel(I);

entropy = -sum(p.*log2(p));

uniformity = sum(p.*p);

%%
clearvars -except entropy uniformity

%--------------------------------------------------------------------------
function [img,mask] = ParseInputs(varargin)

if verLessThan('matlab','7.13')
    iptchecknargin(1,2,nargin,mfilename);
else
    narginchk(1,2);
end

% Check img
img = varargin{1};
validateattributes(img,{'numeric'},{'real','nonsparse'},mfilename,'IMG',1);
if ndims(img) > 3
  error(message('images:laws2D_features:invalidSizeForIMG'))
end

% Assign Defaults
mask = true(size(img));

% Parse Input Arguments
if nargin ~= 1
    mask = varargin{2};
    validateattributes(mask,{'logical'},{'real','nonsparse','size',size(mask)},mfilename,'MASK',2);
end

%%
clearvars -except img mask
