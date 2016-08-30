function [stats] = glcm_features(glcm)
%GLCM_FEATURES Properties of gray-level co-occurrence matrix.  
%   [STATS] = GLCM_FEATURES(GLCM) normalizes the gray-level
%   co-occurrence matrix (GLCM) so that the sum of its elements is one. Each
%   element in the normalized GLCM, (r,c), is the joint probability occurrence
%   of pixel pairs with a defined spatial relationship having gray level
%   values r and c in the image. GLCM_FEATURES uses the normalized GLCM to
%   calculate the features.
%
%   GLCM can be an m x n x p array of valid gray-level co-occurrence
%   matrices. Each gray-level co-occurrence matrix is normalized so that its
%   sum is one.
%  
%   STATS is a structure with fields determined from ref [1]. Each
%   field contains a 1 x p array, where p is the number of gray-level
%   co-occurrence matrices in GLCM.
%
%   Notes
%   -----  
% 
%   Class Support
%   -------------  
%   GLCM can be log2ical or numeric, and it must contain real, non-negative, finite,
%   integers. STATS is a structure.
%
%   Examples
%   --------
%   GLCM = [0 1 2 3;1 1 2 3;1 0 2 0;0 0 0 3];
%   stats = glcm_features(GLCM)
%
%   I = imread('circuit.tif');
%   GLCM2 = glcm_matrix3D(I,'Offset',[1 0 0;0 1 0]);
%   stats = glcm_features(GLCM2)
%  
%   See also GLCM_MATRIX3D.
%
%   References
%   ----------
%   [1] R. M. Haralick, K. Shanmugam, and I. Dinstein, Textural Features of
%       Image Classification, IEEE Transactions on Systems, Man and Cybernetics,
%       vol. SMC-3, no. 6, Nov. 1973
%   [2] Aerts, Hugo JWL et al. "Decoding tumour phenotype by noninvasive 
%       imaging using a quantitative radiomics approach." Nature communications 
%       5 (2014).
%
%   $SPK

%%
numGLCM = size(glcm,3);

for k = 1:numGLCM
    if numGLCM ~= 1
        p = glcm(:,:,k);
    else
        p = glcm;
    end
    
    % Normalize glcm so that sum(glcm(:)) is one.
    if any(glcm(:))
      p = p ./ sum(p(:));
    end
    
    vecp = p(:);
  
    % Get row and column subscripts of GLCM.  These subscripts correspond to the
    % pixel values in the GLCM.
    s = size(p);
    [c,r] = meshgrid(1:s(1),1:s(2));
    r = r(:);
    c = c(:);
    sumrc = r+c;
    diffrc = abs(r-c);
    
    pX = sum(p,2);
    pY = transpose(sum(p,1));
    
    for i = min(sumrc(:)):max(sumrc(:))
        pXplusY(i-1) = sum(vecp(sumrc==i)); 
    end
        
    for i = min(diffrc(:)):max(diffrc(:))
        pXminusY(i+1) = sum(vecp(diffrc==i)); 
    end
  
    mX = sum(r.*p(:));
    stdX = sqrt(sum((r-mX).^2.*p(:)));    
    mY = sum(c.*p(:));
    stdY = sqrt(sum((c-mY).^2.*p(:)));
        
    HX = -sum(pX.*log2(pX+eps));
    HY = -sum(pY.*log2(pY+eps));
    HXY = -sum(p(:).*log2(p(:)+eps));
    HXY1 = -sum(p(:).*log2(pX(r).*pY(c)+eps));
    HXY2 = -sum(pX(r).*pY(c).*log2(pX(r).*pY(c)+eps));
    
    %% Begin calculations of the texture features
    
    %Autocorrelation [2]
    stats.AutoCorrelation(k) = sum(r.*c.*p(:));
    
    %Cluster prominence [2]
    stats.ClusterProminence(k) = sum((r+c-mX-mY).^4.*p(:));
    
    %Cluster shade [2]
    stats.ClusterShade(k) = sum((r+c-mX-mY).^3.*p(:));
    
    %Cluster tendency [2] (same as SumVariance in [1])
    stats.ClusterTendency(k) = sum((r+c-mX-mY).^2.*p(:));
    
    %Contrast [2]
    stats.Contrast(k) = sum((abs(r-c).^2).*p(:));   
    
    %Correlation [1]
    stats.Correlation(k) = (sum(r.*c.*p(:))-mX*mY)/(stdX*stdY+eps);
    
    %Difference Entropy [1]
    stats.DiffEntropy(k) = -sum(pXminusY.*log2(pXminusY+eps));   
    
    %Dissimilarity [2]
    stats.Dissimilarity(k) = sum((abs(r-c)).*p(:));
    
    %Angular Second Moment/AKA Energy [1]
    stats.Energy(k) = sum(p(:).^2);
    
    %Entropy [1]
    stats.Entropy(k) = -sum(p(:).*log2(p(:)+eps));
    
    %Homogeneity 1 [2]
    stats.Homogeneity1(k) = sum(p(:)./(1+abs(r-c)));
    
    %Homogeneity 2 [2]
    stats.Homogeneity2(k) = sum(p(:)./(1+abs(r-c).^2));
    
    %Information Measures of Correlation [1]
    stats.InfoMC1(k) = (HXY-HXY1)/max([HX HY]);
    stats.InfoMC2(k) = sqrt(1-exp(-2*(HXY2-HXY)));
    
    %Inverse difference moment normalized [2]
    stats.InDiffMomNorm(k) = sum(p(:)./(1+abs(r-c).^2/size(p,1)^2));
        
    %Inverse Difference Moment [1]
    stats.InDiffMom(k) = sum(p(:)./(1+(r-c).^2));
    
    %Inverse difference normalized [2]
    stats.InDiffNorm(k) = sum(p(:)./(1+abs(r-c)/size(p,1)));
    
    %Inverse variance [2]
    t1 = p(:);
    t2 = abs(r-c).^2;
    bad = t2 == 0;
    t1(bad) = [];
    t2(bad) = [];
    stats.InVariance(k) = sum(t1./t2);
    
    %Max probability [2]
    stats.MaxProb(k) = max(p(:));
    
    %Sum Average [1]
    stats.SumAverage(k) = sum((min(sumrc(:)):max(sumrc(:))).*pXplusY);
    
    %Sum Entropy [1]
    stats.SumEntropy(k) = -sum(pXplusY.*log2(pXplusY+eps));
    
    %Sum variance [2] (difference than sum variance in [1], which is equivalent to ClusterTendency)
    stats.SumVariance(k) = sum((((min(sumrc(:)):max(sumrc(:)))-stats.SumEntropy(k)).^2).*pXplusY);
    
    %Variance [2] (same as Sum of Squares Variance in [1])
    stats.Variance(k) = sum(((r-mean(p(:))).^2).*p(:));
end

%%
clearvars -except stats
