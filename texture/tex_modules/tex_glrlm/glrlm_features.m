function stats = glrlm_features(glrlm)
%GLRLM_FEATURES Properties of gray-level run length matrix.  
%   STATS = GLRLM_FEATURES(GLCM) uses the GLRLM to calculate the features.
%
%   GLRLM can be an m x n x p array of valid gray-level run length
%   matrices.
%  
%   STATS is a structure with fields determined from ref [1]. Each
%   field contains a 1 x p array, where p is the number of gray-level
%   run length matrices in glrlm.
%
%   Notes
%   -----  
% 
%   Class Support
%   -------------  
%   GLRLM can be logical or numeric, and it must contain real, non-negative, 
%   finite, integers. STATS is a structure.
%
%   Examples
%   --------
%   GLRLM = [0 1 2 3;1 1 2 3;1 0 2 0;0 0 0 3];
%   stats = glrlm_features(GLRLM)
%
%   I = imread('circuit.tif');
%   GLRLM2 = glrlm_matrix3D(I,'Offset',[1 0 0;0 1 0]);
%   stats = glrlm_features(GLCM2)
%  
%   See also GLRLM_MATRIX3D.
%
%   References
%   ----------
%   [1] Galloway, Mary M. "Texture analysis using gray level run lengths." 
%       Computer graphics and image processing 4.2 (1975): 172-179.
%   [2] Tang, Xiaoou. "Texture information in run-length matrices." Image 
%       Processing, IEEE Transactions on 7.11 (1998): 1602-1609.
%
%   $SPK

%%
numGLRLM = size(glrlm,3);
for k = 1:numGLRLM
    if numGLRLM ~= 1
        p = glrlm(:,:,k);
    else
        p = glrlm;
    end
  
    % Get row and column subscripts of GLRLM.  These subscripts correspond to the
    % pixel values in the GLRLM.
    s = size(p);
    [r,c] = meshgrid(1:s(1),1:s(2));
    r = r(:);
    c = c(:);
    
    index = r + (c-1)*s(1);
    pV = p(index);
    
    pX = sum(p,2);
    pY = sum(p,1);
    
    C = sum(p(:));
    
    %Short Run Emphasis [1]
    stats.SRE(k) = sum(pV./c.^2)/C;
    
    %Long Run Emphasis [1]
    stats.LRE(k) = sum(pV.*(c.^2))/C;
    
    %Gray Level Nonuniformity [1]
    stats.GLNU(k) = sum(pX.^2)/C;
    
    %Run Length Nonuniformity [1]
    stats.RLNU(k) = sum(pY.^2)/C;
    
    %Run Percentage/Fraction [1]
    stats.Fraction(k) = C/sum(c.*pV);
    
    glevels = 1:size(p,1);
    
    %Low gray-level run emphasis [2]
    stats.LGRE(k) = sum(pX./(glevels').^2)/C;

    %High gray-level run emphasis [2]
    stats.HGRE(k) = sum(pX.*(glevels').^2/C);

    %Short run low gray-level emphasis [2]
    stats.SRLGE(k) = sum(pV./(c.^2.*r.^2))/C;

    %Short run high gray-level emphasis [2]
    stats.SRHGE(k) = sum(pV.*r.^2./c.^2)/C;

    %Long run low gray-level emphasis [2]
    stats.LRLGE(k) = sum(pV.*c.^2./r.^2)/C;

    %Long run high gray-level emphasis [2]
    stats.LRHGE(k) = sum(pV.*c.^2.*r.^2)/C;
end

%%
clearvars -except stats





%% Short Run Emphasis [1]
% temp = 0;
% nr = 0;
% for j = 1:size(p,2)
%     for i = 1:size(p,1)
%         temp = temp + p(i,j)/j^2;
%         nr = nr + p(i,j);
%     end
% end
% 
% SRE = temp/nr

%% Long Run Emphasis [1]
% temp = 0;
% nr = 0;
% for j = 1:size(p,2)
%     for i = 1:size(p,1)
%         temp = temp + p(i,j)*j^2;
%         nr = nr + p(i,j);
%     end
% end
% 
% LRE = temp/nr

%% Gray Level Nonuniformity [1]
% temp1 = 0;
% temp2 = 0;
% nr = 0;
% for j = 1:size(p,2)
%     temp1 = 0;
%     for i = 1:size(p,1)
%         temp1 = temp1 + p(i,j);
%         nr = nr + p(i,j);
%     end
%     temp1 = temp1^2;
%     temp2 = temp2 + temp1;
% end
% 
% GLNU = temp2/nr

%% Run Length Nonuniformity [1]
% temp1 = 0;
% temp2 = 0;
% nr = 0;
% for i = 1:size(p,1)
%     temp1 = 0;
%     for j = 1:size(p,2)
%         temp1 = temp1 + p(i,j);
%         nr = nr + p(i,j);
%     end
%     temp1 = temp1^2;
%     temp2 = temp2 + temp1;
% end
% 
% RLNU = temp2/nr

%% Run Percentage/Fraction [1]
% Fraction = nr/sum(mask(:))

%% Low gray-level run emphasis [2]
% temp = 0;
% nr = 0;
% for j = 1:size(p,2)
%     for i = 1:size(p,1)
%         temp = temp + p(i,j)/i^2;
%         nr = nr + p(i,j);
%     end
% end
% 
% LGRE = temp/nr

%% High gray-level run emphasis [2]
% temp = 0;
% nr = 0;
% for j = 1:size(p,2)
%     for i = 1:size(p,1)
%         temp = temp + p(i,j)*i^2;
%         nr = nr + p(i,j);
%     end
% end
% 
% HGRE = temp/nr

%% Short run low gray-level emphasis [2]
% temp = 0;
% nr = 0;
% for j = 1:size(p,2)
%     for i = 1:size(p,1)
%         temp = temp + p(i,j)/(i^2*j^2);
%         nr = nr + p(i,j);
%     end
% end
% 
% SRLGE = temp/nr

%% Short run high gray-level emphasis [2]
% temp = 0;
% nr = 0;
% for j = 1:size(p,2)
%     for i = 1:size(p,1)
%         temp = temp + p(i,j)*i^2/j^2;
%         nr = nr + p(i,j);
%     end
% end
% SRHGE = temp/nr

%% Long run low gray-level emphasis [2]
% temp = 0;
% nr = 0;
% for j = 1:size(p,2)
%     for i = 1:size(p,1)
%         temp = temp + p(i,j)*j^2/i^2;
%         nr = nr + p(i,j);
%     end
% end
% 
% LRLGE = temp/nr

%% Long run high gray-level emphasis [2]
% temp = 0;
% nr = 0;
% for j = 1:size(p,2)
%     for i = 1:size(p,1)
%         temp = temp + p(i,j)*i^2*j^2;
%         nr = nr + p(i,j);
%     end
% end
% 
% LRHGE = temp/nr

