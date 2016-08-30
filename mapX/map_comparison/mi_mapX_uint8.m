function MI = mi_mapX_uint8(img1,img2)
% function h=MI2(image_1,image_2,method)
%
% Takes a pair of images and returns the mutual information Ixy using joint entropy function JOINT_H.m
% 
% written by http://www.flash.net/~strider2/matlab.htm


%%
rows=size(img1,1);
cols=size(img2,2);
N=256;

h=zeros(N,N);

for i=1:rows;    %  col 
  for j=1:cols;   %   rows
    h(img1(i,j)+1,img2(i,j)+1) = h(img1(i,j)+1,img2(i,j)+1) + 1;
  end
end

%%
[r,c] = size(h);
b = h./(r*c); % normalized joint histogram
%%
y_marg = sum(b); %sum of the rows of normalized joint histogram
x_marg = sum(b,2)';%sum of columns of normalized joint histogran
%%
Hy=0;
for i=1:numel(y_marg)
    if(y_marg(i)==0)
         %do nothing
    else
        Hy = Hy + -(y_marg(i)*(log2(y_marg(i)))); %marginal entropy for image 1
    end
end
   
Hx=0;
for i=1:numel(x_marg)
    if(x_marg(i)==0)
         %do nothing
    else
        Hx = Hx + -(x_marg(i)*(log2(x_marg(i)))); %marginal entropy for image 2
    end   
end
%%
h_xy = -sum(sum(b.*log2(b+(b==0)))); % joint entropy
%%

MI = Hx + Hy - h_xy;% Mutual information
D = 1 - MI/h_xy; %metric, normalized distance

