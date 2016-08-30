function varargout = pinnacle_imageX(varargin)
% PINNACLE_IMAGEX MATLAB code for pinnacle_imageX.fig
%      PINNACLE_IMAGEX, by itself, creates a new PINNACLE_IMAGEX or raises the existing
%      singleton*.
%
%      H = PINNACLE_IMAGEX returns the handle to a new PINNACLE_IMAGEX or the handle to
%      the existing singleton*.
%
%      PINNACLE_IMAGEX('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in PINNACLE_IMAGEX.M with the given input arguments.
%
%      PINNACLE_IMAGEX('Property','Value',...) creates a new PINNACLE_IMAGEX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pinnacle_imageX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pinnacle_imageX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pinnacle_imageX

% Last Modified by GUIDE v2.5 16-Oct-2015 12:21:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pinnacle_imageX_OpeningFcn, ...
                   'gui_OutputFcn',  @pinnacle_imageX_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%--------------------------------------------------------------------------
function pinnacle_imageX_OpeningFcn(hObject, eventdata, h, varargin)

movegui(hObject,'center')

h.export = [];
h.export = initialize_pinnacle_setupX(h.export);

mainDir = fileparts(which('TREX'));
ver = regexp(mainDir, filesep, 'split');
h.export.trex_setupver = ver{end};

%Set the directory
if ~isempty(varargin)
    h.export.project_path = varargin{2};
else
    h.export.project_path = uigetdir(pwd,'Select Project Directory');
end

h.now = datestr(now,'yyyymmddHHMMSS');

mainDir = fileparts(which('TREX'));
configPath = fullfile(mainDir,'config.trex');

fid = fopen(configPath);
config = textscan(fid,'%s','delimiter','\n');
config = config{1};
fclose(fid);

servers = textParserX(config,'pinnacle-server');
h.server_list = {'Local Pinnacle';servers};

set(h.drop_server,'Enable','on')
set(h.drop_server,'String',h.server_list)

% Choose default command line output for pinnacle_imageX
h.output = hObject;

% Update h structure
guidata(hObject, h);

% UIWAIT makes pinnacle_imageX wait for user response (see UIRESUME)
% uiwait(h.figure_dbimage);


function varargout = pinnacle_imageX_OutputFcn(hObject, eventdata, h) 
% --- Outputs from this function are returned to the command line.

% Get default command line output from h structure
varargout{1} = h.output;

%SERVER PANEL**************************************************************
%**************************************************************************
%**************************************************************************
function drop_server_Callback(hObject, eventdata, h)

h.export = resetexport_pinnacle_setupX(h.export,'institution');
h.export = resetexport_pinnacle_setupX(h.export,'patient');
h.export = resetexport_pinnacle_setupX(h.export,'plan');
h.export = resetexport_pinnacle_setupX(h.export,'image');
h.export = resetexport_pinnacle_setupX(h.export,'roi');
h.export = resetexport_pinnacle_setupX(h.export,'dose');

contents = cellstr(get(h.drop_server,'String'));
h.export.server_name = contents{get(h.drop_server,'Value')};
%Enables the connect button depending on the selection
if strcmpi(h.export.server_name,'')
    set(h.push_server,'Enable','off')    
elseif strcmpi(h.export.server_name,'Local Pinnacle')
    h.export.server_user = 'username';
    h.export.server_pass = 'password';
    
    set(h.push_server,'Enable','on')
    h.export.remote = false;
    h.export.pinnacle = true;
else
    set(h.push_server,'Enable','on')
    h.export.remote = true;
    h.export.pinnacle = true;
end

guidata(hObject,h)

%--------------------------------------------------------------------------
function drop_server_CreateFcn(hObject, eventdata, h)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function push_server_Callback(hObject, eventdata, h)
%%%GET INSTITUTION INFO 
if h.export.remote
    %Get the FTP server username and password
    prompt = {'Username:','Password:'};
    dlg_title = 'FTP Connection';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines);
    h.export.server_user = answer{1};
    h.export.server_pass = answer{2};

    disp('TREX-RT>> Connecting...');
    disp(['TREX-RT>> Server: ',h.export.server_name,', Username: ',h.export.server_user,', Password: ',h.export.server_pass]);

    %Try to connect to the server
    try
        h.ftp = ftp(h.export.server_name,h.export.server_user,h.export.server_pass);
    catch err
        
        disp('TREX-RT>> Connection Aborted!');

        try
            close(h.ftp);
        catch err
        end

        return
    end

    disp('TREX-RT>> Connected!');

    %Set the directory which contains all of the pinnacle data
    if strcmpi(h.export.server_user,'pinnbeta')
        h.export.home_path = '/pinnacle_patient_expansion/BetaPatients/';
    else
        h.export.home_path = '/pinnacle_patient_expansion/NewPatients/';
    end

