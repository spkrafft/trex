function [J,filter_name] = filter_adpmedian(varargin)
%FILTER_ADPMEDIAN Perform adaptive median filtering
%   [IMG,FILTER_NAME] = FILTER_ADPMEDIAN(IMG,SMAX)performs adaptive 
%   median filtering of image I. The median filter starts at size 3-by-3 and 
%   iterates upto size SMAX-by-SMAX. SMAX must be an odd integer greater than 1.
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'Smax'          (Optional)
%                   Default: 5
%
%   Notes
%   -----
% 
%   $SPK

[img,Smax] = ParseInputs(varargin{:});

% Initial setup
J = img;
J(:) = 0;
alreadyProcessed = false(size(img));

% Begin filtering
for k = 3:2:Smax
    zmin = ordfilt2(img,1,ones(k,k),'symmetric');
    zmax = ordfilt2(img,k*k,ones(k,k),'symmetric');
    zmed = medfilt2(img,[k k],'symmetric');
    
    processUsingLevelB = (zmed > zmin) & (zmax > zmed) & ~alreadyProcessed;
    zB = (img > zmin) & (zmax > img);
    outputZxy = processUsingLevelB & zB;
    outputZmed = processUsingLevelB & ~zB;
    J(outputZxy) = img(outputZxy);
    J(outputZmed) = zmed(outputZmed);
    
    alreadyProcessed = alreadyProcessed | processUsingLevelB;
    if all(alreadyProcessed(:))
        break;
    end
end

% Output zmed for any remaining unprocessed pixels. Note that this zmed was
% computed using a window of size Smax-by-Smax, which is the final value of
% k in the loop
J(~alreadyProcessed) = zmed(~alreadyProcessed);

filter_name = ['Adaptive Median (',num2str(Smax),')'];

%%
clearvars -except J filter_name

%--------------------------------------------------------------------------
function [img,Smax] = ParseInputs(varargin)

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
Smax = 5;

% Parse Input Arguments
if nargin ~= 1
    Smax = varargin{2};
    % SMAX must be an odd, positive integer greater than 1
    if (Smax <= 1) || (Smax/2 == round(Smax/2)) || (Smax ~= round(Smax))
        error('SMAX must be an odd integer > 1.')
    end
end

%%
clearvars -except img Smax
