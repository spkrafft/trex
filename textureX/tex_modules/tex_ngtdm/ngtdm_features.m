function [stats] = ngtdm_features(varargin)
%NGTDM_FEATURES Properties of neighborhood gray tone difference matrix.  
%   STATS = NGTDM_FEATURES(SI,NGTDM,P) uses the scaled image, NGTDM, and 
%   probability of occurrence to calculate the features.
%
%   NGTDM and P can be an m x 1 vector where m is the number of gray
%   levels in the scaled image.
%  
%   STATS is a structure with fields determined from ref [1].
%
%   Notes
%   -----  
%
%   References
%   ----------
%   [1] Amadasun, Moses, and Robert King. "Textural features corresponding 
%       to textural properties." Systems, Man and Cybernetics, IEEE Transactions 
%       on 19.5 (1989): 1264-1274.
%   [2] Yu, Huan, et al. "Coregistered FDG PET/CT-based textural characterization 
%       of head and neck cancer for radiation treatment planning." Medical Imaging, 
%       IEEE Transactions on 28.3 (2009): 374-383.
%
%   $SPK

%%
[ngtdm,p] = ParseInputs(varargin{:});

%%
gLevels = sum(ngtdm~=0);
n = sum(p); %total number of elements
p = p/n; %actual probability of occurrence

%Mesh to get indices
s = size(p);
[i,j] = meshgrid(1:s(1),1:s(1));
i = i(:);
j = j(:);

%Get indices of p that aren't zero
p_n0 = find(p ~= 0);
[i_n0,j_n0] = meshgrid(p_n0,p_n0);
i_n0 = i_n0(:);
j_n0 = j_n0(:);

%Coarseness [1]
stats.Coarseness = 1/(eps+sum(p.*ngtdm));

%Contrast [1,2]
stats.Contrast = 1/(gLevels*(gLevels-1))*sum(p(i).*p(j).*(i-j).^2)*(1/n)*sum(ngtdm); %No square in denom as in [2]

%Busyness [1,2]
stats.Busyness = sum(p.*ngtdm)/(sum(abs(i_n0.*p(i_n0)-j_n0.*p(j_n0)))); %Abs in denom as in [2]

%Complexity [1]
stats.Complexity = sum((abs(i_n0-j_n0)./(n^2*(p(i_n0)+p(j_n0)))).*(p(i_n0).*ngtdm(i_n0)+p(j_n0).*ngtdm(j_n0)));

%Strength [1]
stats.Strength = sum((p(i_n0)+p(j_n0)).*(i_n0-j_n0).^2)/(eps+sum(ngtdm));

%%
clearvars -except stats

%--------------------------------------------------------------------------
function [ngtdm,p] = ParseInputs(varargin)

if verLessThan('matlab','7.13')
    iptchecknargin(1,2,nargin,mfilename);
else
    narginchk(1,2);
end

% Check ngtdm
ngtdm = varargin{1};
validateattributes(ngtdm,{'numeric'},{'real','nonsparse','vector'},mfilename,'ngtdm',1);

% Assign Defaults
p = ones(size(ngtdm));

% Parse Input Arguments
if nargin ~= 1
    p = varargin{2};
    validateattributes(p,{'numeric'},{'real','nonsparse','vector','size',size(p)},mfilename,'P',2);
end

%%
clearvars -except ngtdm p
