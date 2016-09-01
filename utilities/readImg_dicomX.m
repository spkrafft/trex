function [img] = readImg_dicomX(data_dir,SeriesInstanceUID)

select = strcmpi({data_dir.dicom_SeriesInstanceUID}, SeriesInstanceUID);

if sum(select) == 0
    img = nan;
else
    filename = {data_dir(select).dicom_Filename};
    number = [data_dir(select).dicom_InstanceNumber];
    slope = [data_dir(select).dicom_RescaleSlope];
    intercept = [data_dir(select).dicom_RescaleIntercept];

    [~,ind] = sort(number);
    filename = filename(ind);

    %%
    img = [];
    for i = 1:numel(filename)
       img(:,:,i) = dicomread(filename{i}); 
       img(:,:,i) = img(:,:,i)*slope(i) + intercept(i);
    end

    img = img + 1000;
    img(img<0) = 0;
end

clearvars -except img