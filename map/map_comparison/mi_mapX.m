function [MI,D] = mi_mapX(img1,img2,binSize)
 
img1 = double(img1(:)); %Vectorize!!!
img2 = double(img2(:));

%%
min_xy = min([img1; img2]);
max_xy = max([img1; img2]);

% std_xy = std([img1; img2]);
% %binSize = 1; %If we are dealing with an integer array
% binSize = (max_xy-min_xy)/std_xy*5; %I suggest: binSize=range(y)/std(y)*5;

bins = min_xy:binSize:max_xy;
%%
% Entropy of img1
% Generate the histogram
[n, xout] = hist(img1, bins);

% Normalize the area of the histogram to make it a pdf
n = n/sum(n);
b = xout(2)-xout(1);

% Calculate the entropy
indices = (n ~= 0);
Hx = -sum(n(indices).*log2(n(indices)).*b);

%%
% Entropy of img2
% Generate the histogram
[n, xout] = hist(img2(:), bins);

% Normalize the area of the histogram to make it a pdf
n = n/sum(n);
b = xout(2)-xout(1);

% Calculate the entropy
indices = (n ~= 0);
Hy = -sum(n(indices).*log2(n(indices)).*b);    

%%
[N,C] = hist3([img1(:),img2(:)],{bins; bins});
 
hx = C{1,1};
hy = C{1,2};
 
% Normalize the area of the histogram to make it a pdf
N = N/sum(N(:));
b = hx(2)-hx(1);
l = hy(2)-hy(1);
 
% Calculate the entropy
indices = N ~= 0;
Hxy = -b*l*sum(N(indices).*log2(N(indices)));

MI = Hx + Hy - Hxy;
D = 1 - MI/Hxy; %metric, normalized distance
