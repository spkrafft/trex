function [roi] = roi2Mask_pinnacle_extractX(extractWrite,entry)
%%
roi = [];
roi.data = cell(0);

roi.mask = false(extractWrite.image_ydim,extractWrite.image_xdim,extractWrite.image_zdim);

roi.array_xV = load(fullfile(extractWrite.project_patient,extractWrite.image_file),'array_xV');
roi.array_xV = roi.array_xV.array_xV;
roi.array_yV = load(fullfile(extractWrite.project_patient,extractWrite.image_file),'array_yV');
roi.array_yV = roi.array_yV.array_yV;
roi.array_zV = load(fullfile(extractWrite.project_patient,extractWrite.image_file),'array_zV');
roi.array_zV = roi.array_zV.array_zV;

fid = fopen(fullfile(extractWrite.project_roidata,'plan.roi'));
roi1 = textscan(fid,'%s','delimiter','\n');
roi1 = roi1{1};
fclose(fid);

roidata = splitParserX(roi1,'roi={');
clear roi1

namelist = cell(0);
for cellInd = 1:numel(roidata)
    namelist{end+1,1} = textParserX(roidata{cellInd},'name');
end
%%
if ~isempty(extractWrite.roi_source)
    sourcenames = regexpi(extractWrite.roi_source,'/','split');

    for i = 1:length(sourcenames)
        disp(['TREX-RT>> Entry ',num2str(entry),': Creating ROI source mask for ',sourcenames{i}])
        [tempMask,roi] = findroi(extractWrite,sourcenames{i},roi,roidata,namelist);
        roi.mask = roi.mask | tempMask;
    end
end

if ~isempty(extractWrite.roi_int)
    intnames = regexpi(extractWrite.roi_int,'/','split');

    for i = 1:length(intnames)
        disp(['TREX-RT>> Entry ',num2str(entry),': Creating ROI avoid interior mask for ',intnames{i}])
        [tempMask,roi] = findroi(extractWrite,intnames{i},roi,roidata,namelist);
        roi.mask = roi.mask & ~tempMask;
    end
end

if ~isempty(extractWrite.roi_ext)
    extnames = regexpi(extractWrite.roi_ext,'/','split');

    for i = 1:length(extnames)
        disp(['TREX-RT>> Entry ',num2str(entry),': Creating ROI avoid exterior mask for ',extnames{i}])
        [tempMask,roi] = findroi(extractWrite,extnames{i},roi,roidata,namelist);
        roi.mask = roi.mask & tempMask;
    end
end

%%
clearvars -except roi

%--------------------------------------------------------------------------
function [mask,roi] = findroi(extractWrite,roiname,roi,roidata,namelist)
%%
if sum(strcmp(roiname,namelist)) == 1
    cellInd = find(strcmp(roiname,namelist));
    [mask,roi] = roi2mask(extractWrite,cellInd,roi,roidata);

elseif ~isempty(regexpi(roiname,'Subvolume: (\w*)'))
    subvolume = roiname(regexpi(roiname,'Subvolume: (\w*)'):end-1);
    roiname = roiname(1:regexpi(roiname,'Subvolume: (\w*)')-3);

    cellInd = find(strcmp(roiname,namelist));
    [mask,roi] = roi2mask(extractWrite,cellInd,roi,roidata);
    mask = roisubvolumes_extractX(subvolume,mask);    
    
elseif ~isempty(regexpi(roiname,extractWrite.dose_name))
    isodose = str2double(roiname(regexpi(roiname,'[0-9]')));
    mask = false(extractWrite.image_ydim,extractWrite.image_xdim,extractWrite.image_zdim);
    
    array = load(fullfile(extractWrite.project_patient,extractWrite.dose_file),'array');
    mask(array.array >= isodose) = 1;
    
else
    error('Something wrong in roi2mask')
end

%%
clearvars -except mask roi

%--------------------------------------------------------------------------
function [mask,roi] = roi2mask(extractWrite,cellInd,roi,roidata)
%%
mask = false(extractWrite.image_ydim,extractWrite.image_xdim,extractWrite.image_zdim);

curveCell = splitParserX(roidata{cellInd},'points={');
roi.data{end+1} = roidata{cellInd};

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

%Defined here to limit overhead to parfor
tempMask = cell(1,numel(curveData));
xdim = extractWrite.image_xdim;
ydim = extractWrite.image_ydim;
xV = roi.array_xV;
yV = roi.array_yV;

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
                
        slice = find(round(z(1)*1000)/1000==round(roi.array_zV*1000)/1000);
        
        if isempty(slice)
            slice = find(round(z(1)*100)/100==round(roi.array_zV*100)/100);
        end
        
        if isempty(slice)
            slice = find(round(z(1)*10)/10==round(roi.array_zV*10)/10);
        end
        
        mask(:,:,slice)=xor(mask(:,:,slice),tempMask{i});
    end
end

%%
clearvars -except mask roi

