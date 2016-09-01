function [h] = doseInfo_pinnacle_setupX(h)
%%
for cellInd = 1:numel(h.filedata.trialdata)
    name = textParserX(h.filedata.trialdata{cellInd},'Name ');
    if strcmpi(h.export.dose_name,name)
        break
    end 
end

trialdata = h.filedata.trialdata{cellInd};

h.dose = [];

h.dose.PatientVolumeName = textParserX(trialdata,'PatientVolumeName ');
h.dose.CtToDensityName = textParserX(trialdata,'CtToDensityName ');
    
h.dose.xdim = str2double(textParserX(trialdata,'DoseGrid .Dimension .X '));
h.dose.ydim = str2double(textParserX(trialdata,'DoseGrid .Dimension .Y '));
h.dose.zdim = str2double(textParserX(trialdata,'DoseGrid .Dimension .Z '));

h.dose.xstart = str2double(textParserX(trialdata,'DoseGrid .Origin .X '));
h.dose.ystart = str2double(textParserX(trialdata,'DoseGrid .Origin .Y '));
h.dose.zstart = str2double(textParserX(trialdata,'DoseGrid .Origin .Z '));

h.dose.xpixdim = str2double(textParserX(trialdata,'DoseGrid .VoxelSize .X '));
h.dose.ypixdim = str2double(textParserX(trialdata,'DoseGrid .VoxelSize .Y '));
h.dose.zpixdim = str2double(textParserX(trialdata,'DoseGrid .VoxelSize .Z '));

h.dose.array_xV = h.dose.xstart : h.dose.xpixdim : h.dose.xstart + (h.dose.xdim-1)*h.dose.xpixdim;
h.dose.array_yV = fliplr(h.dose.ystart : h.dose.ypixdim : h.dose.ystart + (h.dose.ydim-1)*h.dose.ypixdim);
h.dose.array_zV = h.dose.zstart : h.dose.zpixdim : h.dose.zstart + (h.dose.zdim-1)*h.dose.zpixdim;

prescriptions = splitParserX(trialdata,'Prescription ={');
rxexist = false;
%%
if numel(prescriptions) ~= numel(trialdata)
    rxexist = true;
    for i = 1:numel(prescriptions)
        h.dose.prescription(i).Name = textParserX(prescriptions{i},'Name ');
        h.dose.prescription(i).RequestedMonitorUnitsPerFraction = str2double(textParserX(prescriptions{i},'RequestedMonitorUnitsPerFraction '));
        h.dose.prescription(i).PrescriptionDose = str2double(textParserX(prescriptions{i},'PrescriptionDose '));
        h.dose.prescription(i).PrescriptionPercent = str2double(textParserX(prescriptions{i},'PrescriptionPercent '));
        h.dose.prescription(i).NumberOfFractions = str2double(textParserX(prescriptions{i},'NumberOfFractions '));
        h.dose.prescription(i).PrescriptionRoi = textParserX(prescriptions{i},'PrescriptionRoi ');
        
        h.dose.prescription(i).PrescriptionPoint = textParserX(prescriptions{i},'PrescriptionPoint ');
        
        h.dose.prescription(i).Method = textParserX(prescriptions{i},'Method ');    
        h.dose.prescription(i).NormalizationMethod = textParserX(prescriptions{i},'NormalizationMethod ');
        h.dose.prescription(i).PrescriptionPeriod = textParserX(prescriptions{i},'PrescriptionPeriod ');
        h.dose.prescription(i).WeightsProportionalTo = textParserX(prescriptions{i},'WeightsProportionalTo ');
    end
end

beams = splitParser2X(trialdata,'Beam ={');
beamexist = false;

