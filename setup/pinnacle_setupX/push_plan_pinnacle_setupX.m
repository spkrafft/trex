function [h] = push_plan_pinnacle_setupX(h)
%%
h = suspendhandles_pinnacle_setupX(h);

disp('TREX-RT>> Plan selected!');
disp(['TREX-RT>> Plan Directory: ',h.export.plan_path]);

for cellInd = 1:numel(h.filedata.plandata)
    [planid] = textParserX(h.filedata.plandata{cellInd},'PlanID ');
    if strcmpi(planid,h.export.plan_id)
        break
    end
end
    
h.roitoggle_curve = false;
h.dosetoggle = false;

%Work on the scan data*****************************************************
h.export.image_id = textParserX(h.filedata.plandata{cellInd},'PrimaryCTImageSetID ');
h.export.image_name = ['ImageSet_',h.export.image_id];
h.export.image_internalUID = dicomuid;

%Make sure that image set exists in the directory, or a different plan
%needs to be selected
if h.export.remote
    cd(h.ftp,h.export.patient_path);
    files = dir(h.ftp,h.export.patient_path);
    cd(h.ftp,h.export.home_path);
else
    files = dir(h.export.patient_path);    
end

found = false;
for i = 1:numel(files)
    if ~isempty(regexpi(files(i).name,[h.export.image_name,'+\.img$']))
        found = true;
        break
    end
end

if found
    disp(['TREX-RT>> Image name: ImageSet_',h.export.image_id]);
else
    disp('TREX-RT>> Associated image set does not exist!');
    msgbox('Associated image set does not exist!','Warning: SetupX','error')
    return
end

h = imageInfo_pinnacle_setupX(h);
h = dicomInfo_pinnacle_setupX(h);

h.active = 'main';
h.view_main = 'a';
h.view_minor1 = 's';
h.view_minor2 = 'c';

h.wl_current = 'Lung';
ind = strcmpi(h.wl_current,h.wl_presets);

h.window = h.wl_presets{ind,2};
h.level = h.wl_presets{ind,3};

bot = h.level-floor(h.window/2);
if bot < 0
    bot = 0;
end
top = h.level+ceil(h.window/2);
if top > 4095
    top = 4095;
end
h.range = [bot top];

h.main_z = round(h.export.image_zdim/2);
h.main_y = round(h.export.image_ydim/2);
h.main_x = round(h.export.image_xdim/2);

h.minor1_z = round(h.export.image_zdim/2);
h.minor1_y = round(h.export.image_ydim/2);
h.minor1_x = round(h.export.image_xdim/2);
        
h.minor2_z = round(h.export.image_zdim/2);
h.minor2_y = round(h.export.image_ydim/2);
h.minor2_x = round(h.export.image_xdim/2);

if h.imgtoggle
    h.img.array = readImg_pinnacle_setupX(h);
end

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

%Work on the roi data******************************************************
drawnow; pause(0.001);

disp('TREX-RT>> Getting ROI names...')

%Make sure that there is an ROI file for the plan
try
    if h.export.remote
        cd(h.ftp,h.export.plan_path);
        roiPath = mget(h.ftp,'plan.roi',h.export.project_path);
        roiPath = roiPath{1};
        cd(h.ftp,h.export.home_path);
    else
        copyfile(fullfile(h.export.plan_path,'plan.roi'),h.export.project_path);
        roiPath = fullfile(h.export.project_path,'plan.roi');
    end
catch err
    disp('TREX-RT>> No ROI data exists for this plan!');
    return
end

%Find roi names
h.roi_namelist = cell(0);

fid = fopen(roiPath);
h.filedata.roi = textscan(fid,'%s','delimiter','\n');
h.filedata.roi = h.filedata.roi{1};
fclose(fid);

delete(roiPath)

h.export.roi_internalUID = dicomuid;

h.roi.data = splitParserX(h.filedata.roi,'roi={');

