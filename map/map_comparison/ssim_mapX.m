function [mssim,ssim_map] = ssim_mapX(img1,img2,varargin)

hsize = 11;
if nargin == 3
    hsize = varargin{1};
end

h = fspecial('gaussian',hsize,1.5);
K(1) = 0.01;
K(2) = 0.03;
L = 1;

C1 = (K(1)*L)^2;
C2 = (K(2)*L)^2;
img1 = double(img1);
img2 = double(img2);

%%

mu1 = imfilter(img1,h);
mu2 = imfilter(img2,h);

%%
mu1_sq = mu1.*mu1;
mu2_sq = mu2.*mu2;
mu1_mu2 = mu1.*mu2;

%%

sigma1_sq = imfilter(img1.*img1,h);
sigma2_sq = imfilter(img2.*img2,h);
sigma12 = imfilter(img1.*img2,h);

%%
sigma1_sq = sigma1_sq - mu1_sq;
sigma2_sq = sigma2_sq - mu2_sq;
sigma12 = sigma12 - mu1_mu2;

%%


ssim_map = ((2*mu1_mu2 + C1).*(2*sigma12 + C2))./((mu1_sq + mu2_sq + C1).*(sigma1_sq + sigma2_sq + C2));
%%
mssim = nanmean(ssim_map(:));

