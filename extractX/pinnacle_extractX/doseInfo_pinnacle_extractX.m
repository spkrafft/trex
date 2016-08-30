function [dose] = doseInfo_pinnacle_extractX(extractWrite)
%%
fid = fopen(fullfile(extractWrite.project_dosedata,'plan.Trial'));
trial = textscan(fid,'%s','delimiter','\n');
trial = trial{1};
fclose(fid);

trialdata = splitParserX(trial,'Trial ={');

dose = [];
dose.array = [];
dose.array_xV = [];
dose.array_yV = [];
dose.array_zV = [];

dose.original = [];
dose.original.array = [];

for cellInd = 1:numel(trialdata)
    dose.Name = textParserX(trialdata{cellInd},'Name ');
    if strcmpi(extractWrite.dose_name,dose.Name)
        break
    end 
end

trialdata = trialdata{cellInd};

dose.PatientVolumeName = textParserX(trialdata,'PatientVolumeName ');
dose.CtToDensityName = textParserX(trialdata,'CtToDensityName ');
    
dose.original.xdim = str2double(textParserX(trialdata,'DoseGrid .Dimension .X '));
dose.original.ydim = str2double(textParserX(trialdata,'DoseGrid .Dimension .Y '));
dose.original.zdim = str2double(textParserX(trialdata,'DoseGrid .Dimension .Z '));

dose.original.xstart = str2double(textParserX(trialdata,'DoseGrid .Origin .X '));
dose.original.ystart = str2double(textParserX(trialdata,'DoseGrid .Origin .Y '));
dose.original.zstart = str2double(textParserX(trialdata,'DoseGrid .Origin .Z '));

dose.original.xpixdim = str2double(textParserX(trialdata,'DoseGrid .VoxelSize .X '));
dose.original.ypixdim = str2double(textParserX(trialdata,'DoseGrid .VoxelSize .Y '));
dose.original.zpixdim = str2double(textParserX(trialdata,'DoseGrid .VoxelSize .Z '));

dose.original.xV = dose.original.xstart : dose.original.xpixdim : dose.original.xstart + (dose.original.xdim-1)*dose.original.xpixdim;
dose.original.yV = fliplr(dose.original.ystart : dose.original.ypixdim : dose.original.ystart + (dose.original.ydim-1)*dose.original.ypixdim);
dose.original.zV = dose.original.zstart : dose.original.zpixdim : dose.original.zstart + (dose.original.zdim-1)*dose.original.zpixdim;

prescriptions = splitParserX(trialdata,'Prescription ={');

for i = 1:numel(prescriptions)
    prescription(i).Name = textParserX(prescriptions{i},'Name ');
    prescription(i).RequestedMonitorUnitsPerFraction = str2double(textParserX(prescriptions{i},'RequestedMonitorUnitsPerFraction '));
    prescription(i).PrescriptionDose = str2double(textParserX(prescriptions{i},'PrescriptionDose '));
    prescription(i).PrescriptionPercent = str2double(textParserX(prescriptions{i},'PrescriptionPercent '));
    prescription(i).NumberOfFractions = str2double(textParserX(prescriptions{i},'NumberOfFractions '));
    prescription(i).PrescriptionRoi = textParserX(prescriptions{i},'PrescriptionRoi ');

    prescription(i).PrescriptionPoint = textParserX(prescriptions{i},'PrescriptionPoint ');

    prescription(i).Method = textParserX(prescriptions{i},'Method ');    
    prescription(i).NormalizationMethod = textParserX(prescriptions{i},'NormalizationMethod ');
    prescription(i).PrescriptionPeriod = textParserX(prescriptions{i},'PrescriptionPeriod ');
    prescription(i).WeightsProportionalTo = textParserX(prescriptions{i},'WeightsProportionalTo ');
end

dose.prescription = prescription;
clear prescription

beams = splitParser2X(trialdata,'Beam ={');

