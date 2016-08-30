function [array] = vector2array_mapX(map_file,feature_name,Interp)

map = load(map_file);
%%
array = nan(size(map.I));

index = map.Y(:,2) + (map.X(:,2)-1)*size(array,1) + (map.Z(:,2)-1)*size(array,1)*size(array,2);

%%
if all(isnan(map.(feature_name)))
    return
else
    array(index) = map.(feature_name)(:);
end

%%
tsize = size(map.I);

pixdim = nan(1, ndims(map.I));
%%
% pixdim(1) = 500/512*(str2double(map.parameter_block_size) - str2double(map.parameter_overlap)); %x spacing
% pixdim(2) = 500/512*(str2double(map.parameter_block_size) - str2double(map.parameter_overlap)); %y spacing

pixdim(1) = map.image_xpixdim*(str2double(map.parameter_block_size) - str2double(map.parameter_overlap)); %x spacing
pixdim(2) = map.image_ypixdim*(str2double(map.parameter_block_size) - str2double(map.parameter_overlap)); %y spacing
%%

if isfield(map,'parameter_offset')
    if strcmpi(map.parameter_offset,'2D')
        pixdim(3) = map.image_zpixdim; %z spacing
        
        rows = unique(map.Y(:,2));
        cols = unique(map.X(:,2));

        array = array(rows,cols,:);
        
    elseif strcmpi(map.parameter_offset,'3D')
       error('3d really needs to be checked...') 
       %pixdim(3) = map.image_zpixdim*(str2double(map.parameter_block_size) - str2double(map.parameter_overlap)); %z spacing
    else
        error('here')
    end
elseif isfield(map,'parameter_dim')
    if strcmpi(map.parameter_dim,'2D')
        pixdim(3) = map.image_zpixdim; %z spacing
        
        rows = unique(map.Y(:,2));
        cols = unique(map.X(:,2));

        array = array(rows,cols,:);
        
    elseif strcmpi(map.parameter_dim,'3D')
       error('3d really needs to be checked...') 
       %pixdim(3) = map.image_zpixdim*(str2double(map.parameter_block_size) - str2double(map.parameter_overlap)); %z spacing
    else
        error('here')
    end
end

%%
% ind_nan = isnan(array);
% rows = all(all(ind_nan,3),2);
% array(rows,:,:) = [];
% 
% ind_nan = isnan(array);
% cols = all(all(ind_nan,3),1);
% array(:,cols,:) = [];
% 
% ind_nan = isnan(array);
% slices = all(all(ind_nan,2),1);
% array(:,:,slices) = [];

%%
switch Interp
    case 'reduce'
       %Do nothing else 
    otherwise
        array = imresize3DX(array,pixdim,tsize,Interp);
        
        mask = double(map.mask);
        mask(mask==0) = NaN;
        array = mask.*array;
end

%%
clearvars -except array
