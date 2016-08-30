function [weight] = spatialdvh_weight(siz,scheme)
% Creates and outputs weighting matrices with the given size and scheme.
%
% Input parameters:
%
% 'siz'             A 1x3 input vector containing the desired dimensions of
%                   the resulting weighting array.
%
% 'scheme'          An input string indicating the desired type of
%                   weighting matrix. See the options below for the
%                   available options.
%
% Output parameters:
%
% 'weight'          The output weighting matrix.
%
% Notes:
%
% SPK

weight = zeros(siz);
ydim = siz(1);
xdim = siz(2);
zdim = siz(3);

ycent = round(ydim/2);
xcent = round(xdim/2);
zcent = round(zdim/2);

switch scheme
    case 'Radial_XY'
        for i =1:ydim
            for j = 1:xdim
                for k = 1:zdim
                    weight(i,j,k) = sqrt((j-xcent)^2/xcent^2+(i-ycent)^2/ycent^2);
                end
            end
        end
        
    case 'Sup_Inf'
        line = linspace(0,1,round(zdim));
        weight = permute(repmat(line,[ydim,1,xdim]),[1 3 2]);
        
    case 'Ant_Post'
        line = linspace(0,1,round(ydim));
        weight = permute(repmat(line,[zdim,1,xdim]),[2 3 1]);
        
    case 'Right_Left'
        line = linspace(0,1,round(xdim));
        weight = permute(repmat(line,[zdim,1,ydim]),[3 2 1]);
        
    otherwise
        error('here')
end

%%
clearvars -except weight
