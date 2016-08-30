function [J] = norm_mapX(I,out_rng,varargin)
%%
if nargin > 2
    in_rng = varargin{1};
else
    %Remove any significant outliers (similar to matlab stretchlim function
    p1 = prctile(I(:),1);
    p99 = prctile(I(:),99);
    I(I>p99) = p99;
    I(I<p1) = p1;

    %Linear scaling of the image to the provided input range
    in_rng = [nanmin(I(:)), nanmax(I(:))];
end

%%
J = out_rng(1)+((out_rng(2)-out_rng(1))*(I-in_rng(1)))./(in_rng(2)-in_rng(1));

J(J > out_rng(2)) = out_rng(2);
J(J < out_rng(1)) = out_rng(1);

%%
clearvars -except J
