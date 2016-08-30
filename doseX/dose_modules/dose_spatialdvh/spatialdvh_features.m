function [stats,doseBins,volHist,cumVolHist] = spatialdvh_features(varargin)
%SPATIALDVH_FEATURES Calculate the dose distribution features
%   [STATS] = SPATIALDVH_FEATURES(MASK,DOSE,VOL_VOX,BIN_SIZE)
%
%   Parameters include:
%  
%   'mask'      	
%
%   'dose'          Assumed to be in cGy 
%
%   'vol_vox'       
%
%   'bin_size' 
%
%   Notes
%   -----  
%
%   References
%   ----------
%
%   $SPK

%%
[mask,dose,vol_vox,bin_size] = ParseInputs(varargin{:});

%%
dose = dose(mask);

[doseBins,volHist] = diff_dvh(dose,vol_vox,bin_size);
[doseBins,cumVolHist] = cumul_dvh(doseBins,volHist);

volume = sum(mask)*vol_vox;

%Hist statistics
stats.Sum = sum(dose);
stats.Mean = mean(dose);
stats.Min = min(dose);
stats.Max = max(dose);
stats.Variance = var(dose);
stats.Skewness = skewness(dose);
stats.Kurtosis = kurtosis(dose);
stats.Range = range(dose);
stats.MeanAbsDeviation = mad(dose,0);
stats.MedianAbsDeviation = mad(dose,1);
stats.InterQuartileRange = iqr(dose);
stats.Energy = sum(dose.^2);
stats.RMS = sqrt(stats.Energy/numel(dose));

%% Relative V5-100
for i = 5:5:100
    ind = find(doseBins >= i*100,1);
    if isempty(ind)
        stats.(strcat('rV',num2str(i))) = 0;
    else
        stats.(strcat('rV',num2str(i))) = cumVolHist(ind)/volume;
    end
end

%% Absolute V5-100
for i = 5:5:100
    ind = find(doseBins >= i*100,1);
    if isempty(ind)
        stats.(strcat('aV',num2str(i))) = 0;
    else
        stats.(strcat('aV',num2str(i))) = cumVolHist(ind);
    end
end

%% Relative VS5-100
% for i = 5:5:100
%     ind = find(doseBins >= i*100,1);
%     if isempty(ind)
%         stats.(strcat('rVS',num2str(i))) = 1;
%     else
%         stats.(strcat('rVS',num2str(i))) = 1 - cumVolHist(ind)/volume;
%     end
% end

%% Absolute VS5-100
% for i = 5:5:100
%     ind = find(doseBins >= i*100,1);
%     if isempty(ind)
%         stats.(strcat('aVS',num2str(i))) = 1;
%     else
%         stats.(strcat('aVS',num2str(i))) = volume - cumVolHist(ind);
%     end
% end

%% Relative D5-100
for i = 5:5:100
    ind = find(cumVolHist/volume < i/100,1);
    if isempty(ind)
        stats.(strcat('rD',num2str(i))) = 0;
    else
        stats.(strcat('rD',num2str(i))) = doseBins(ind);
    end
end

%% MOC5-100
for i = 5:5:100
    ind = find(cumVolHist/volume >= (100-i)/100);
    if isempty(ind)
        stats.(strcat('moc',num2str(i))) = 0;
    else
        stats.(strcat('moc',num2str(i))) = sum(doseBins(ind).*volHist(ind))/sum(volHist(ind));
    end
end

%% MOH5-100
for i = 5:5:100
    ind = find(cumVolHist/volume <= i/100);
    if isempty(ind)
        stats.(strcat('moh',num2str(i))) = 0;
    else
        stats.(strcat('moh',num2str(i))) = sum(doseBins(ind).*volHist(ind))/sum(volHist(ind));
    end
end

%% EUD
% n1 = 0.15:0.05:1;
% n2 = fliplr(1./n1);
% exponentn = [n1,n2(2:end)];
% 
% for i = 1:length(exponentn)
%     n = exponentn(i) + eps;
%     name = num2str(exponentn(i));
%     name(name == '.') = '_';
%     name = strcat('eudn',name);
%     stats.(name) = sum((doseBins.^(1/n)).*(volHist./volume))^(n);
%     clear name n
% end

%%
clearvars -except stats doseBins volHist cumVolHist

%--------------------------------------------------------------------------
function [doseBins,volHist] = diff_dvh(dose,vol_vox,bin_size)
%%
%Upper boundary of the dose bin
binUpper = 0:bin_size:(max(dose)+bin_size);

%Defines the center of the dose bin
doseBins = binUpper+bin_size/2;

volHist = histc(dose,binUpper);
volHist = volHist*vol_vox;

if iscolumn(doseBins)
    doseBins = doseBins';
end

if iscolumn(volHist)
    volHist = volHist';
end

%%
clearvars -except doseBins volHist

%--------------------------------------------------------------------------
function [doseBins,cumVolHist] = cumul_dvh(doseBins,volHist)
%%
cumVols = cumsum(volHist);
cumVolHist  = cumVols(end) - cumVols;

if iscolumn(cumVolHist)
    cumVolHist = cumVolHist';
end

%%
clearvars -except doseBins cumVolHist

%--------------------------------------------------------------------------
function [mask,dose,vol_vox,bin_size] = ParseInputs(varargin)

if verLessThan('matlab','7.13')
    iptchecknargin(1,4,nargin,mfilename);
else
    narginchk(1,4);
end

% Check mask
mask = varargin{1};
validateattributes(mask,{'numeric','logical'},{'real','nonsparse'},mfilename,'MASK',1);

% Assign Defaults
dose = ones(size(mask));
vol_vox = 1;
bin_size = 1;

% Parse Input Arguments
if nargin ~= 1
    dose = varargin{2};
    validateattributes(dose,{'numeric'},{'real','nonsparse','size',size(mask)},mfilename,'DOSE',2);
        
    vol_vox = varargin{3};
    validateattributes(vol_vox,{'numeric'},{'real','nonsparse','scalar'},mfilename,'VOL_VOX',3);
    
    bin_size = varargin{4};
    validateattributes(bin_size,{'numeric'},{'real','nonsparse','scalar'},mfilename,'BIN_SIZE',4);
end

%If any of the input variables are arrays a opposed to vectors, convert
%them to vectors
if ~isvector(mask)
    mask = mask(:);
end

if ~isvector(dose)
    dose = dose(:);
end

%%
clearvars -except mask dose vol_vox bin_size
