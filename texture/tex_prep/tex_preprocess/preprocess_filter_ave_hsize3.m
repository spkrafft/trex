function [J,preprocess_name] = preprocess_filter_ave_hsize3(img)
%PREPROCESS_FILTER_AVE_HSIZE3
%   [IMG,preprocess_NAME] = PREPROCESS_FILTER_AVE_HSIZE3(IMG)
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   Notes
%   -----
% 
%   $SPK

[img] = ParseInputs(img);

hsize = 3;

h = fspecial('average',hsize);
J = imfilter(img,h);

preprocess_name = ['Average (',num2str(hsize),')'];

%%
clearvars -except J preprocess_name

%--------------------------------------------------------------------------
function [img] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(1,1,nargin,mfilename);
else
    narginchk(1,1);
end

% Check img
img = varargin{1};
validateattributes(img,{'numeric'},{'real','nonsparse'},mfilename,'img',1);
if ndims(img) > 3
  error(message('images:preprocess:invalidSizeForIMG'))
end

%%
clearvars -except img
