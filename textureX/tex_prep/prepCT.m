function [img,preprocess,mask,crop] = prepCT(varargin)
%PREPCT Prepares input image for texture analysis
%   [IMG,FILTER] = PREPCT(IMG,MASK) preps the scan for 
%   texture analysis by cropping, preprocessing and setting all of voxels 
%   outside the mask to NaN.
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'mask'          Self explanatory
%
%   'preprocess'  	(Optional) This is the name of the preprocess to be applied
%                   to the input image. See the switch statement below for
%                   the available options.
%
%   'pad'           (Optional) Size of the zero pad added to the image.
%                   Default is 5 in each dimension of img.
%
%   Notes
%   -----
% 
%   $SPK

%%
[img,mask,preprocess,padSiz] = ParseInputs(varargin{:});

%%
img = double(img);

% Image extraction should already have applied the appropriate rescale
% slope/intercept and then shifted all values such that 0 is air, 1000 is
% water.
%
% Anything that is less than zero gets clipped to zero. 
% Truncate at 12-bits by clipping anything greater than 4095 to 4095.
img(img<0) = 0;
img(img>4095) = 4095;

[img,mask] = prepCrop(img,mask,'Pad',padSiz);

[img,preprocess] = prepPreprocess(img,preprocess);

crop = img;
img(mask==false) = nan;

%%
clearvars -except img preprocess crop mask

%--------------------------------------------------------------------------
function [img,mask,preprocess,padSiz] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(2,6,nargin,mfilename);
else
    narginchk(2,6);
end

% Check img
img = varargin{1};
validateattributes(img,{'numeric'},{'real','nonsparse'},mfilename,'img',1);
if ndims(img) > 3
  error(message('images:prepCT:invalidSizeForIMG'))
end

% Check mask
mask = varargin{2};
validateattributes(mask,{'logical'},{'real','nonsparse','size',size(img)},mfilename,'mask',2);

% Assign Defaults
preprocess = 'none';
% padSiz = 5*ones(1,ndims(img));
padSiz = 5*ones(1,3);

% Parse Input Arguments
if nargin ~= 2
    paramStrings = {'Preprocess','Pad'};
  
    for k = 3:2:nargin
        param = lower(varargin{k});
        inputStr = validatestring(param, paramStrings, mfilename, 'PARAM', k);
        idx = k + 1;  %Advance index to the VALUE portion of the input.
        if idx > nargin
            error(message('images:prepCT:missingParameterValue', inputStr));        
        end

        switch (inputStr)
            case 'Preprocess'
                preprocess = varargin{idx};
                validateattributes(preprocess,{'char'},{},mfilename, 'PREPROCESS', idx);
                
            case 'Pad'
                padSiz = varargin{idx};
                validateattributes(padSiz,{'numeric'},{'real','nonsparse'},mfilename,'PAD', idx);
                if numel(padSiz) ~= 3
                    error(message('images:prepCT:invalidSizeForPAD'))
                end
            otherwise
                error('here')
        end
    end
end

%%
clearvars -except img mask preprocess padSiz
