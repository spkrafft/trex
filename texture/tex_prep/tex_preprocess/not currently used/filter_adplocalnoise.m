function [J,filter_name] = filter_adplocalnoise(varargin)
%FILTER_ADPLOCALNOISE Perform adaptive local noise reduction filtering
%   [IMG,FILTER_NAME] = FILTER_ADPLOCALNOISE(IMG,SIZ,VARNOISE)
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'siz'           (Optional)
%                   Default: 5
%
%   'varNoise'      (Optional)
%                   Default: 15
%
%   Notes
%   -----
% 
%   $SPK

[img,siz,varNoise] = ParseInputs(varargin{:});

padSize = (siz-1)/2;

padI = padarray(img,padSize);
J = zeros(size(padI));

for i = padSize+1:size(padI,1)-padSize
    for j = padSize+1:size(padI,2)-padSize

        region = padI(i-padSize:i+padSize,j-padSize:j+padSize);
        
        meanLocal = mean(region(:));
        varLocal = var(region(:));

        J(i,j) = padI(i,j) - (varNoise/varLocal)*(padI(i,j) - meanLocal);
    end
end

J = J(padSize+1:size(J,1)-padSize,padSize+1:size(J,2)-padSize);

filter_name = ['Adaptive Local Noise (',num2str(siz),'/',num2str(varNoise),')'];

%%
clearvars -except J filter_name

%--------------------------------------------------------------------------
function [img,siz,varNoise] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(1,3,nargin,mfilename);
else
    narginchk(1,3);
end

% Check img
img = varargin{1};
validateattributes(img,{'numeric'},{'real','nonsparse'},mfilename,'img',1);
if ndims(img) > 3
  error(message('images:filter:invalidSizeForIMG'))
end

% Assign Defaults
siz = 5;
varNoise = 15;

% Parse Input Arguments
if nargin ~= 1
    siz = varargin{2};
    varNoise = varargin{3};
end

%%
clearvars -except img siz varNoise
