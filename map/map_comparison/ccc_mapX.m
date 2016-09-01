function [ccc] = ccc_mapX(img1,img2)

v1  = img1(:);
v2  = img2(:);

ind = isnan(v1);
ind2 = isnan(v2);
if ~isequal(ind,ind2)
    error('here')
end

v1(ind) = [];
v2(ind) = [];

ccc = corr_ccc_mapX([v1,v2]);

clearvars -except ccc

%--------------------------------------------------------------------------
function [rc] = corr_ccc_mapX(Y)
% INPUT:
%   Y - a N*R data matrix
% Based on IPN_ccc in the IPN_toolbox
% REFERENCE:
%   Lin, L.I. 1989. A Corcordance Correlation Coefficient to Evaluate
%   Reproducibility. Biometrics 45, 255-268.
%
% XINIAN ZUO 2008
% zuoxinian@gmail.com

Ybar = mean(Y);
S = cov(Y,1);
R = size(Y,2);
tmp = triu(S,1);
rc = 2*sum(tmp(:))/((R-1)*trace(S)+ipn_ssd_mapX(Ybar));

clearvars -except rc

%--------------------------------------------------------------------------
function [ssd] = ipn_ssd_mapX(X)
% INPUT:
%   X - a 1*R data vector
%
% REF:
%   Lin, L.I. 1989. A Corcordance Correlation Coefficient to Evaluate
%   Reproducibility. Biometrics 45, 255-268.
%
% XINIAN ZUO 2008
% zuoxinian@gmail.com

R=length(X);
ssd=0;
for k=1:R-1
    ssd=ssd+sum((X(k+1:R)-X(k)).*(X(k+1:R)-X(k)));
end

clearvars -except ssd