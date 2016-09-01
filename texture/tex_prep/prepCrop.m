function [img,mask,xV,yV,zV] = prepCrop(varargin)
%PREPCROP Crops input image to the mask
%   [IMG,MASK] = PREPCROP(IMG,MASK) returns a cropped mask 
%   and image that are determined by the boundaries of the mask.
%
%   Parameters include:
%  
%   'img'     Self explanatory
%
%   'mask'          Self explanatory
%
%   'pad'           (Optional) An input vector equal to the number of
%                   dimensions of mask/img. Essentially, this 
%                   symmetrically expands the boundaries of the mask based
%                   on the input vector. If an attempt is made to expand
%                   the boundary beyond the limits of the original mask,
%                   the result is clipped to original mask boundary.
%                   
%   Notes
%   -----
% 
%   $SPK

%%
[img,mask,padsize,xV,yV,zV] = ParseInputs(varargin{:});

%%
summask = sum(mask(:));

%Get the boundaries of the mask
%Z DIM
if ndims(mask) == 3
    ind = sum(squeeze(any(mask,1)),1);
    ind = find(ind);
    startz = min(ind)-padsize(3);
    if startz < 1
        startz = 1;
    end
    endz = max(ind)+padsize(3);
    if endz > size(mask,3)
        endz = size(mask,3);
    end
else
    startz = 1;
    endz = 1;
end

%Y DIM
ind = sum(squeeze(any(mask,2)),2);
ind = find(ind);
starty = min(ind)-padsize(1);
if starty < 1
    starty = 1;
end
endy = max(ind)+padsize(1);
if endy > size(mask,1)
    endy = size(mask,1);
end

%X DIM
ind = sum(squeeze(any(mask,3)),1);
ind = find(ind);
startx = min(ind)-padsize(2);
if startx < 1
    startx = 1;
end
endx = max(ind)+padsize(2);
if endx > size(mask,2)
    endx = size(mask,2);
end
    
%Crop the mask and img using the boundaries
mask = mask(starty:endy,startx:endx,startz:endz);
img = img(starty:endy,startx:endx,startz:endz);
xV = xV(startx:endx);
yV = yV(starty:endy);
zV = zV(startz:endz);

if ~isequal(sum(mask(:)),summask)
    error('The cropped mask does not contain the same number of elements as the uncropped mask.')
end

%%
clearvars -except img mask xV yV zV

%--------------------------------------------------------------------------
function [img,mask,padSiz,xV,yV,zV] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(2,10,nargin,mfilename);
else
    narginchk(2,10);
end

% Check img
img = varargin{1};
validateattributes(img,{'logical','numeric'},{'real','nonsparse'},mfilename,'img',1);
if ndims(img) > 3
  error(message('images:prepCrop:invalidSizeForIMG'))
end

% Check mask
mask = varargin{2};
validateattributes(mask,{'logical'},{'real','nonsparse','size',size(img)},mfilename,'mask',2);

% Assign Defaults
padSiz = [0,0,0];
[yV,xV,zV] = size(img);
xV = 1:xV;
yV = 1:yV;
zV = 1:zV;

% Parse Input Arguments
if nargin ~= 2
    paramStrings = {'Pad','xV','yV','zV'};
  
    for k = 3:2:nargin
        param = lower(varargin{k});
        inputStr = validatestring(param, paramStrings, mfilename, 'PARAM', k);
        idx = k + 1;  %Advance index to the VALUE portion of the input.
        if idx > length(varargin)
            error(message('images:prepCrop:missingParameterValue', inputStr));        
        end

        switch (inputStr)
            case 'Pad'
                padSiz = varargin{idx};
                validateattributes(padSiz,{'numeric'},{'real','nonsparse'},mfilename,'PAD', idx);
                if numel(padSiz) ~= 3
                    error(message('images:prepCrop:invalidSizeForPAD'))
                end
                
            case 'xV'
                xV = varargin{idx};
                validateattributes(padSiz,{'numeric'},{'real','nonsparse','vector'},mfilename,'XV', idx);
                
            case 'yV'
                yV = varargin{idx};
                validateattributes(padSiz,{'numeric'},{'real','nonsparse','vector'},mfilename,'YV', idx);
                
            case 'zV'
                zV = varargin{idx};
                validateattributes(padSiz,{'numeric'},{'real','nonsparse','vector'},mfilename,'ZV', idx);
            otherwise
                error('here')
        end
    end
end

%%
clearvars -except img mask padSiz xV yV zV
