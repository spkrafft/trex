function [glMatrix] = glrlm_orderMatrix(glMatrix,inputOffset,outputOffset)
%GLRLM_ORDERMATRIX Order the matrices for statistical
%   texture feature calculation.
%   [GLMATRIX] = GLRLM_ORDERMATRIX(GLMATRIX,INPUTOFFSET,OUTPUTOFFSET) returns  
%   matrices based on the input gray level matrix. 
%
%   Parameters include:
%  
%   'glMatrix'      An input n by m by up to 13 gray level matrix (i.e. the gray
%                   level co-occurrence or run length matrix).
%
%   'inputOffset'   A p-by-3 array of offsets specifying the diretion 
%                   between the pixel-of-interest and its neighbor. Each  
%                   row in the array is a three-element vector [X_OFFSET 
%                   Y_OFFSET Z_OFFSET] that specifies the relationship, or 
%                   'Offset', between a  pair of pixels. Because this 
%                   offset is often expressed as an angle, the following 
%                   table lists the offset values that specify common 
%                   angles, given the pixel distance.
%
%                   Angle(phi,theta)    Offset
%                   ----------------    ------
%                   (0,90)              (1,0,0)
%                   (90,90)             (0,1,0)
%                   (-,90)              (0,0,1)
%                   (45,90)             (1,1,0)
%                   (135,90)            (-1,1,0)
%                   (90,45)             (0,1,1)
%                   (90,135)            (0,1,-1)
%                   (0,45)              (1,0,1)
%                   (0,135)             (1,0,-1)
%                   (45,54.7)           (1,1,1)
%                   (135,54.7)          (-1,1,1)
%                   (45,125.3)          (1,1,-1)
%                   (135,125.3)         (-1,1,-1)
%
%   'outputOffset'  A p-by-3 array of offsets specifiing the desired order
%                   of the output glMatrix
%
%   Notes
%   -----
% 
%   $SPK

%%
[glMatrix,inputOffset,outputOffset] = ParseInputs(glMatrix,inputOffset,outputOffset);

%%
[~,ind_order] = ismember(inputOffset,outputOffset,'rows');
ind_exist = ind_order~=0;
glMatrix = glMatrix(:,:,ind_exist);

ind_order = ind_order(ind_exist);
glMatrix = glMatrix(:,:,ind_order);

%%
clearvars -except glMatrix

%-----------------------------------------------------------------------------
function [glMatrix,inputOffset,outputOffset] = ParseInputs(glMatrix,inputOffset,outputOffset)

if verLessThan('matlab','7.13')
    iptchecknargin(3,3,nargin,mfilename);
else
    narginchk(3,3);
end

% Check glMatrix
validateattributes(glMatrix,{'logical','numeric'},{'real','nonnegative','integer'},mfilename,'GLMATRIX',1);

if ndims(glMatrix) > 3
  error(message('images:glrlm_orderMatrix:invalidSizeForGLMATRIX'))
end

% Cast glMatrix to double to avoid truncation by data type. Note that 
% glMatrix is not an image.
if ~isa(glMatrix,'double')
  glMatrix = double(glMatrix);
end

% Check offset
validateattributes(inputOffset,{'logical','numeric'},{'2d','nonempty','integer','real'},mfilename,'INPUTOFFSET',2);
if size(inputOffset,2) ~= 3
    error(message('images:glrlm_orderMatrix:invalidOffsetSize'));
end
if size(inputOffset,1) ~= size(glMatrix,3)
    error(message('images:glrlm_orderMatrix:invalidOffsetSize'));
end
inputOffset = double(inputOffset);

% Check offset
validateattributes(outputOffset,{'logical','numeric'},{'2d','nonempty','integer','real'},mfilename,'OUTPUTOFFSET',2);
if size(outputOffset,2) ~= 3 %%|| size(offset,1) ~= 13
    error(message('images:glrlm_orderMatrix:invalidOffsetSize'));
end
outputOffset = double(outputOffset);

%%
clearvars -except glMatrix inputOffset outputOffset

