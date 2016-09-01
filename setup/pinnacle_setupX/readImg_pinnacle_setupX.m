function [img] = readImg_pinnacle_setupX(h)
%%
disp('TREX-RT>> Reading image...')

if h.export.remote
    cd(h.ftp,h.export.patient_path);
    drawnow; pause(0.1);
    img_file = mget(h.ftp,[h.export.image_name,'.img'],h.export.project_path);
    img_file = img_file{1};
    cd(h.ftp,h.export.home_path);
else
    copyfile(fullfile(h.export.patient_path,[h.export.image_name,'.img']),h.export.project_path);
    img_file = fullfile(h.export.project_path,[h.export.image_name,'.img']);
end 

img = zeros([h.export.image_ydim,h.export.image_xdim,h.export.image_zdim],'uint16'); 

if ~h.export.image_byteorder
    byte_order = 'l';
else
    byte_order = 'b';
end

fid = fopen(img_file);
for i=1:h.export.image_zdim
    img(:,:,i) = reshape(fread(fid,h.export.image_xdim*h.export.image_ydim,'uint16',byte_order),h.export.image_ydim,h.export.image_xdim)';
end
fclose(fid);

delete(img_file)

%%
clearvars -except img
