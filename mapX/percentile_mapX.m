function [J] = percentile_mapX(I)
%%
A = I(:);
ind_a = ~isnan(A);
A = A(ind_a);

%%
[B,~,ind_b] = unique(A);

%%
[f,x] = ecdf(B);

x = x(2:end);
f = f(2:end);

%%
b = f(ind_b);

%%
J = nan(size(I));
J(ind_a) = b;

%%
clearvars -except J

