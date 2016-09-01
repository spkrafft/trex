function [B,RB] = imresize3DX(A,pixdim,tsize,Interp)
% This function resizes a 3D image volume to new dimensions
% [B,RB] = imresize3DX(A,pixdim,tsize,Interp);
%
% inputs
%   A: The input image volume
%   pixdim: the pixel dimensions of the input volume [x,y,z]
%   tsize: new dimensions or the output image volume [r,c,z]
%   Interp: Type of interpolation ('nearest', 'linear', or 'cubic')
%   npad: Boundary condition ('replicate', 'symmetric', 'circular', 'fill', or 'bound')  
%
% outputs,
%   B: The resized image volume
%
% SPK 06/06/2016

% %% Shift all of the pixel values in the original image if necessary for nan setting
% ind_nan = isnan(A);
% 
% % What does the shifting of nans do here?
% A(ind_nan) = nanmedian(A(:)); %set all nan to zero

%% Extrapolate beyond the boundaries and available array points using nearest neighbor
[x,y,z] = meshgrid(1:size(A,2),1:size(A,1),1:size(A,3));
x = x(:);
y = y(:);
z = z(:);

v = A(:);

ind = ~isnan(v);

F = scatteredInterpolant(x(ind),y(ind),z(ind),v(ind),'linear','linear');
vq = F(x(~ind),y(~ind),z(~ind));

A(~ind) = vq;

clear x
clear y
clear z
clear v
clear ind
clear F
clear vq

%% Do the magic here
% scale = tsize./size(A);
scale = ones(ndims(A),1);
tform = affine3d([scale(2) 0 0 0; 0 scale(1) 0 0; 0 0 scale(3) 0; 0 0 0 1]);

RA = imref3d(size(A),pixdim(1),pixdim(2),pixdim(3)); %x,y,z pixel dimensions

Rout = imref3d(tsize,size(A,2)/tsize(2)*pixdim(1),...
                     size(A,1)/tsize(1)*pixdim(2),...
                     size(A,3)/tsize(3)*pixdim(3)); %x,y,z pixel dimensions                
                 
[B,RB] = imwarp(A,RA,tform,Interp,'FillValues',0,'OutputView',Rout);

%% If the size doesn't match, we have a problem...
if sum(size(B) ~= tsize) > 0
    error('here')
end

%%
clearvars -except B RB