else
    h.export.home_path = uigetdir(h.export.project_path,'Select the home Pinnacle directory (i.e. BetaPatients or NewPatients directory)');   
end

disp(['TREX-RT>> Home Directory: ',h.export.home_path]);

%Get the list of institutions and initialize
if h.export.remote
    list = dir(h.ftp,h.export.home_path);
else
    list = dir(h.export.home_path);
end

h.institution_pathlist = cell(0);
h.institution_dirlist = cell(0);

disp('TREX-RT>> Getting institution names...');

%Cycle through each file/directory in the home directory...
for i = 1:numel(list)
    %...stop if it is one of the institutions
    if ~isempty(regexpi(list(i).name,'Institution_[0-9]')) && list(i).isdir
        if h.export.remote
            h.institution_pathlist{end+1,1} = [h.export.home_path,'/',list(i).name,'/'];
        else
            h.institution_pathlist{end+1,1} = fullfile(h.export.home_path,list(i).name);
        end
        h.institution_dirlist{end+1,1} = list(i).name;
    end
end
clear list

disp(['TREX-RT>> Detected ',num2str(numel(h.institution_dirlist)),' unique institutions!']);

if numel(h.institution_dirlist) > 0
            
    set(h.drop_institution,'Enable','on')
    set(h.drop_institution,'String',h.institution_dirlist)

    disp('TREX-RT>> Institution drop down menu populated. Please select an institution.');
else
    disp('TREX-RT>> No available institution data. Please select a different server or login username.');
    msgbox('No available institution data. Please select a different server or login username.','SetupX: Warning','error')
end

guidata(hObject,h)

%INSTITUTION PANEL*********************************************************
%**************************************************************************
%**************************************************************************
function drop_institution_Callback(hObject, eventdata, h)

h.export = resetexport_pinnacle_setupX(h.export,'institution');
h.export = resetexport_pinnacle_setupX(h.export,'patient');
h.export = resetexport_pinnacle_setupX(h.export,'plan');
h.export = resetexport_pinnacle_setupX(h.export,'image');
h.export = resetexport_pinnacle_setupX(h.export,'roi');
h.export = resetexport_pinnacle_setupX(h.export,'dose');

disp('TREX-RT>> Gathering institution info...')

h.export.institution_path = h.institution_pathlist{get(h.drop_institution,'Value')};
h.export.institution_dir = h.institution_dirlist{get(h.drop_institution,'Value')};

%Get the list of files within the institution directory and transfer the
%institution file to the project directory
if h.export.remote
    cd(h.ftp,h.export.institution_path);
    drawnow; pause(0.1);
    inst_file = mget(h.ftp,'Institution',h.export.project_path);
    inst_file = inst_file{1};
    cd(h.ftp,h.export.home_path);
else
    copyfile(fullfile(h.export.institution_path,'Institution'),h.export.project_path);
    inst_file = fullfile(h.export.project_path,'Institution');
end

%Open, read, and close the institution file
fid = fopen(inst_file);
h.filedata.institution = textscan(fid,'%s','delimiter','\n');
h.filedata.institution = h.filedata.institution{1};
fclose(fid);

h.export.institution_name = textParserX(h.filedata.institution,'Name ');
h.export.institution_street = textParserX(h.filedata.institution,'StreetAddress ');
h.export.institution_street2 = textParserX(h.filedata.institution,'StreetAddress2 ');

clear institution
delete(inst_file)

set(h.push_institution,'Enable','on')