for i = 1:numel(beams)
    beam(i).Name = textParserX(beams{i},'Name ');
    beam(i).IsocenterName = textParserX(beams{i},'IsocenterName ');
    beam(i).PrescriptionName = textParserX(beams{i},'PrescriptionName ');
    beam(i).UsePoiForPrescriptionPoint = textParserX(beams{i},'UsePoiForPrescriptionPoint ');
    beam(i).PrescriptionPointName = textParserX(beams{i},'PrescriptionPointName ');
    beam(i).PrescriptionPointDepth = textParserX(beams{i},'PrescriptionPointDepth ');
    beam(i).PrescriptionPointXOffset = textParserX(beams{i},'PrescriptionPointXOffset ');
    beam(i).PrescriptionPointYOffset = textParserX(beams{i},'PrescriptionPointYOffset ');
    beam(i).SpecifyDosePerMuAtPrescriptionPoint = textParserX(beams{i},'SpecifyDosePerMuAtPrescriptionPoint ');
    beam(i).DosePerMuAtPrescriptionPoint = textParserX(beams{i},'DosePerMuAtPrescriptionPoint ');
    beam(i).MachineNameAndVersion = textParserX(beams{i},'MachineNameAndVersion ');
    beam(i).Modality = textParserX(beams{i},'Modality ');
    beam(i).MachineEnergyName = textParserX(beams{i},'MachineEnergyName ');
    beam(i).DesiredLocalizerName = textParserX(beams{i},'DesiredLocalizerName ');
    beam(i).ActualLocalizerName = textParserX(beams{i},'ActualLocalizerName ');
    beam(i).DisplayLaserMotion = textParserX(beams{i},'DisplayLaserMotion ');
    beam(i).SetBeamType = textParserX(beams{i},'SetBeamType ');
    beam(i).PrevBeamType = textParserX(beams{i},'PrevBeamType ');
    beam(i).ComputationVersion = textParserX(beams{i},'ComputationVersion ');

    beam(i).DoseEngine = textParserX(beams{i},'TypeName ');
    beam(i).ConvolveHomogeneous = str2double(textParserX(beams{i},'ConvolveHomogeneous '));
    beam(i).FluenceHomogeneous = str2double(textParserX(beams{i},'FluenceHomogeneous '));
    beam(i).FlatWaterPhantom = str2double(textParserX(beams{i},'FlatWaterPhantom '));
    beam(i).FlatHomogeneous = str2double(textParserX(beams{i},'FlatHomogeneous '));
    beam(i).ElectronHomogeneous = str2double(textParserX(beams{i},'ElectronHomogeneous '));

    temp = splitParserX(beams{i},'MonitorUnitInfo ={');
    beam(i).PrescriptionDose = str2double(textParserX(temp{1},'PrescriptionDose '));
    beam(i).SourceToPrescriptionPointDistance = str2double(textParserX(temp{1},'SourceToPrescriptionPointDistance '));
    beam(i).TotalTransmissionFraction = str2double(textParserX(temp{1},'TotalTransmissionFraction '));
    beam(i).TransmissionDescription = textParserX(temp{1},'TransmissionDescription ');
    beam(i).PrescriptionPointDepth = str2double(textParserX(temp{1},'PrescriptionPointDepth '));
    beam(i).PrescriptionPointRadDepth = str2double(textParserX(temp{1},'PrescriptionPointRadDepth '));
    beam(i).DepthToActualPoint = str2double(textParserX(temp{1},'DepthToActualPoint '));
    beam(i).SSDToActualPoint = str2double(textParserX(temp{1},'SSDToActualPoint '));
    beam(i).RadDepthToActualPoint = str2double(textParserX(temp{1},'RadDepthToActualPoint '));
    beam(i).PrescriptionPointRadDepthValid = str2double(textParserX(temp{1},'PrescriptionPointRadDepthValid '));
    beam(i).PrescriptionPointOffAxisDistance = str2double(textParserX(temp{1},'PrescriptionPointOffAxisDistance '));
    beam(i).UnblockedFieldAreaAtSAD = str2double(textParserX(temp{1},'UnblockedFieldAreaAtSAD '));
    beam(i).UnblockedFieldPerimeterAtSAD = str2double(textParserX(temp{1},'UnblockedFieldPerimeterAtSAD '));
    beam(i).BlockedFieldAreaAtSAD = str2double(textParserX(temp{1},'BlockedFieldAreaAtSAD '));
    beam(i).IntersectFieldAreaAtSAD = str2double(textParserX(temp{1},'IntersectFieldAreaAtSAD '));
    beam(i).NormalizedDose = str2double(textParserX(temp{1},'NormalizedDose '));
    beam(i).OffAxisRatio = str2double(textParserX(temp{1},'OffAxisRatio '));
    beam(i).CollimatorOutputFactor = str2double(textParserX(temp{1},'CollimatorOutputFactor '));
    beam(i).RelativeOutputFactor = str2double(textParserX(temp{1},'RelativeOutputFactor '));
    beam(i).PhantomOutputFactor = str2double(textParserX(temp{1},'PhantomOutputFactor '));
    beam(i).OFMeasurementDepth = str2double(textParserX(temp{1},'OFMeasurementDepth '));
    beam(i).OutputFactorInfo = textParserX(temp{1},'OutputFactorInfo ');

    beam(i).DoseVolume = textParserX(beams{i},'DoseVolume ');
    beam(i).DoseVarVolume = textParserX(beams{i},'DoseVarVolume ');

    temp = splitParserX(beams{i},'DoseVolume ');
    beam(i).Weight = str2double(textParserX(temp{end},'Weight '));
    beam(i).IsWeightLocked = str2double(textParserX(temp{end},'IsWeightLocked '));
    beam(i).MonitorUnitsValid = str2double(textParserX(temp{end},'MonitorUnitsValid '));
end

dose.beam = beam;

%%
clearvars -except dose
