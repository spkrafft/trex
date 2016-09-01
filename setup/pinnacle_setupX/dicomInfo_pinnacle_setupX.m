function [h] = dicomInfo_pinnacle_setupX(h)
%%
%Look for the DICOM data
if h.export.remote
    cd(h.ftp,h.export.patient_path);
    list = dir(h.ftp,h.export.patient_path);
else
    list = dir(h.export.patient_path); 
end

%Cycle through each file/directory in the patient directory...
for i = 1:numel(list)
    %...stop if it is the DICOM directory
    if strcmpi(list(i).name,[h.export.image_name,'.DICOM']) && list(i).isdir
        
        if h.export.remote
            h.export.image_dicompath = [h.export.patient_path,list(i).name,'/'];
            cd(h.ftp,h.export.image_dicompath);
            files = dir(h.ftp,h.export.image_dicompath);
        else
            h.export.image_dicompath = fullfile(h.export.patient_path,list(i).name);
            files = dir(h.export.image_dicompath);
        end
        
        for j = 1:numel(files)
            if ~isempty(regexpi(files(j).name,'\w*.(img|dcm)'))
                
                if h.export.remote
                    download = mget(h.ftp,files(j).name,h.export.project_path);
                    download = download{1};
                else
                    copyfile(fullfile(h.export.image_dicompath,files(j).name),h.export.project_path)
                    download = fullfile(h.export.project_path,files(j).name);
                end
                
                info = dicominfo(download);
                fields = fieldnames(info);
                delete(download)

                for k = 1:numel(fields)
                    switch fields{k}
                        %Fields already searched for in pinnacle header
                        %files, but will overwrite if the DICOM data exists
                        case 'Format'
                            h.export.dicom_Format = {info.Format};
                        case 'FormatVersion'
                            h.export.dicom_FormatVersion = {info.FormatVersion};
                        case 'Width'
                            h.export.dicom_Width = {info.Width};
                        case 'Height'
                            h.export.dicom_Height = {info.Height};
                        case 'BitDepth'
                            h.export.dicom_BitDepth = {info.BitDepth};
                        case 'ColorType'
                            h.export.dicom_ColorType = {info.ColorType};
                        case 'IdentifyingGroupLength'
                            h.export.dicom_IdentifyingGroupLength = {info.IdentifyingGroupLength};
                        case 'SpecificCharacterSet'
                            h.export.dicom_SpecificCharacterSet = {info.SpecificCharacterSet};
                        case 'ImageType'
                            h.export.dicom_ImageType = {info.ImageType};
                        case 'InstanceCreationDate'
                            h.export.dicom_InstanceCreationDate = {info.InstanceCreationDate};
                        case 'InstanceCreationTime'
                            h.export.dicom_InstanceCreationTime = {info.InstanceCreationTime};
                        case 'SOPClassUID'
                            h.export.dicom_SOPClassUID = {info.SOPClassUID};
                        case 'SOPInstanceUID'
                            h.export.dicom_SOPInstanceUID = {info.SOPInstanceUID};
                        case 'StudyDate'
                            h.export.dicom_StudyDate = {info.StudyDate};
                        case 'SeriesDate'
                            h.export.dicom_SeriesDate = {info.SeriesDate};
                        case 'AcquisitionDate'
                            h.export.dicom_AcquisitionDate = {info.AcquisitionDate};
                        case 'ContentDate'
                            h.export.dicom_ContentDate = {info.ContentDate};
                        case 'StudyTime'
                            h.export.dicom_StudyTime = {info.StudyTime};
                        case 'SeriesTime'
                            h.export.dicom_SeriesTime = {info.SeriesTime};
                        case 'AcquisitionTime'
                            h.export.dicom_AcquisitionTime = {info.AcquisitionTime};
                        case 'ContentTime'
                            h.export.dicom_ContentTime = {info.ContentTime};
                        case 'AccessionNumber'
                            h.export.dicom_AccessionNumber = {info.AccessionNumber};
                        case 'Modality'
                            h.export.dicom_Modality = {info.Modality};
                        case 'Manufacturer'
                            h.export.dicom_Manufacturer = {info.Manufacturer};
                        case 'InstitutionName'
                            h.export.dicom_InstitutionName = {info.InstitutionName};
                        case 'StationName'
                            h.export.dicom_StationName = {info.StationName};
                        case 'StudyDescription'
                            h.export.dicom_StudyDescription = {info.StudyDescription};
                        case 'SeriesDescription'
                            h.export.dicom_SeriesDescription = {info.SeriesDescription};
                        case 'ManufacturerModelName'
                            h.export.dicom_ManufacturerModelName = {info.ManufacturerModelName};
                        case 'PatientGroupLength'
                            h.export.dicom_PatientGroupLength = {info.PatientGroupLength};
                        case 'PatientName'
                            h.export.dicom_FamilyName = {info.PatientName.FamilyName};
                            h.export.dicom_GivenName = {info.PatientName.GivenName};
                        case 'PatientID'
                            h.export.dicom_PatientID = {info.PatientID};
                        case 'PatientBirthDate'
                            h.export.dicom_PatientBirthDate = {info.PatientBirthDate};
                        case 'PatientSex'
                            h.export.dicom_PatientSex = {info.PatientSex};
                        case 'PatientAge'
                            h.export.dicom_PatientAge = {info.PatientAge};
                        case 'PatientSize'
                            h.export.dicom_PatientSize = {info.PatientSize};
                        case 'PatientWeight'
                            h.export.dicom_PatientWeight = {info.PatientWeight};
                        case 'AcquisitionGroupLength'
                            h.export.dicom_AcquisitionGroupLength = {info.AcquisitionGroupLength};
                        case 'BodyPartExamined'
                            h.export.dicom_BodyPartExamined = {info.BodyPartExamined};
                        case 'ScanOptions'
                            h.export.dicom_ScanOptions = {info.ScanOptions};
                        case 'SliceThickness'
                            h.export.dicom_SliceThickness = {info.SliceThickness};
                        case 'KVP'
                            h.export.dicom_KVP = {info.KVP};
                        case 'DataCollectionDiameter'
                            h.export.dicom_DataCollectionDiameter = {info.DataCollectionDiameter};
                        case 'SoftwareVersion'
                            h.export.dicom_SoftwareVersion = {info.SoftwareVersion};
                        case 'ProtocolName'
                            h.export.dicom_ProtocolName = {info.ProtocolName};
                        case 'ReconstructionDiameter'
                            h.export.dicom_ReconstructionDiameter = {info.ReconstructionDiameter};
                        case 'DistanceSourceToDetector'
                            h.export.dicom_DistanceSourceToDetector = {info.DistanceSourceToDetector};
                        case 'DistanceSourceToPatient'
                            h.export.dicom_DistanceSourceToPatient = {info.DistanceSourceToPatient};
                        case 'GantryDetectorTilt'
                            h.export.dicom_GantryDetectorTilt = {info.GantryDetectorTilt};
                        case 'TableHeight'
                            h.export.dicom_TableHeight = {info.TableHeight};
                        case 'RotationDirection'
                            h.export.dicom_RotationDirection = {info.RotationDirection};
                        case 'ExposureTime'
                            h.export.dicom_ExposureTime = {info.ExposureTime};
                        case 'XrayTubeCurrent'
                            h.export.dicom_XrayTubeCurrent = {info.XrayTubeCurrent};
                        case 'Exposure'
                            h.export.dicom_Exposure = {info.Exposure};
                        case 'FilterType'
                            h.export.dicom_FilterType = {info.FilterType};
                        case 'GeneratorPower'
                            h.export.dicom_GeneratorPower = {info.GeneratorPower};
                        case 'FocalSpot'
                            h.export.dicom_FocalSpot = {info.FocalSpot};
                        case 'ConvolutionKernel'
                            h.export.dicom_ConvolutionKernel = {info.ConvolutionKernel};
                        case 'PatientPosition'
                            h.export.dicom_PatientPosition = {info.PatientPosition};
                        case 'RelationshipGroupLength'
                            h.export.dicom_RelationshipGroupLength = {info.RelationshipGroupLength};
                        case 'StudyInstanceUID'
                            h.export.dicom_StudyInstanceUID = {info.StudyInstanceUID};
                        case 'SeriesInstanceUID'
                            h.export.dicom_SeriesInstanceUID = {info.SeriesInstanceUID};
                        case 'StudyID'
                            h.export.dicom_StudyID = {info.StudyID};
                        case 'SeriesNumber'
                            h.export.dicom_SeriesNumber = {info.SeriesNumber};
                        case 'AcquisitionNumber'
                            h.export.dicom_AcquisitionNumber = {info.AcquisitionNumber};
                        case 'InstanceNumber'
                            h.export.dicom_InstanceNumber = {info.InstanceNumber};
                        case 'FrameOfReferenceUID'
                            h.export.dicom_FrameOfReferenceUID = {info.FrameOfReferenceUID};
                        case 'PositionReferenceIndicator'
                            h.export.dicom_PositionReferenceIndicator = {info.PositionReferenceIndicator};
                        case 'SliceLocation'
                            h.export.dicom_SliceLocation = {info.SliceLocation};
                        case 'ImagePresentationGroupLength'
                            h.export.dicom_ImagePresentationGroupLength = {info.ImagePresentationGroupLength};
                        case 'SamplesPerPixel'
                            h.export.dicom_SamplesPerPixel = {info.SamplesPerPixel};
                        case 'PhotometricInterpretation'
                            h.export.dicom_PhotometricInterpretation = {info.PhotometricInterpretation};
                        case 'Rows'
                            h.export.dicom_Rows = {info.Rows};
                        case 'Columns'
                            h.export.dicom_Columns = {info.Columns};
                        case 'BitsAllocated'
                            h.export.dicom_BitsAllocated = {info.BitsAllocated};
                        case 'BitsStored'
                            h.export.dicom_BitsStored = {info.BitsStored};
                        case 'HighBit'
                            h.export.dicom_HighBit = {info.HighBit};
                        case 'PixelRepresentation'
                            h.export.dicom_PixelRepresentation = {info.PixelRepresentation};
                        case 'PixelPaddingValue'
                            h.export.dicom_PixelPaddingValue = {info.PixelPaddingValue};
                        case 'WindowCenter'
                            h.export.dicom_WindowCenter = {info.WindowCenter};
                        case 'WindowWidth'
                            h.export.dicom_WindowWidth = {info.WindowWidth};
                        case 'RescaleIntercept'
                            h.export.dicom_RescaleIntercept = {info.RescaleIntercept};
                        case 'RescaleSlope'
                            h.export.dicom_RescaleSlope = {info.RescaleSlope};
                        case 'RescaleType'
                            h.export.dicom_RescaleType = {info.RescaleType};
                        case 'StudyGroupLength'
                            h.export.dicom_StudyGroupLength = {info.StudyGroupLength};
                        case 'PerformedProcedureStepStartDate'
                            h.export.dicom_PerformedProcedureStepStartDate = {info.PerformedProcedureStepStartDate};
                        case 'PerformedProcedureStepStartTime'
                            h.export.dicom_PerformedProcedureStepStartTime = {info.PerformedProcedureStepStartTime};
                        case 'PerformedProcedureStepID'
                            h.export.dicom_PerformedProcedureStepID = {info.PerformedProcedureStepID};
                        case 'PerformedProcedureStepDescription'
                            h.export.dicom_PerformedProcedureStepDescription = {info.PerformedProcedureStepDescription};
                        case 'PixelDataGroupLength'
                            h.export.dicom_PixelDataGroupLength = {info.PixelDataGroupLength};
                    end
                end
                break
            end
        end
        break
    end
end

if h.export.remote
    cd(h.ftp,h.export.home_path);
end

%%
clearvars -except h
