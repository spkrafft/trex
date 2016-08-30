function [img,preprocess] = prepPreprocess(varargin)
%PREPPREPROCESS
%   [IMG,FILTER] = PREPPREPROCESS(IMG,PREPROCESS) 
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'preprocess'    (Optional) This is the name of the preprocess to be applied
%                   to the input image. See the switch statement below for
%                   the available options.
%
%   Notes
%   -----
% 
%   $SPK

%%
[img,preprocess] = ParseInputs(varargin{:});

%%
if strcmpi(preprocess,'none')
    
else
    [~,func_names,preprocess_names] = read_preprocess;
    ind = strcmpi(preprocess,preprocess_names);
    if sum(ind)==0
        error('Input preprocess is invalid')
    end
    %fhandle = [func_names{ind,1},'(img)'];
    img = feval(func_names{ind,1},img);
end

%%
clearvars -except img preprocess

%--------------------------------------------------------------------------
function [img,preprocess] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(1,2,nargin,mfilename);
else
    narginchk(1,2);
end

% Check img
img = varargin{1};
validateattributes(img,{'numeric'},{'real','nonsparse'},mfilename,'img',1);
if ndims(img) > 3
  error(message('images:PREPPREPROCESS:invalidSizeForIMG'))
end

% Assign Defaults
preprocess = 'none';

% Parse Input Arguments
if nargin ~= 1 
    preprocess = varargin{2};
end

%%
clearvars -except img preprocess
