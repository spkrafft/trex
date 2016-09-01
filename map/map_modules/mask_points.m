function [X,Y,Z] = mask_points(mask,block_size,overlap,shift,dim)
%%
[size_y,size_x,size_z] = size(mask);

step = block_size-overlap;

xV = shift:step:size(mask,2);
yV = shift:step:size(mask,1);
if strcmpi(dim,'3D')
    zV = shift:step:size(mask,3);
else
    zV = 1:1:size(mask,3);   
end

[X,Y,Z] = meshgrid(xV,yV,zV);
X = X(:);
Y = Y(:);
Z = Z(:);

%%
%Lower and upper bound for each block centered X, Y, Z
X_low = X - floor(block_size/2);
X_up = X + ceil(block_size/2) - 1;

Y_low = Y - floor(block_size/2);
Y_up = Y + ceil(block_size/2) - 1;

if strcmpi(dim,'3D')
    Z_low = Z - floor(block_size/2);
    Z_up = Z + ceil(block_size/2) - 1;
else
    Z_low = Z;
    Z_up = Z;
end

%If part of the block falls outside the slice, get rid of it
ind = X_low < 1 | X_up > size_x | Y_low < 1 | Y_up > size_y | Z_low < 1 | Z_up > size_z;
X_low(ind) = [];
X(ind) = [];
X_up(ind) = [];
Y_low(ind) = [];
Y(ind) = [];
Y_up(ind) = [];
Z_low(ind) = [];
Z(ind) = [];
Z_up(ind) = [];

%%
%If the block is centered on pixel that is outside the mask, get rid of it
index = Y + (X-1)*size_y + (Z-1)*size_y*size_x;
ind = mask(index) == false;
X_low(ind) = [];
X(ind) = [];
X_up(ind) = [];
Y_low(ind) = [];
Y(ind) = [];
Y_up(ind) = [];
Z_low(ind) = [];
Z(ind) = [];
Z_up(ind) = [];

% Cat points
X = [X_low,X,X_up];
Y = [Y_low,Y,Y_up];
Z = [Z_low,Z,Z_up];

%%
clearvars -except X Y Z
