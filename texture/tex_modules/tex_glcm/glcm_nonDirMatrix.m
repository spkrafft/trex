function [nondir2D,nondir3D] = glcm_nonDirMatrix(glMatrix,offset)
%GLCM_NONDIRMATRIX Create non-directional 2D and 3D matrices for statistical
%   texture feature calculation.
%   [NONDIR2D,NONDIR3D] = GLCM_NONDIRMATRIX(GLMATRIX,OFFSET) returns the 2D 
%   and 3D non-directional matrices based on the input gray level matrix. 
%
%   Parameters include:
%  
%   'glMatrix'      An input n by m by 13 gray level matrix (i.e. the gray
%                   level co-occurrence or run length matrix).
%
%   'offset'     	A p-by-3 array of offsets specifying the diretion 
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
%   Notes
%   -----
% 
%   $SPK

%%
[glMatrix,offset] = ParseInputs(glMatrix,offset);

%%
offset2D = [];
for i = 1:size(offset,1)
    if offset(i,3) == 0
        offset2D(end+1) = i;
    end
end

%Sum to create nondirectional 2D matrix
nondir2D = zeros(size(glMatrix(:,:,1)));
for i = 1:length(offset2D)
    nondir2D = nondir2D + glMatrix(:,:,offset2D(i));
end

%Sum to create nondirectional 3D matrix
nondir3D = zeros(size(glMatrix(:,:,1)));
for i = 1:size(offset,1)
    nondir3D = nondir3D + glMatrix(:,:,i);
end

%%
clearvars -except nondir2D nondir3D

%-----------------------------------------------------------------------------
function [glMatrix,offset] = ParseInputs(glMatrix,offset)

if verLessThan('matlab', '7.13')
    iptchecknargin(2,2,nargin,mfilename);
else
    narginchk(2,2);
end

% Check glMatrix
validateattributes(glMatrix,{'logical','numeric'},{'real','nonnegative','integer'},mfilename,'GLMATRIX',1);

if ndims(glMatrix) > 3 %%|| size(glMatrix,3) ~= 13
  error(message('images:glcm_nonDirMatrix:invalidSizeForGLMATRIX'))
end

% Cast glMatrix to double to avoid truncation by data type. Note that 
% glMatrix is not an image.
if ~isa(glMatrix,'double')
  glMatrix = double(glMatrix);
end

% Check offset
validateattributes(offset,{'logical','numeric'},{'2d','nonempty','integer','real'},mfilename,'OFFSET',2);
if size(offset,2) ~= 3 %%|| size(offset,1) ~= 13
    error(message('images:glcm_nonDirMatrix:invalidOffsetSize'));
end
offset = double(offset);

%%
clearvars -except glMatrix offset
