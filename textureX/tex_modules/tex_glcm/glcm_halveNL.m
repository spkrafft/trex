function [glcm_out] = glcm_halveNL(glcm)
%GLCM_HALVENL Reduce number of gray levels in glcm by factor of 2 
%   [GLCM] = GLCM_HALVENL(GLCM) combines neighboring rows and columns of
%   glcm to achieve reduced bit depth glcm
%
%   GLCM can be an m x n x p array of valid gray-level co-occurrence
%   matrices. 
%  
%   Notes
%   -----  
% 
%   Class Support
%   -------------  
%   GLCM can be log2ical or numeric, and it must contain real, non-negative, finite,
%   integers.
%
%   Examples
%   --------
%   GLCM = [0 1 2 3;1 1 2 3;1 0 2 0;0 0 0 3];
%   GLCM = glcm_halveNL(GLCM)
%
%   See also GLCM_MATRIX3D.
%
%   References
%   ----------
%
%   $SPK

%%
numGLCM = size(glcm,3);
glcm_out = nan(size(glcm,1)/2,size(glcm,2)/2,size(glcm,3));

for k = 1:numGLCM
    
    glcm_r1 = glcm(1:2:end,:,k);
    glcm_r2 = glcm(2:2:end,:,k);

    glcm_r = glcm_r1+glcm_r2;

    glcm_c1 = glcm_r(:,1:2:end);
    glcm_c2 = glcm_r(:,2:2:end);

    glcm_out(:,:,k) = glcm_c1+glcm_c2;
end

%%
clearvars -except glcm_out
