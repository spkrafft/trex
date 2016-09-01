function reformat_projectX(crop,tsize)

% crop = true;
% tsize = [20,30,10];
%%
project_path = uigetdir(pwd,'Select Project Directory');

if crop
    project_path_reformat = [project_path,' Crop and Reformat ',num2str(tsize)];
else
    project_path_reformat = [project_path,' Reformat ',num2str(tsize)];
end

mkdir(project_path_reformat)

copyfile(project_path,project_path_reformat)

cleanup_log_reformat(project_path_reformat) %This completely gets rid of the texture and dose stuff.

% remove_doseX(project_path_reformat)
% remove_textureX(project_path_reformat)

migration_projectX(project_path_reformat)

cleanup_log_reformat(project_path_reformat) %This completely gets rid of the texture and dose stuff.

cleanup_projectX(project_path_reformat)

project_path = project_path_reformat;

extractRead = read_extractX(project_path,false);
%% Image...
xpixdim = [];
ypixdim = [];
zpixdim = [];

h = waitbar(0,'Image Reformat In Progress...');
for entry = 1:numel(extractRead.patient_mrn)
    image = load(fullfile(extractRead.project_patient{entry},extractRead.image_file{entry}));
    mask = load(fullfile(extractRead.project_patient{entry},extractRead.roi_file{entry}));
    
    fnames = fieldnames(image);
    ind = ~cellfun(@isempty, regexpi(fnames,'^dicom_*|ftp'));
    image = rmfield(image,fnames(ind));
    
    if crop
        [image.array,~,image.array_xV,image.array_yV,image.array_zV] = prepCrop(image.array,mask.mask,'Pad',[0,0,0]);
    end

    [image.array, RB] = imresize3DX(image.array,[image.image_xpixdim,image.image_ypixdim,image.image_zpixdim],tsize,'linear');
    
    image.image_xdim = tsize(2); 
    image.image_ydim = tsize(1); 
    image.image_zdim = tsize(3); 
    
    image.image_xpixdim = RB.PixelExtentInWorldX;
    image.image_ypixdim = RB.PixelExtentInWorldY;
    image.image_zpixdim = RB.PixelExtentInWorldZ;
    
    xpixdim(entry,1) = RB.PixelExtentInWorldX;
    ypixdim(entry,1) = RB.PixelExtentInWorldY;
    zpixdim(entry,1) = RB.PixelExtentInWorldZ;

    image.image_xstart = 0; 
    image.image_ystart = 0; 
    image.image_zstart = 0; 

    image.array_xV = RB.PixelExtentInWorldX*(0:tsize(2)-1);
    image.array_yV = RB.PixelExtentInWorldY*(0:tsize(1)-1);
    image.array_zV = RB.PixelExtentInWorldZ*(0:tsize(3)-1);

    save(fullfile(extractRead.project_patient{entry},extractRead.image_file{entry}),'-struct','image');   
    
    clear image
    clear mask
    
    waitbar(entry/numel(extractRead.patient_mrn),h)
end

close(h)

%% Update the setup and extract log files with new image dim/pixdim/start
setupRead = read_setupX(project_path,false);

fnames = fieldnames(setupRead);
ind = ~cellfun(@isempty, regexpi(fnames,'^dicom_*|ftp'));
setupRead = rmfield(setupRead,fnames(ind));

setupRead.image_xdim = repmat(tsize(2),numel(setupRead.patient_mrn),1); 
setupRead.image_ydim = repmat(tsize(1),numel(setupRead.patient_mrn),1);  
setupRead.image_zdim = repmat(tsize(3),numel(setupRead.patient_mrn),1);  

setupRead.image_xpixdim = xpixdim;
setupRead.image_ypixdim = ypixdim;
setupRead.image_zpixdim = zpixdim;

setupRead.image_xstart = zeros(numel(setupRead.patient_mrn),1);
setupRead.image_ystart = zeros(numel(setupRead.patient_mrn),1);
setupRead.image_zstart = zeros(numel(setupRead.patient_mrn),1);

filename = [datestr(now,'yyyymmddHHMMSS'),'_','setup','X.mat'];
save(fullfile(project_path,'Log',filename),'-struct','setupRead') 

pause(1)

extractRead = read_extractX(project_path,false);

fnames = fieldnames(extractRead);
ind = ~cellfun(@isempty, regexpi(fnames,'^dicom_*|ftp'));
extractRead = rmfield(extractRead,fnames(ind));

extractRead.image_xdim = repmat(tsize(2),numel(extractRead.patient_mrn),1); 
extractRead.image_ydim = repmat(tsize(1),numel(extractRead.patient_mrn),1);  
extractRead.image_zdim = repmat(tsize(3),numel(extractRead.patient_mrn),1);  

extractRead.image_xpixdim = xpixdim;
extractRead.image_ypixdim = ypixdim;
extractRead.image_zpixdim = zpixdim;

