function [spear] = spearman_mapX(img1,img2)

v1  = img1(:);
v2  = img2(:);

ind = isnan(v1);
ind2 = isnan(v2);
if ~isequal(ind,ind2)
    error('here')
end

v1(ind) = [];
v2(ind) = [];

[spear] = corr(v1,v2,'type','spearman');

clearvars -except spear

