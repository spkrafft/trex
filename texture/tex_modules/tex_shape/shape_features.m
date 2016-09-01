function [stats] = shape_features(varargin)
%SHAPE_FEATURES 
%   [STATS] = SHAPE_FEATURES(MASK,XV,YV,ZV)
%
%   Parameters include:
%  
%   'mask'   	Self explanatory
%
%   'xV'        (Optional)
%
%   'yV'        (Optional)
%
%   'zV'        (Optional)
%
%   Notes
%   -----
%   Utilizes imMinkowski code (available at https://www.mathworks.com/matlabcentral/fileexchange/33690-geometric-measures-in-2d-3d-images)
%   
%   References
%   ----------
%   [1] Legland, D.; Kiêu, K. & Devaux, M.-F. Computation of Minkowski measures
%   on 2D and 3D binary images. Image Anal. Stereol., 2007, 26, 83-92
%
%   Solidity and eccentricity from <https://github.com/mvallieres/radiomics/>
%   But I have used the original dimensions of the mask rather than
%   resizing to have isotropic voxels
%   
%   $SPK

%%
[mask,xV,yV,zV] = ParseInputs(varargin{:});

%%
if numel(xV) == 1 && numel(yV) == 1 && numel(zV) == 1 
    siz_vox = [abs(xV), abs(yV), abs(zV)];
else
    siz_vox = [abs(mean(diff(xV))), abs(mean(diff(yV))), abs(mean(diff(zV)))];
end

vol_vox = siz_vox(1)*siz_vox(2)*siz_vox(3);

stats.Volume = sum(mask(:))*vol_vox;

% %% Region Props Info
% stats_names3d = {'Area',...
%               'BoundingBox'};
% out = regionprops(double(mask),stats_names3d);     
% 
% stats.NumVoxels = out.Area;
% stats.LengthX = out.BoundingBox(5)*siz_vox(1);
% stats.LengthY = out.BoundingBox(4)*siz_vox(2);
% stats.LengthZ = out.BoundingBox(6)*siz_vox(3);
% 
% stats_names2d = {'ConvexArea',...
%                  'FilledArea',...
%                  'MajorAxisLength',...
%                  'MinorAxisLength',...
%                  'Orientation',...
%                  'Solidity'};
% out = [];
% for i = 1:size(mask,3)
%     if sum(sum(mask(:,:,i))) > 0
%         s = regionprops(double(mask(:,:,i)),stats_names2d);
% 
%         if isempty(out)
%             out = s;
%         else
%             fields = fieldnames(s);
%             for fCount = 1:numel(fields) 
%               out.(fields{fCount})(end+1,1) =  s.(fields{fCount});
%             end
%         end
%     end
% end
% 
% stats.FilledVolumeRatio = sum(out.FilledArea*vol_vox)/stats.Volume;
% stats.MajorAxisLengthMean2D = mean(out.MajorAxisLength*siz_vox(1));
% stats.MajorAxisLengthSum2D = sum(out.MajorAxisLength*siz_vox(1));
% stats.MinorAxisLengthMean2D = mean(out.MinorAxisLength*siz_vox(1));
% stats.MinorAxisLengthSum2D = sum(out.MinorAxisLength*siz_vox(1));
% stats.OrientationMean2D = mean(out.Orientation);
% 
% %% imMinkowski functions
% mink = minkowski_features(mask,siz_vox);
% 
% minkNames = fieldnames(mink);
% for i = 1:numel(minkNames)
%     stats.(minkNames{i}) = mink.(minkNames{i});
% end
% 
% %% Solidity
% perimeter = bwperim(mask,18);
% [y,x,z] = ind2sub(size(mask),find(perimeter));
% x = xV(x);
% y = yV(y);
% z = zV(z);
% 
% [~,stats.HullVolume] = convhull(x,y,z);
% stats.Solidity = stats.Volume/stats.HullVolume;
% 
% %% Eccentricity
% x = x(:); 
% y = y(:); 
% z = z(:);
% n = size(x,1);
% D = [x.*x,y.*y,z.*z,2*y.*z,2*x.*z,2*x.*y,2*x,2*y,2*z,ones(n,1)]';
% S = D*D';
% 
% % Create constraint matrix C:
% C(6,6)=0; C(1,1)=-1; C(2,2)=-1; C(3,3)=-1; C(4,4)=-4; C(5,5)=-4; C(6,6)=-4;
% C(1,2)=1; C(2,1)=1; C(1,3)=1; C(3,1)=1; C(2,3)=1; C(3,2)=1;
% 
% % Solve generalized eigensystem
% S11 = S(1:6, 1:6); 
% S12 = S(1:6, 7:10); 
% S22 = S(7:10,7:10);
% A = S11-S12*pinv(S22)*S12'; 
% CA = C\A;
% [gevec,geval] = eig(CA);
% 
% % Find the largest eigenvalue(the only positive eigenvalue)
% In = 1;
% maxVal = geval(1,1);
% for i = 2:6
%    if (geval(i,i) > maxVal)
%        maxVal = geval(i,i);
%        In = i;
%    end;
% end;
% 
% % Find the fitting
% v1 = gevec(:,In); 
% v2 = -pinv(S22)*S12'*v1;
% v = [v1; v2];
% 
% % Algebraic from of the ellipsoid
% A = [v(1),v(6),v(5),v(7); ...
%      v(6),v(2),v(4),v(8); ...
%      v(5),v(4),v(3),v(9); ...
%      v(7),v(8),v(9),-1];
% 
% % Center of the ellipsoid
% center = -A(1:3,1:3)\[v(7); v(8); v(9)];
% 
% % Corresponding translation matrix
% T = eye(4);
% T(4,1:3) = center';
% 
% % Translating to center
% R = T*A*T';
% 
% % Solving eigenproblem
% [~,evals] = eig(R(1:3,1:3)/-R(4,4));
% radii = sqrt(1./diag(evals));
% 
% % ECCENTRICITY COMPUTATION
% stats.Eccentricity = sqrt(1-(radii(2)*radii(3)/radii(1)^2));

%%
clearvars -except stats

%--------------------------------------------------------------------------
function [mask,xV,yV,zV] = ParseInputs(varargin)

if verLessThan('matlab','7.13')
    iptchecknargin(1,4,nargin,mfilename);
else
    narginchk(1,4);
end

% Check mask
mask = varargin{1};
validateattributes(mask,{'numeric','logical'},{'real','nonsparse'},mfilename,'mask',1);
if ndims(mask) > 3
  error(message('images:shape_features:invalidSizeForMASK'))
end
mask = logical(mask); %force it to logical if it isn't already. Not in validate attributes because is is an issue with dynamic calls to shape_features

if isscalar(mask)
    mask = padarray(mask,[1 1 1],1);
    mask = padarray(mask,[1 1 1],0);
end

% Assign Defaults
xV = 1:size(mask,2);
yV = 1:size(mask,1);
zV = 1:size(mask,3);

% Parse Input Arguments
if nargin ~= 1
    xV = varargin{2};
    validateattributes(xV,{'numeric'},{'real','nonsparse'},mfilename,'XV',2);
    yV = varargin{3};
    validateattributes(yV,{'numeric'},{'real','nonsparse'},mfilename,'YV',3);
    zV = varargin{4};
    validateattributes(zV,{'numeric'},{'real','nonsparse'},mfilename,'ZV',4);
    
    if numel(xV) == 1 && numel(yV) == 1 && numel(zV) == 1 
        %Then cool, we are passing in the siz_vox directly, mainly for the
        %map stuff
    elseif numel(xV) == size(mask,2) && numel(yV) == size(mask,1) && numel(zV) == size(mask,3) 
        %Also cool
    else
       error('not cool') 
    end
    
%     xV = varargin{2};
%     validateattributes(xV,{'numeric'},{'real','nonsparse','vector','size',[1,size(mask,2)]},mfilename,'XV',2);
%     yV = varargin{3};
%     validateattributes(yV,{'numeric'},{'real','nonsparse','vector','size',[1,size(mask,1)]},mfilename,'YV',3);
%     zV = varargin{4};
%     validateattributes(zV,{'numeric'},{'real','nonsparse','vector','size',[1,size(mask,3)]},mfilename,'ZV',4);

end

%%
clearvars -except mask xV yV zV
