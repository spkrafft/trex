function [J,preprocess_name] = preprocess_filter_gradient3D(varargin)
%PREPROCESS_FILTER_GRADIENT3D
%   [IMG,PREPROCESS_NAME] = PREPROCESS_FILTER_GRADIENT3D(IMG,METHOD)
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'method'     	(Optional)
%                   Default: 'Sobel'
%
%   Notes
%   -----
% 
%   $SPK

[img,method] = ParseInputs(varargin{:});

switch method
    case 'sobel'
        h = repmat(-fspecial('sobel'),[1,1,3]); % Align mask correctly along the x- and y- axes
        Gx = imfilter(img,permute(h,[2,1,3]),'replicate');
        Gy = imfilter(img,h,'replicate');
        Gz = imfilter(img,permute(h,[3,2,1]),'replicate');
        
    case 'prewitt'
        h = repmat(-fspecial('prewitt'),[1,1,3]); % Align mask correctly along the x- and y- axes
        Gx = imfilter(img,permute(h,[2,1,3]),'replicate');
        Gy = imfilter(img,h,'replicate');
        Gz = imfilter(img,permute(h,[3,2,1]),'replicate');   
        
    case 'centraldifference'           
        [Gx,Gy,Gz] = gradient(img);
   
    case 'intermediatedifference' 
        Gx = zeros(size(img));
        if (size(img,2) > 1)        
            Gx(:,1:end-1,:) = img(:,2:end,:) - img(:,1:end-1,:);
        end
            
        Gy = zeros(size(img));
        if (size(img,1) > 1)
            Gy(1:end-1,:,:) = img(2:end,:,:) - img(1:end-1,:,:);
        end
        
        Gz = zeros(size(img));
        if (size(img,3) > 1)
            Gz(:,:,1:end-1) = img(:,:,2:end) - img(:,:,1:end-1);
        end
        
    otherwise
        error('not a valid gradient method')
end

J = sqrt(Gx.^2+Gy.^2+Gz.^2);

preprocess_name = ['Gradient3D Filter (',method,')'];

%%
clearvars -except J preprocess_name

%--------------------------------------------------------------------------
function [img,method] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(1,2,nargin,mfilename);
else
    narginchk(1,2);
end

% Check img
img = varargin{1};
validateattributes(img,{'numeric'},{'real','nonsparse'},mfilename,'img',1);
if ndims(img) > 3
  error(message('images:preprocess:invalidSizeForIMG'))
end

% Assign Defaults
method = 'sobel';

% Parse Input Arguments
if nargin ~= 1
    method = lower(varargin{2});
end

%%
clearvars -except img method