for cellInd = 1:numel(h.roi.data)
    name = textParserX(h.roi.data{cellInd},'name');
    
    if strcmpi(textParserX(h.roi.data{cellInd},'curve={'),' ')
        disp(['TREX-RT>> Found ROI:  ',name,' but it has no curve data'])
    else
        [h.roi_namelist{end+1,1}] = name;
        disp(['TREX-RT>> Found ROI:  ',h.roi_namelist{end,1}])
    end
end

disp(['TREX-RT>> Detected ',num2str(numel(h.roi_namelist)),' ROIs!'])

%Work on the dose data*****************************************************
doseexist = true;

drawnow; pause(0.001);

disp('TREX-RT>> Getting plan dose trial names...')

try
    if h.export.remote
        cd(h.ftp,h.export.plan_path);
        trialPath = mget(h.ftp,'plan.Trial',h.export.project_path);
        trialPath = trialPath{1};
        cd(h.ftp,h.export.home_path);
    else
        copyfile(fullfile(h.export.plan_path,'plan.Trial'),h.export.project_path);
        trialPath = fullfile(h.export.project_path,'plan.Trial');
    end
catch err
    disp('TREX-RT>> No trial data exists for this plan!')
    doseexist = false;
end

%**************************************************************************
restorehandles_pinnacle_setupX(h)

set(h.drop_preset,'String',h.wl_presets(:,1))
set(h.edit_window,'String',num2str(h.window));
set(h.slider_window,'Value',h.window);
set(h.slider_level,'Value',h.level);
set(h.edit_level,'String',num2str(h.level));

set(h.menu_displayscan,'Enable','on')
set(h.slider_level,'Enable','on')
set(h.text_window,'Enable','on')
set(h.text_level,'Enable','on')
set(h.edit_level,'Enable','on')
set(h.edit_window,'Enable','on')
set(h.text_preset,'Enable','on')
set(h.drop_preset,'Enable','on')
set(h.slider_window,'Enable','on')
set(h.push_scaninfo,'Enable','on')
set(h.menu_scaninfo,'Enable','on')
set(h.menu_roiadvanced,'Enable','on')
set(h.menu_roisubvolumes,'Enable','on')

%-----
if numel(h.roi_namelist) > 0 
    set(h.drop_roi,'Enable','on')
    set(h.drop_roi,'String',h.roi_namelist)

    disp('TREX-RT>> ROI drop down menu populated. Please select an ROI.')
else
    disp('TREX-RT>> No available ROI data. Please select a different server/username/institution/plan/roi.')
    msgbox('No available ROI data. Please select a different server/username/institution/plan/roi.','Warning: SetupX','error');
end

h.export.roi_name = [];
h.export.roi_source = [];
h.export.roi_int = [];
h.export.roi_ext = [];

%-----
if doseexist
    %Find dose trial names
    h.dose_namelist = cell(0);
    h.dose_namelist{end+1,1} = '';

    fid = fopen(trialPath);
    trial = textscan(fid,'%s','delimiter','\n');
    trial = trial{1};
    fclose(fid);

    delete(trialPath)

    h.filedata.trialdata = splitParserX(trial,'Trial ={');

    for cellInd = 1:numel(h.filedata.trialdata)
        [h.dose_namelist{end+1,1}] = textParserX(h.filedata.trialdata{cellInd},'Name ');
        disp(['TREX-RT>> Found Trial:  ',h.dose_namelist{end,1}])
    end

    disp(['TREX-RT>> Detected ',num2str(numel(h.dose_namelist))-1,' dose trials!'])

    if numel(h.dose_namelist) > 0
        set(h.drop_dose,'Enable','on')
        set(h.drop_dose,'String',h.dose_namelist)
    
        disp('TREX-RT>> Dose trial drop down menu populated. Please select a trial.')
    else
        disp('TREX-RT>> No available dose trial data.')
        msgbox('No available dose trial data.','Warning: SetupX','error');
    end
end

h.export.dose_name = [];
h.export.dose_internalUID = [];

%%
clearvars -except h
