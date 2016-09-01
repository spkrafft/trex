function [J] = standardize_mapX(I)
%%
mean_I = nanmean(I(:));
std_I = nanstd(I(:));

J = (I - mean_I)/std_I;

%%
clearvars -except J
