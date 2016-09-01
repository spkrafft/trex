function [image] = imageRead_pinnacle_extractX(extractWrite)
%%
image.array = [];

image.array_xV = extractWrite.image_xstart : extractWrite.image_xpixdim : extractWrite.image_xstart + (extractWrite.image_xdim-1)*extractWrite.image_xpixdim;
image.array_yV = fliplr(extractWrite.image_ystart : extractWrite.image_ypixdim : extractWrite.image_ystart + (extractWrite.image_ydim-1)*extractWrite.image_ypixdim);
% image.array_zV = extractWrite.image_zstart : extractWrite.image_zpixdim : extractWrite.image_zstart + (extractWrite.image_zdim-1)*extractWrite.image_zpixdim;

fid = fopen(fullfile(extractWrite.project_scandata,[extractWrite.image_name,'.ImageInfo']));
imageInfo = textscan(fid,'%s','delimiter','\n');
imageInfo = imageInfo{1};
fclose(fid);
imageInfo = splitParserX(imageInfo,'ImageInfo ={');   
    
image.array_zV = zeros(1,numel(imageInfo));
for i = 1:numel(imageInfo)
    image.array_zV(1,i) = str2double(textParserX(imageInfo{i},'TablePosition = '));
end
clear imageInfo

image.array = zeros([extractWrite.image_ydim,extractWrite.image_xdim,extractWrite.image_zdim],'uint16'); 

if extractWrite.image_byteorder == 0
    byte_order = 'l';
else
    byte_order = 'b';
end

if extractWrite.image_bitpix ~= 16
    error('Image bitpix not 16')
end

fid = fopen(fullfile(extractWrite.project_scandata,[extractWrite.image_name,'.img']));
for i=1:extractWrite.image_zdim
    image.array(:,:,i) = reshape(fread(fid,extractWrite.image_xdim*extractWrite.image_ydim,'uint16',byte_order),extractWrite.image_ydim,extractWrite.image_xdim)';
end

fclose(fid);

%%
clearvars -except image