extractRead.image_xstart = zeros(numel(setupRead.patient_mrn),1);
extractRead.image_ystart = zeros(numel(setupRead.patient_mrn),1);
extractRead.image_zstart = zeros(numel(setupRead.patient_mrn),1);

filename = [datestr(now,'yyyymmddHHMMSS'),'_','extract','X.mat'];
save(fullfile(project_path,'Log',filename),'-struct','extractRead') 

%% Dose...
h = waitbar(0,'Dose Reformat In Progress...');
for entry = 1:numel(extractRead.patient_mrn)
    if ~isempty(extractRead.dose_file{entry})
        dose = load(fullfile(extractRead.project_patient{entry},extractRead.dose_file{entry}));
        mask = load(fullfile(extractRead.project_patient{entry},extractRead.roi_file{entry}));
        
        fnames = fieldnames(dose);
        ind = ~cellfun(@isempty, regexpi(fnames,'^dicom_*|ftp'));
        dose = rmfield(dose,fnames(ind));
        
        if crop
            [dose.array,~,dose.array_xV,dose.array_yV,dose.array_zV] = prepCrop(dose.array,mask.mask,'Pad',[0,0,0]);
        end

        [dose.array, RB] = imresize3DX(dose.array,[dose.image_xpixdim,dose.image_ypixdim,dose.image_zpixdim],tsize,'linear');

        dose.image_xdim = tsize(2); 
        dose.image_ydim = tsize(1); 
        dose.image_zdim = tsize(3); 

        dose.image_xpixdim = RB.PixelExtentInWorldX;
        dose.image_ypixdim = RB.PixelExtentInWorldY;
        dose.image_zpixdim = RB.PixelExtentInWorldZ;

        dose.image_xstart = 0; 
        dose.image_ystart = 0; 
        dose.image_zstart = 0; 

        dose.array_xV = RB.PixelExtentInWorldX*(0:tsize(2)-1);
        dose.array_yV = RB.PixelExtentInWorldY*(0:tsize(1)-1);
        dose.array_zV = RB.PixelExtentInWorldZ*(0:tsize(3)-1);

        save(fullfile(extractRead.project_patient{entry},extractRead.dose_file{entry}),'-struct','dose');    
        
        clear dose
        clear mask
        
        waitbar(entry/numel(extractRead.patient_mrn),h)
    end
end

close(h)

%% Maps
map_parameters = parameterfields_mapX([]);   
for mCount = 1:numel(map_parameters.module_names)
    h = waitbar(0,[upper(map_parameters.module_names{mCount}),' Map Reformat In Progress...']);
    
    mapRead = read_mapX(project_path, map_parameters.module_names{mCount},false);
    
    if ~isempty(mapRead.map_file)
        fnames = fieldnames(mapRead);
        ind = ~cellfun(@isempty, regexpi(fnames,'^dicom_*|ftp'));
        mapRead = rmfield(mapRead,fnames(ind));

        feature_names = fieldnames(feval([map_parameters.module_names{mCount},'_features'],0));

        for entry = 1:numel(mapRead.patient_mrn)
            map_file = fullfile(mapRead.project_patient{entry},'mapX',mapRead.map_file{entry});
            map = load(map_file);

            fnames = fieldnames(map);
            ind = ~cellfun(@isempty, regexpi(fnames,'^dicom_*|ftp'));
            map = rmfield(map,fnames(ind));

            pixdim = [map.image_xpixdim,map.image_ypixdim,map.image_zpixdim];

            mask = prepCrop(map.mask,map.mask,'Pad',[0,0,0]);
            mask = imresize3DX(mask,pixdim,tsize,'linear');

            for i = 1:numel(feature_names)
                if all(isnan(map.(feature_names{i})))
                    map = rmfield(map,feature_names{i});
                else
                    map.(feature_names{i}) = vector2array_mapX(map_file,feature_names{i},'linear');
                    map.(feature_names{i}) = prepCrop(map.(feature_names{i}),map.mask,'Pad',[0,0,0]);
                    map.(feature_names{i}) = imresize3DX(map.(feature_names{i}),pixdim,tsize,'linear');
                    map.(feature_names{i})(~mask) = nan;

                    map.(feature_names{i}) = map.(feature_names{i})(:);
                end
            end

            map.crop = prepCrop(map.crop,map.mask,'Pad',[0,0,0]);
            [map.crop, RB] = imresize3DX(map.crop,pixdim,tsize,'linear');

            map.mask = mask;
            map.I = map.crop;
            map.I(~map.mask) = nan;

            map.image_xdim = tsize(2); 
            map.image_ydim = tsize(1); 
            map.image_zdim = tsize(3); 

            map.image_xpixdim = RB.PixelExtentInWorldX;
            map.image_ypixdim = RB.PixelExtentInWorldY;
            map.image_zpixdim = RB.PixelExtentInWorldZ;

            map.image_xstart = 0; 
            map.image_ystart = 0; 
            map.image_zstart = 0; 

            map.array_xV = RB.PixelExtentInWorldX*(0:tsize(2)-1);
            map.array_yV = RB.PixelExtentInWorldY*(0:tsize(1)-1);
            map.array_zV = RB.PixelExtentInWorldZ*(0:tsize(3)-1);

            [x,y,z] = meshgrid(1:size(map.mask,2),1:size(map.mask,1),1:size(map.mask,3));

            map.X = nan(numel(map.mask),3);
            map.X(:,2) = x(:);
            map.Y = nan(numel(map.mask),3);
            map.Y(:,2) = y(:);
            map.Z = nan(numel(map.mask),3);
            map.Z(:,2) = z(:);

            save(map_file,'-struct','map');

            mapRead.image_xdim(entry) = tsize(2); 
            mapRead.image_ydim(entry) = tsize(1);  
            mapRead.image_zdim(entry) = tsize(3);  

            mapRead.image_xpixdim(entry) = RB.PixelExtentInWorldX;
            mapRead.image_ypixdim(entry) = RB.PixelExtentInWorldY;
            mapRead.image_zpixdim(entry) = RB.PixelExtentInWorldZ;

            mapRead.image_xstart(entry) = 0; 
            mapRead.image_ystart(entry) = 0; 
            mapRead.image_zstart(entry) = 0; 

            clear map

            waitbar(entry/numel(mapRead.patient_mrn),h)
        end

        filename = [datestr(now,'yyyymmddHHMMSS'),'_',map_parameters.module_names{mCount},'_mapX.mat'];
        save(fullfile(project_path,'Log',filename),'-struct','mapRead') 
    end
    
    clear mapRead
    
    close(h)