guidata(hObject,h)

%--------------------------------------------------------------------------
function drop_institution_CreateFcn(hObject, eventdata, h)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function push_institution_Callback(hObject, eventdata, h)

output = cell(0);

set(h.drop_server,'Enable','off')
set(h.push_server,'Enable','off')
set(h.drop_institution,'Enable','off')
set(h.push_institution,'Enable','off')

disp('TREX-RT>> Institution selected!');
disp(['TREX-RT>> Institution Path: ',h.export.institution_path]);

h.export.institution_path = [h.export.institution_path,'/Mount_0/'];

%Get the list of patients and initialize
if h.export.remote
    list = dir(h.ftp,h.export.institution_path);
else
    list = dir(h.export.institution_path);
end
h.patient_pathlist = cell(0);
h.patient_dirlist = cell(0);

mrnlist = cell(0);
namelist = cell(0);
stringlist = cell(0);

disp('TREX-RT>> Getting patient data...');

splitInstitution = splitParserX(h.filedata.institution,'PatientLite ={');

for i = 1:numel(splitInstitution)
    desc = textParserX(splitInstitution{i},'FormattedDescription =');
    ind = regexpi(desc,'&[0-9]');
    mrn{i} = desc(ind(1)+1:ind(1)+6);
    name{i} = strrep(desc(1:ind(1)),'&',' ');
    patientid{i} = textParserX(splitInstitution{i},'PatientID =');
end

%Cycle through each file/directory in the institution directory...
for i = 1:numel(list)
    %...stop if it is one of the patients
    if ~isempty(regexpi(list(i).name,'^Patient_[0-9]')) && list(i).isdir
        if h.export.remote
            h.patient_pathlist{end+1,1} = [h.export.institution_path,'/',list(i).name,'/'];
        else
            h.patient_pathlist{end+1,1} = fullfile(h.export.institution_path,list(i).name);
        end
        h.patient_dirlist{end+1,1} = list(i).name;
        
        ind = strcmpi(patientid,strrep(list(i).name,'Patient_',''));
        
        mrnlist{end+1,1} = mrn{ind};
        namelist{end+1,1} = name{ind};
        
        stringlist{end+1,1} = [mrnlist{end,1},' ',namelist{end,1}];
        
    end
end
clear list

w = waitbar(0,'Please wait...');
p_steps = numel(h.patient_pathlist);

% save('test.mat')
% error()

for i = 1:numel(h.patient_pathlist)
    %%
    g = h;
    g.export.patient_path = h.patient_pathlist{i};
    g.export.patient_dir = h.patient_dirlist{i};
    
    if g.export.remote
        cd(g.ftp,g.export.patient_path);
        drawnow; pause(0.1);
        pat_file = mget(g.ftp,'Patient',g.export.project_path);
        pat_file = pat_file{1};
        cd(g.ftp,g.export.home_path);
    else
        copyfile(fullfile(g.export.patient_path,'Patient'),g.export.project_path);
        pat_file = fullfile(g.export.project_path,'Patient');
    end

    %Open, read, and close the patient file
    fid = fopen(pat_file);
    g.filedata.patient = textscan(fid,'%s','delimiter','\n');
    g.filedata.patient = g.filedata.patient{1};
    fclose(fid);
    
    delete(pat_file)
    
    last = textParserX(g.filedata.patient,'LastName ');
    first = textParserX(g.filedata.patient,'FirstName ');
    g.export.patient_name = [last,', ',first];
    g.export.patient_mrn = str2double(textParserX(g.filedata.patient,'MedicalRecordNumber '));
    
    disp(g.export.patient_mrn)
    disp(g.export.patient_dir)
    
    if g.export.remote
        list = dir(g.ftp,g.export.patient_path);
    else
        list = dir(g.export.patient_path);
    end

    g.image_pathlist = cell(0);
    g.image_namelist = cell(0);
    g.image_idlist = cell(0);

    %Cycle through each file/directory in the patient directory...
    for j = 1:numel(list)
        %...stop if it is one of the image headers
        if ~isempty(regexpi(list(j).name,'ImageSet_[0-9]+\.img$')) && ~list(j).isdir
            if g.export.remote
                g.image_pathlist{end+1,1} = [g.export.patient_path,'/',list(j).name,'/'];
            else
                g.image_pathlist{end+1,1} = fullfile(g.export.patient_path,list(j).name);
            end
            g.image_namelist{end+1,1} = strrep(list(j).name,'.img','');
            g.image_idlist{end+1,1} = strrep(strrep(list(j).name,'ImageSet_',''),'.img','');
        end
    end
