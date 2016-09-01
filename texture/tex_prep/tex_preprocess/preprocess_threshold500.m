function [J,preprocess_name] = preprocess_threshold500(img)
%PREPROCESS_THRESHOLD500
%   [IMG,PREPROCESS_NAME] = PREPROCESS_THRESHOLD500(IMG)
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

threshold = 500;

J = img;
J(J>threshold) = nan;

preprocess_name = ['Threshold (',num2str(threshold),')'];

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
