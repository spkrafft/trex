function [mask] = pinnacle_roi2Mask_setupX(h)
%%
mask = false(h.export.image_ydim,h.export.image_xdim,h.export.image_zdim);

if ~isempty(h.export.roi_source)
    sourcenames = regexpi(h.export.roi_source,'/','split');

    for i = 1:length(sourcenames)
        tempMask = findroi(h,sourcenames{i});
        mask = mask | tempMask;
    end
end

if ~isempty(h.export.roi_int)
    intnames = regexpi(h.export.roi_int,'/','split');

    for i = 1:length(intnames)
        tempMask = findroi(h,intnames{i});
        mask = mask & ~tempMask;
    end
end

if ~isempty(h.export.roi_ext)
    extnames = regexpi(h.export.roi_ext,'/','split');

    for i = 1:length(extnames)
        tempMask = findroi(h,extnames{i});
        mask = mask & tempMask;
    end
end

%%
clearvars -except mask

function [mask] = findroi(h,roiname)
%%
disp(['TREX-RT>> Generating ',roiname,' mask...'])

if sum(strcmp(roiname,h.roi_namelist)) == 1
    cellInd = find(strcmp(roiname,h.roi_namelist));
    [mask] = roi2mask(h,cellInd);
elseif ~isempty(regexpi(roiname,h.export.dose_name))
    isodose = str2double(roiname(regexpi(roiname,'[0-9]')));
    mask = false(h.export.image_ydim,h.export.image_xdim,h.export.image_zdim);
    mask(h.dose.interpArray >= isodose) = 1;
else
    error('Something wring in roi2mask')
end

disp(['TREX-RT>> ',roiname,' mask completed!'])

%%
clearvars -except mask

%--------------------------------------------------------------------------
function [mask] = roi2mask(h,cellInd)
%%
mask = false(h.export.image_ydim,h.export.image_xdim,h.export.image_zdim);

curveCell = splitParserX(h.roi.data{cellInd},'points={');

curveData = cell(numel(curveCell),1);

parfor i = 1:numel(curveCell)
    endjunk = splitParserX(curveCell{i},'End of points');
    tempCurve = curveCell{i}(2:numel(curveCell{i})-numel(endjunk{1}));

    for j = 1:numel(tempCurve)
        points = cell2mat(textscan(tempCurve{j},'%f %f %f'));
        curveData{i}(j,:) = points;
    end
end

clear endjunk points tempCurve curveCell

tempMask = cell(1,numel(curveData));
xdim = numel(h.img.array_xV);
ydim = numel(h.img.array_yV);
xV = h.img.array_xV;
yV = h.img.array_yV;

parfor i = 1:numel(curveData)
    if ~isempty(curveData{i})
        x = curveData{i}(:,1);
        y = curveData{i}(:,2);

        [~,~,~,tempMask{i},~,~] = roifill(xV,yV,zeros([xdim,ydim]),x,y);
    end
end

for i = 1:numel(curveData)
    if ~isempty(curveData{i})
        z = curveData{i}(:,3);

        slice = find(round(z(1)*1000)/1000==round(h.img.array_zV*1000)/1000);
        
        if isempty(slice)
            slice = find(round(z(1)*100)/100==round(h.img.array_zV*100)/100);
        end
        
        if isempty(slice)
            slice = find(round(z(1)*10)/10==round(h.img.array_zV*10)/10);
        end
        
        mask(:,:,slice)=xor(mask(:,:,slice),tempMask{i});
    end
end

%%
clearvars -except mask
