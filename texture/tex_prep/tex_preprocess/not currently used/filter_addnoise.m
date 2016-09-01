function [J,filter_name] = filter_addnoise(varargin)
%FILTER_ADDNOISE
%   [IMG,FILTER_NAME] = FILTER_ADDNOISE(IMG,NOISE_STD)
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'noise_std'     (Optional)
%                   Default: 15
%
%   Notes
%   -----
% 
%   $SPK

[img,noise_std] = ParseInputs(varargin{:});

J = round(img + noise_std.*randn(size(img)));

filter_name = ['Add Noise (',num2str(noise_std),')'];

%%
clearvars -except J filter_name

%--------------------------------------------------------------------------
function [img,noise_std] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(1,2,nargin,mfilename);
else
    narginchk(1,2);
end

% Check img
img = varargin{1};
validateattributes(img,{'numeric'},{'real','nonsparse'},mfilename,'img',1);
if ndims(img) > 3
  error(message('images:filter:invalidSizeForIMG'))
end

% Assign Defaults
noise_std = 15;

% Parse Input Arguments
if nargin ~= 1
    noise_std = varargin{2};
end

%%
clearvars -except img noise_std