end

%% Mask...
h = waitbar(0,'Mask Reformat In Progress...');
for entry = 1:numel(extractRead.patient_mrn)
    mask = load(fullfile(extractRead.project_patient{entry},extractRead.roi_file{entry}));
    
    fnames = fieldnames(mask);
    ind = ~cellfun(@isempty, regexpi(fnames,'^dicom_*|ftp'));
    mask = rmfield(mask,fnames(ind));
    
    if crop
        [mask.mask,~,mask.array_xV,mask.array_yV,mask.array_zV] = prepCrop(mask.mask,mask.mask,'Pad',[0,0,0]);
    end

    [mask.mask, RB] = imresize3DX(mask.mask,[mask.image_xpixdim,mask.image_ypixdim,mask.image_zpixdim],tsize,'linear');
    
    mask.image_xdim = tsize(2); 
    mask.image_ydim = tsize(1); 
    mask.image_zdim = tsize(3); 
    
    mask.image_xpixdim = RB.PixelExtentInWorldX;
    mask.image_ypixdim = RB.PixelExtentInWorldY;
    mask.image_zpixdim = RB.PixelExtentInWorldZ;

    mask.image_xstart = 0; 
    mask.image_ystart = 0; 
    mask.image_zstart = 0; 

    mask.array_xV = RB.PixelExtentInWorldX*(0:tsize(2)-1);
    mask.array_yV = RB.PixelExtentInWorldY*(0:tsize(1)-1);
    mask.array_zV = RB.PixelExtentInWorldZ*(0:tsize(3)-1);

    save(fullfile(extractRead.project_patient{entry},extractRead.roi_file{entry}),'-struct','mask');    
    
    clear mask
    
    waitbar(entry/numel(extractRead.patient_mrn),h)
end

%%

close(h)

disp('Reformat Complete!')

clearvars

%--------------------------------------------------------------------------
function cleanup_log_reformat(project_path_reformat)

%%
modules = {'setup',...
           'extract'};
       
% dose = parameterfields_doseX([]);
% tex = parameterfields_textureX([]);  
map = parameterfields_mapX([]);      

% modules = [modules,dose.module_names,tex.module_names,map.module_names];
modules = [modules,strcat(map.module_names,'_map')];
 
rundata = cell(0);
for i = 1:numel(modules)
    date = getDate_logX(project_path_reformat,modules{i});
    rundata{end+1,1} = modules{i};
    rundata{end,2} = date;
end
%%
filenames = cell(0);
list = dir(fullfile(project_path_reformat,'Log'));
for i = 1:numel(list)
    if ~isempty(regexpi(list(i).name,'.mat$')) || ~isempty(regexpi(list(i).name,'.xlog$'))
        filenames{end+1,1} = list(i).name;
    end
end

%%
keep = false(size(filenames));
for i = 1:size(rundata,1)    
    if rundata{i,2} ~= 0
        keep = ~cellfun(@isempty,regexpi(filenames,[num2str(rundata{i,2}),'_',rundata{i,1},'(\w*)X.mat'])) | keep;
    end
end

%%
[s,mess,messid] = mkdir(fullfile(project_path_reformat,'Log'),'old');

for i = 1:numel(keep)
    if ~keep(i)
        %filenames{i}
        movefile(fullfile(project_path_reformat,'Log',filenames{i}),fullfile(project_path_reformat,'Log','old',filenames{i}))
    end
end

%%
clearvars