%%
    for j = 1:numel(g.image_pathlist)
        %%
        g.export.image_name = g.image_namelist{j};
    
        [g2] = imageInfo(g);
        [g2] = dicomInfo(g2);
        
        disp(['studyUID: ',g2.export.image_studyinstanceUID])
        
        if isempty(output)
            output = [output; fieldnames(g2.export)'];
            fieldnames(g2.export)
        end
        
        output = [output; struct2cell(g2.export)'];
        
        clear g2
    end
    
    clear g
    
    waitbar(i/p_steps,w);
end

close(w)

% dlmcellX('image_data.csv',output)
save('image_data.mat','output')
% xlswrite('image_data.xlsx',output)

try
    close(h.ftp);
catch err

end

fclose('all');
delete(h.figure_dbimage);

%--------------------------------------------------------------------------
function [g] = imageInfo(g)
%%
if g.export.remote
    cd(g.ftp,g.export.patient_path);
    imageHeaderPath = mget(g.ftp,[g.export.image_name,'.header'],g.export.project_path);
    imageHeaderPath = imageHeaderPath{1};
    
    imageInfoPath = mget(g.ftp,[g.export.image_name,'.ImageInfo'],g.export.project_path);
    imageInfoPath = imageInfoPath{1};

    cd(g.ftp,g.export.home_path);
else
    copyfile(fullfile(g.export.patient_path,[g.export.image_name,'.header']),g.export.project_path)
    imageHeaderPath = fullfile(g.export.project_path,[g.export.image_name,'.header']);
    
    copyfile(fullfile(g.export.patient_path,[g.export.image_name,'.ImageInfo']),g.export.project_path)
    imageInfoPath = fullfile(g.export.project_path,[g.export.image_name,'.ImageInfo']);
end

fid = fopen(imageHeaderPath);
imageHeader = textscan(fid,'%s','delimiter','\n');
imageHeader = imageHeader{1};
fclose(fid);
delete(imageHeaderPath)

fid = fopen(imageInfoPath);
imageInfo = textscan(fid,'%s','delimiter','\n');
imageInfo = imageInfo{1};
fclose(fid);
delete(imageInfoPath)

imageInfo = splitParserX(imageInfo,'ImageInfo ={');

g.export.image_seriesUID = textParserX(imageInfo{1},'SeriesUID ');
g.export.image_studyinstanceUID = textParserX(imageInfo{1},'StudyInstanceUID ');
g.export.image_frameUID = textParserX(imageInfo{1},'FrameUID ');
g.export.image_classUID = textParserX(imageInfo{1},'ClassUID ');

g.export.image_xdim = str2double(textParserX(imageHeader,'x_dim '));
g.export.image_ydim = str2double(textParserX(imageHeader,'y_dim '));
g.export.image_zdim = str2double(textParserX(imageHeader,'z_dim '));

g.export.image_bitpix = str2double(textParserX(imageHeader,'bitpix '));
g.export.image_byteorder = logical(str2double(textParserX(imageHeader,'byte_order ')));

g.export.image_xpixdim = str2double(textParserX(imageHeader,'x_pixdim '));
g.export.image_ypixdim = str2double(textParserX(imageHeader,'y_pixdim '));
g.export.image_zpixdim = str2double(textParserX(imageHeader,'z_pixdim '));

g.export.image_zstart = str2double(textParserX(imageHeader,'z_start '));

g.export.image_patientname = textParserX(imageHeader,'db_name ');
g.export.image_date = textParserX(imageHeader,'date ');
g.export.image_seriesdatetime = textParserX(imageHeader,'SeriesDateTime ');
g.export.image_scannerid = textParserX(imageHeader,'scanner_id ');
g.export.image_patientpos = textParserX(imageHeader,'patient_position ');
g.export.image_manufacturer = textParserX(imageHeader,'manufacturer ');
g.export.image_model = textParserX(imageHeader,'model ');

g.export.image_studyid = textParserX(imageHeader,'study_id ');
g.export.image_examid = textParserX(imageHeader,'exam_id ');
g.export.image_patientid = textParserX(imageHeader,'patient_id ');
g.export.image_modality = textParserX(imageHeader,'modality ');
g.export.image_seriesdesc = textParserX(imageHeader,'Series_Description ');
g.export.image_scanoptions = textParserX(imageHeader,'Scan_Options ');
g.export.image_kvp = textParserX(imageHeader,'KVP ');
%%
clear imageHeader
clear imageInfo

clearvars -except g

%--------------------------------------------------------------------------
function [g] = dicomInfo(g)
%%
%Look for the DICOM data
if g.export.remote
    cd(g.ftp,g.export.patient_path);
    list = dir(g.ftp,g.export.patient_path);
else
    list = dir(g.export.patient_path); 
end

%Cycle through each file/directory in the patient directory...
for i = 1:numel(list)
    %...stop if it is the DICOM directory
    if strcmpi(list(i).name,[g.export.image_name,'.DICOM']) && list(i).isdir
        if g.export.remote
            g.export.image_dicompath = [g.export.patient_path,list(i).name,'/'];
            cd(g.ftp,g.export.image_dicompath);
            files = dir(g.ftp,g.export.image_dicompath);
        else
            g.export.image_dicompath = fullfile(g.export.patient_path,list(i).name);
            files = dir(g.export.image_dicompath);
        end

        for j = 1:numel(files)
            if ~isempty(regexpi(files(j).name,'\w*.(img|dcm)')) || ~isempty(regexpi(files(j).name,'^(CT|PT)'))
                if g.export.remote
                    download = mget(g.ftp,files(j).name,g.export.project_path);
                    download = download{1};
                else
                    copyfile(fullfile(g.export.image_dicompath,files(j).name),g.export.project_path)
                    download = fullfile(g.export.project_path,files(j).name);
                end
                
                info = dicominfo(download);
                fields = fieldnames(info);
                delete(download)

                for k = 1:numel(fields)
                    switch fields{k}
                        case 'Format'
                            g.export.dicom_Format = info.Format;
                        case 'FormatVersion'
                            g.export.dicom_FormatVersion = info.FormatVersion;
                        case 'Width'
                            g.export.dicom_Width = info.Width;
                        case 'Height'
                            g.export.dicom_Height = info.Height;
                        case 'BitDepth'
                            g.export.dicom_BitDepth = info.BitDepth;
                        case 'ColorType'
                            g.export.dicom_ColorType = info.ColorType;
                        case 'IdentifyingGroupLength'
                            g.export.dicom_IdentifyingGroupLength = info.IdentifyingGroupLength;
                        case 'SpecificCharacterSet'
                            g.export.dicom_SpecificCharacterSet = info.SpecificCharacterSet;
                        case 'ImageType'
                            g.export.dicom_ImageType = info.ImageType;
                        case 'InstanceCreationDate'
                            g.export.dicom_InstanceCreationDate = info.InstanceCreationDate;
                        case 'InstanceCreationTime'
                            g.export.dicom_InstanceCreationTime = info.InstanceCreationTime;
                        case 'SOPClassUID'
                            g.export.dicom_SOPClassUID = info.SOPClassUID;
                        case 'SOPInstanceUID'
                            g.export.dicom_SOPInstanceUID = info.SOPInstanceUID;
                        case 'StudyDate'
                            g.export.dicom_StudyDate = info.StudyDate;
                        case 'SeriesDate'
                            g.export.dicom_SeriesDate = info.SeriesDate;
                        case 'AcquisitionDate'
                            g.export.dicom_AcquisitionDate = info.AcquisitionDate;
                        case 'ContentDate'
                            g.export.dicom_ContentDate = info.ContentDate;
                        case 'StudyTime'
                            g.export.dicom_StudyTime = info.StudyTime;
                        case 'SeriesTime'
                            g.export.dicom_SeriesTime = info.SeriesTime;
                        case 'AcquisitionTime'
                            g.export.dicom_AcquisitionTime = info.AcquisitionTime;
                        case 'ContentTime'
                            g.export.dicom_ContentTime = info.ContentTime;
                        case 'AccessionNumber'
                            g.export.dicom_AccessionNumber = info.AccessionNumber;
                        case 'Modality'
                            g.export.dicom_Modality = info.Modality;
                        case 'Manufacturer'
                            g.export.dicom_Manufacturer = info.Manufacturer;
                        case 'InstitutionName'
                            g.export.dicom_InstitutionName = info.InstitutionName;
                        case 'StationName'
                            g.export.dicom_StationName = info.StationName;
                        case 'StudyDescription'
                            g.export.dicom_StudyDescription = info.StudyDescription;
                        case 'SeriesDescription'
                            g.export.dicom_SeriesDescription = info.SeriesDescription;
                        case 'ManufacturerModelName'
                            g.export.dicom_ManufacturerModelName = info.ManufacturerModelName;
                        case 'PatientGroupLength'
                            g.export.dicom_PatientGroupLength = info.PatientGroupLength;
                        case 'PatientName'
                            g.export.dicom_FamilyName = info.PatientName.FamilyName;
                            g.export.dicom_GivenName = info.PatientName.GivenName;
                        case 'PatientID'
                            g.export.dicom_PatientID = info.PatientID;
                        case 'PatientBirthDate'
                            g.export.dicom_PatientBirthDate = info.PatientBirthDate;
                        case 'PatientSex'
                            g.export.dicom_PatientSex = info.PatientSex;
                        case 'PatientAge'
                            g.export.dicom_PatientAge = info.PatientAge;
                        case 'PatientSize'
                            g.export.dicom_PatientSize = info.PatientSize;
                        case 'PatientWeight'
                            g.export.dicom_PatientWeight = info.PatientWeight;
                        case 'AcquisitionGroupLength'
                            g.export.dicom_AcquisitionGroupLength = info.AcquisitionGroupLength;
                        case 'BodyPartExamined'
                            g.export.dicom_BodyPartExamined = info.BodyPartExamined;
                        case 'ScanOptions'
                            g.export.dicom_ScanOptions = info.ScanOptions;
                        case 'SliceThickness'
                            g.export.dicom_SliceThickness = info.SliceThickness;
                        case 'KVP'
                            g.export.dicom_KVP = info.KVP;
                        case 'DataCollectionDiameter'
                            g.export.dicom_DataCollectionDiameter = info.DataCollectionDiameter;
                        case 'SoftwareVersion'
                            g.export.dicom_SoftwareVersion = info.SoftwareVersion;
                        case 'ProtocolName'
                            g.export.dicom_ProtocolName = info.ProtocolName;
                        case 'ReconstructionDiameter'
                            g.export.dicom_ReconstructionDiameter = info.ReconstructionDiameter;
                        case 'DistanceSourceToDetector'
                            g.export.dicom_DistanceSourceToDetector = info.DistanceSourceToDetector;
                        case 'DistanceSourceToPatient'
                            g.export.dicom_DistanceSourceToPatient = info.DistanceSourceToPatient;
                        case 'GantryDetectorTilt'
                            g.export.dicom_GantryDetectorTilt = info.GantryDetectorTilt;
                        case 'TableHeight'
                            g.export.dicom_TableHeight = info.TableHeight;
                        case 'RotationDirection'
                            g.export.dicom_RotationDirection = info.RotationDirection;
                        case 'ExposureTime'
                            g.export.dicom_ExposureTime = info.ExposureTime;
                        case 'XrayTubeCurrent'
                            g.export.dicom_XrayTubeCurrent = info.XrayTubeCurrent;
                        case 'Exposure'
                            g.export.dicom_Exposure = info.Exposure;
                        case 'FilterType'
                            g.export.dicom_FilterType = info.FilterType;
                        case 'GeneratorPower'
                            g.export.dicom_GeneratorPower = info.GeneratorPower;
                        case 'FocalSpot'
                            g.export.dicom_FocalSpot = info.FocalSpot;
                        case 'ConvolutionKernel'
                            g.export.dicom_ConvolutionKernel = info.ConvolutionKernel;
                        case 'PatientPosition'
                            g.export.dicom_PatientPosition = info.PatientPosition;
                        case 'RelationshipGroupLength'
                            g.export.dicom_RelationshipGroupLength = info.RelationshipGroupLength;
                        case 'StudyInstanceUID'
                            g.export.dicom_StudyInstanceUID = info.StudyInstanceUID;
                        case 'SeriesInstanceUID'
                            g.export.dicom_SeriesInstanceUID = info.SeriesInstanceUID;
                        case 'StudyID'
                            g.export.dicom_StudyID = info.StudyID;
                        case 'SeriesNumber'
                            g.export.dicom_SeriesNumber = info.SeriesNumber;
                        case 'AcquisitionNumber'
                            g.export.dicom_AcquisitionNumber = info.AcquisitionNumber;
                        case 'InstanceNumber'
                            g.export.dicom_InstanceNumber = info.InstanceNumber;
                        case 'FrameOfReferenceUID'
                            g.export.dicom_FrameOfReferenceUID = info.FrameOfReferenceUID;
                        case 'PositionReferenceIndicator'
                            g.export.dicom_PositionReferenceIndicator = info.PositionReferenceIndicator;
                        case 'SliceLocation'
                            g.export.dicom_SliceLocation = info.SliceLocation;
                        case 'ImagePresentationGroupLength'
                            g.export.dicom_ImagePresentationGroupLength = info.ImagePresentationGroupLength;
                        case 'SamplesPerPixel'
                            g.export.dicom_SamplesPerPixel = info.SamplesPerPixel;
                        case 'PhotometricInterpretation'
                            g.export.dicom_PhotometricInterpretation = info.PhotometricInterpretation;
                        case 'Rows'
                            g.export.dicom_Rows = info.Rows;
                        case 'Columns'
                            g.export.dicom_Columns = info.Columns;
                        case 'BitsAllocated'
                            g.export.dicom_BitsAllocated = info.BitsAllocated;
                        case 'BitsStored'
                            g.export.dicom_BitsStored = info.BitsStored;
                        case 'HighBit'
                            g.export.dicom_HighBit = info.HighBit;
                        case 'PixelRepresentation'
                            g.export.dicom_PixelRepresentation = info.PixelRepresentation;
                        case 'PixelPaddingValue'
                            g.export.dicom_PixelPaddingValue = info.PixelPaddingValue;
                        case 'WindowCenter'
                            g.export.dicom_WindowCenter = info.WindowCenter;
                        case 'WindowWidth'
                            g.export.dicom_WindowWidth = info.WindowWidth;
                        case 'RescaleIntercept'
                            g.export.dicom_RescaleIntercept = info.RescaleIntercept;
                        case 'RescaleSlope'
                            g.export.dicom_RescaleSlope = info.RescaleSlope;
                        case 'RescaleType'
                            g.export.dicom_RescaleType = info.RescaleType;
                        case 'StudyGroupLength'
                            g.export.dicom_StudyGroupLength = info.StudyGroupLength;
                        case 'PerformedProcedureStepStartDate'
                            g.export.dicom_PerformedProcedureStepStartDate = info.PerformedProcedureStepStartDate;
                        case 'PerformedProcedureStepStartTime'
                            g.export.dicom_PerformedProcedureStepStartTime = info.PerformedProcedureStepStartTime;
                        case 'PerformedProcedureStepID'
                            g.export.dicom_PerformedProcedureStepID = info.PerformedProcedureStepID;
                        case 'PerformedProcedureStepDescription'
                            g.export.dicom_PerformedProcedureStepDescription = info.PerformedProcedureStepDescription;
                        case 'PixelDataGroupLength'
                            g.export.dicom_PixelDataGroupLength = info.PixelDataGroupLength;
                    end
                end
                break
            end
        end
        break
    end
end

if g.export.remote
    cd(g.ftp,g.export.home_path);
end
%%
clearvars -except g
