function [stats] = hist_features(I)
%HIST_FEATURES Compute all of the interested first order (descriptive)
%   statistics.
%   [STATS] = HIST_FEATURES(I) calculates all of the interested first
%   order statistics including histogram measures, entropy, energy
%
%   Parameters include:
%  
%   'I'         Self explanatory
%
%   Notes
%   -----
% 
%   $SPK

%%
[I] = ParseInputs(I);

%% Vectorize I and remove all NaNs, which are outside the region of interest
I = I(:);
I(isnan(I)) = [];

stats.Sum = sum(I);
stats.Mean = mean(I);
stats.Min = min(I);
stats.Max = max(I);
stats.Variance = var(I);
stats.Skewness = skewness(I);
stats.Kurtosis = kurtosis(I);
stats.Range = range(I);
stats.MeanAbsDeviation = mad(I,0);
stats.MedianAbsDeviation = mad(I,1);
stats.InterQuartileRange = iqr(I);
stats.Per01 = prctile(I,1);
stats.Per10 = prctile(I,10);
stats.Per25 = prctile(I,25);
stats.Per50 = prctile(I,50);
stats.Per75 = prctile(I,75);
stats.Per90 = prctile(I,90);
stats.Per95 = prctile(I,95);
stats.Per99 = prctile(I,99);
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
function [I] = ParseInputs(varargin)

if verLessThan('matlab','7.13')
    iptchecknargin(1,1,nargin,mfilename);
else
    narginchk(1,1);
end

% Check I
I = varargin{1};
validateattributes(I,{'numeric'},{'real','nonsparse'},mfilename,'I',1);
if ndims(I) > 3
  error(message('images:histogram_features:invalidSizeForI'))
end

%%
clearvars -except I
