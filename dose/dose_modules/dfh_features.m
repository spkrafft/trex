function [stats,doseBins,volHist,cumVolHist] = dfh_features(varargin)
%DFH_FEATURES Calculate the dose distribution features
%   [STATS] = DFH_FEATURES(MASK,DOSE,VOL_VOX,BIN_SIZE)
%
%   Parameters include:
%  
%   'mask'      	
%
%   'dose'          Assumed to be in cGy 
%
%   'map'       
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
[mask,dose,map,bin_size] = ParseInputs(varargin{:});

%%
dose = dose(mask);
map = map(mask);

[doseBins,volHist] = diff_dvh(dose,map,bin_size);
[doseBins,cumVolHist] = cumul_dvh(doseBins,volHist);

stats.fVolume = sum(volHist); %sum(map)
stats.fSum = sum(doseBins.*volHist); %sum(dose.*map); 
stats.fMean = stats.fSum/stats.fVolume;

%% Relative V5-100
for i = 5:5:100
    ind = find(doseBins >= i*100,1);
    if isempty(ind)
        stats.(strcat('rV',num2str(i))) = 0;
    else
        stats.(strcat('rV',num2str(i))) = cumVolHist(ind)/stats.fVolume;
    end
end

%% EUD
n1 = 0.15:0.05:1;
n2 = fliplr(1./n1);
exponentn = [n1,n2(2:end)];

for i = 1:length(exponentn)
    n = exponentn(i) + eps;
    name = num2str(exponentn(i));
    name(name == '.') = '_';
    name = strcat('eudn',name);
    stats.(name) = sum((doseBins.^(1/n)).*(volHist./stats.fVolume))^(n);
    clear name n
end

%%
clearvars -except stats doseBins volHist cumVolHist

%--------------------------------------------------------------------------
function [doseBins,volHist] = diff_dvh(dose,map,bin_size)
%%
%Upper boundary of the dose bin
binUpper = 0:bin_size:(max(dose)+bin_size);

%Defines the center of the dose bin
doseBins = binUpper+bin_size/2;

volHist = zeros(numel(binUpper),1);
for i = 1:numel(binUpper)-1
    volHist(i,1) = sum(map(dose >= binUpper(i) & dose < binUpper(i+1)));
end

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
function [mask,dose,map,bin_size] = ParseInputs(varargin)

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
map = ones(size(mask));
bin_size = 1;

% Parse Input Arguments
if nargin ~= 1
    dose = varargin{2};
    validateattributes(dose,{'numeric'},{'real','nonsparse','size',size(mask)},mfilename,'DOSE',2);
        
    map = varargin{3};
    validateattributes(map,{'numeric'},{'real','nonsparse','size',size(mask)},mfilename,'MAP',2);
    
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

if ~isvector(map)
    map = map(:);
end

%%
clearvars -except mask dose map bin_size