if numel(beams) ~= numel(trialdata)
    beamexist = true;
    for i = 1:numel(beams)
        h.dose.beam(i).Name = textParserX(beams{i},'Name ');
        h.dose.beam(i).IsocenterName = textParserX(beams{i},'IsocenterName ');
        h.dose.beam(i).PrescriptionName = textParserX(beams{i},'PrescriptionName ');
        h.dose.beam(i).UsePoiForPrescriptionPoint = textParserX(beams{i},'UsePoiForPrescriptionPoint ');
        h.dose.beam(i).PrescriptionPointName = textParserX(beams{i},'PrescriptionPointName ');
        h.dose.beam(i).PrescriptionPointDepth = textParserX(beams{i},'PrescriptionPointDepth ');
        h.dose.beam(i).PrescriptionPointXOffset = textParserX(beams{i},'PrescriptionPointXOffset ');
        h.dose.beam(i).PrescriptionPointYOffset = textParserX(beams{i},'PrescriptionPointYOffset ');
        h.dose.beam(i).SpecifyDosePerMuAtPrescriptionPoint = textParserX(beams{i},'SpecifyDosePerMuAtPrescriptionPoint ');
        h.dose.beam(i).DosePerMuAtPrescriptionPoint = textParserX(beams{i},'DosePerMuAtPrescriptionPoint ');
        h.dose.beam(i).MachineNameAndVersion = textParserX(beams{i},'MachineNameAndVersion ');
        h.dose.beam(i).Modality = textParserX(beams{i},'Modality ');
        h.dose.beam(i).MachineEnergyName = textParserX(beams{i},'MachineEnergyName ');
        h.dose.beam(i).DesiredLocalizerName = textParserX(beams{i},'DesiredLocalizerName ');
        h.dose.beam(i).ActualLocalizerName = textParserX(beams{i},'ActualLocalizerName ');
        h.dose.beam(i).DisplayLaserMotion = textParserX(beams{i},'DisplayLaserMotion ');
        h.dose.beam(i).SetBeamType = textParserX(beams{i},'SetBeamType ');
        h.dose.beam(i).PrevBeamType = textParserX(beams{i},'PrevBeamType ');
        h.dose.beam(i).ComputationVersion = textParserX(beams{i},'ComputationVersion ');

        h.dose.beam(i).DoseEngine = textParserX(beams{i},'TypeName ');

        temp = splitParserX(beams{i},'MonitorUnitInfo ={');
        h.dose.beam(i).PrescriptionDose = str2double(textParserX(temp{1},'PrescriptionDose '));
        h.dose.beam(i).SourceToPrescriptionPointDistance = str2double(textParserX(temp{1},'SourceToPrescriptionPointDistance '));
        h.dose.beam(i).TotalTransmissionFraction = str2double(textParserX(temp{1},'TotalTransmissionFraction '));
        h.dose.beam(i).TransmissionDescription = textParserX(temp{1},'TransmissionDescription ');
        h.dose.beam(i).PrescriptionPointDepth = str2double(textParserX(temp{1},'PrescriptionPointDepth '));
        h.dose.beam(i).PrescriptionPointRadDepth = str2double(textParserX(temp{1},'PrescriptionPointRadDepth '));
        h.dose.beam(i).DepthToActualPoint = str2double(textParserX(temp{1},'DepthToActualPoint '));
        h.dose.beam(i).SSDToActualPoint = str2double(textParserX(temp{1},'SSDToActualPoint '));
        h.dose.beam(i).RadDepthToActualPoint = str2double(textParserX(temp{1},'RadDepthToActualPoint '));
        h.dose.beam(i).PrescriptionPointRadDepthValid = str2double(textParserX(temp{1},'PrescriptionPointRadDepthValid '));
        h.dose.beam(i).PrescriptionPointOffAxisDistance = str2double(textParserX(temp{1},'PrescriptionPointOffAxisDistance '));
        h.dose.beam(i).UnblockedFieldAreaAtSAD = str2double(textParserX(temp{1},'UnblockedFieldAreaAtSAD '));
        h.dose.beam(i).UnblockedFieldPerimeterAtSAD = str2double(textParserX(temp{1},'UnblockedFieldPerimeterAtSAD '));
        h.dose.beam(i).BlockedFieldAreaAtSAD = str2double(textParserX(temp{1},'BlockedFieldAreaAtSAD '));
        h.dose.beam(i).IntersectFieldAreaAtSAD = str2double(textParserX(temp{1},'IntersectFieldAreaAtSAD '));
        h.dose.beam(i).NormalizedDose = str2double(textParserX(temp{1},'NormalizedDose '));
        h.dose.beam(i).OffAxisRatio = str2double(textParserX(temp{1},'OffAxisRatio '));
        h.dose.beam(i).CollimatorOutputFactor = str2double(textParserX(temp{1},'CollimatorOutputFactor '));
        h.dose.beam(i).RelativeOutputFactor = str2double(textParserX(temp{1},'RelativeOutputFactor '));
        h.dose.beam(i).PhantomOutputFactor = str2double(textParserX(temp{1},'PhantomOutputFactor '));
        h.dose.beam(i).OFMeasurementDepth = str2double(textParserX(temp{1},'OFMeasurementDepth '));
        h.dose.beam(i).OutputFactorInfo = textParserX(temp{1},'OutputFactorInfo ');
        
        h.dose.beam(i).DoseVolume = textParserX(beams{i},'DoseVolume ');
        h.dose.beam(i).DoseVarVolume = textParserX(beams{i},'DoseVarVolume ');

        temp = splitParserX(beams{i},'DoseVolume ');
        h.dose.beam(i).Weight = str2double(textParserX(temp{end},'Weight '));
        h.dose.beam(i).IsWeightLocked = str2double(textParserX(temp{end},'IsWeightLocked '));
        h.dose.beam(i).MonitorUnitsValid = str2double(textParserX(temp{end},'MonitorUnitsValid '));
    end
end

if rxexist && beamexist
    h = machineInfo_pinnacle_setupX(h);
    if ~isempty(h.dose.machine)
        h = readDose_pinnacle_setupX(h);
    else
        h.dose = [];
    end
else
    disp('TREX-RT>> Dose for selected trial is invalid (i.e. not calculated)')
    h.dose = [];
end

%%
clearvars -except h
