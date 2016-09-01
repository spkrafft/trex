function [psnr,mse] = psnr_mapX(img1,img2)

img_max = max(max(img1(:)),max(img2(:))); 
dif = img1(:)-img2(:);
mse = nanmean(dif.^2);
psnr = 10*log(img_max*img_max/mse)/log(10);