function [stats] = plan_features(varargin)
%PLAN_FEATURES 
%   [STATS] = PLAN_FEATURES(DOSES)
%
%   Parameters include:
%  
%   'doseS'   	TREX extracted dose struct
%
%   Notes
%   -----
%   
%   References
%   ----------
%   
%   $SPK

%%
doseS = ParseInputs(varargin{:});

%%
stats.NumRx = 0;
stats.MUPerFraction = 0;
stats.NumFractions = 0;
stats.NumBeams = 0;

stats.Modality = nan;
stats.MachineEnergy = nan;
stats.BeamType = nan;
stats.ComputationVersion = nan;
stats.DoseEngine = nan;
stats.ConvolveHomogeneous = nan;
stats.FluenceHomogeneous = nan;
stats.FlatWater = nan;
stats.FlatHomogeneous = nan;
stats.ElectronHomogeneous = nan;
stats.PrimHomoSecHetero = nan;
stats.PrimHeteroSecHomo = nan;
stats.WaterPhantom = nan;
stats.Homogeneous = nan;
stats.Heterogeneous = nan;

stats.NumMachine = 0;
stats.MachineName = nan;
stats.MachineType = nan;
stats.MachineVersion = nan;

stats.PatientVolumeName = nan;
stats.CT2DensityName = nan;
%%
if isstruct(doseS)
    % PRESCRIPTIONS
    for i = 1:numel(doseS.prescription)
        if doseS.prescription(i).RequestedMonitorUnitsPerFraction > 0
            stats.NumRx = stats.NumRx + 1;
            stats.MUPerFraction = stats.MUPerFraction + doseS.prescription(i).RequestedMonitorUnitsPerFraction;
            stats.NumFractions = stats.NumFractions + doseS.prescription(i).NumberOfFractions;
        end
    end

    % BEAMS
    t.Modality = cell(0);
    t.MachineEnergy = cell(0);
    t.BeamType = cell(0);
    t.ComputationVersion = cell(0);
    t.DoseEngine = cell(0);
    t.ConvolveHomogeneous = [];
    t.FluenceHomogeneous = [];
    t.FlatWater = [];
    t.FlatHomogeneous = [];
    t.ElectronHomogeneous = [];
    t.PrimHomoSecHetero = [];
    t.PrimHeteroSecHomo = [];
    t.WaterPhantom = [];
    t.Homogeneous = [];
    t.Heterogeneous = [];

    for i = 1:numel(doseS.beam)      
        if doseS.beam(i).Weight > 0
            stats.NumBeams = stats.NumBeams + 1;
            
            t.Modality{end+1} = doseS.beam(i).Modality;
            t.MachineEnergy{end+1} = doseS.beam(i).MachineEnergyName;
            t.BeamType{end+1} = doseS.beam(i).SetBeamType;
            t.ComputationVersion{end+1} = doseS.beam(i).ComputationVersion;
            t.DoseEngine{end+1} = doseS.beam(i).DoseEngine;
            
            if isfield(doseS.beam(i),'ConvolveHomogeneous')
                t.ConvolveHomogeneous(end+1) = doseS.beam(i).ConvolveHomogeneous;
                t.FluenceHomogeneous(end+1) = doseS.beam(i).FluenceHomogeneous;
                t.FlatWater(end+1) = doseS.beam(i).FlatWaterPhantom;
                t.FlatHomogeneous(end+1) = doseS.beam(i).FlatHomogeneous;
                t.ElectronHomogeneous(end+1) = doseS.beam(i).ElectronHomogeneous;

                if t.FlatWater(end) == 1
                    t.PrimHomoSecHetero(end+1) = 0;
                    t.PrimHeteroSecHomo(end+1) = 0;
                    t.WaterPhantom(end+1) = 1;
                    t.Homogeneous(end+1) = 0;
                    t.Heterogeneous(end+1) = 0;
                elseif t.ConvolveHomogeneous(end) == 1 && t.FluenceHomogeneous(end) == 1
                    t.PrimHomoSecHetero(end+1) = 0;
                    t.PrimHeteroSecHomo(end+1) = 0;
                    t.WaterPhantom(end+1) = 0;
                    t.Homogeneous(end+1) = 1;
                    t.Heterogeneous(end+1) = 0;
                elseif t.ConvolveHomogeneous(end) == 1 && t.FluenceHomogeneous(end) == 0
                    t.PrimHomoSecHetero(end+1) = 0;
                    t.PrimHeteroSecHomo(end+1) = 1;
                    t.WaterPhantom(end+1) = 0;
                    t.Homogeneous(end+1) = 0;
                    t.Heterogeneous(end+1) = 0;    
                elseif t.ConvolveHomogeneous(end) == 0 && t.FluenceHomogeneous(end) == 1
                    t.PrimHomoSecHetero(end+1) = 1;
                    t.PrimHeteroSecHomo(end+1) = 0;
                    t.WaterPhantom(end+1) = 0;
                    t.Homogeneous(end+1) = 0;
                    t.Heterogeneous(end+1) = 0;        
                elseif t.ConvolveHomogeneous(end) == 0 && t.FluenceHomogeneous(end) == 0
                    t.PrimHomoSecHetero(end+1) = 0;
                    t.PrimHeteroSecHomo(end+1) = 0;
                    t.WaterPhantom(end+1) = 0;
                    t.Homogeneous(end+1) = 0;
                    t.Heterogeneous(end+1) = 1;
                else
                    t.PrimHomoSecHetero(end+1) = 0;
                    t.PrimHeteroSecHomo(end+1) = 0;
                    t.WaterPhantom(end+1) = 0;
                    t.Homogeneous(end+1) = 0;
                    t.Heterogeneous(end+1) = 0;
                end
            end
        end 
    end

    f_names = fieldnames(t);
    for i = 1:numel(f_names)
        temp = unique(t.(f_names{i}));
        
        if iscell(t.(f_names{i}))
            if numel(temp) > 1
                stats.(f_names{i}) = 'mixed';
            else
                stats.(f_names{i}) = temp{1};
            end
        else
            if numel(temp) > 1
                stats.(f_names{i}) = nan;
            else
                stats.(f_names{i}) = temp;
            end
        end
    end

    % MACHINE   
    if numel(doseS.machine) > 1        
        stats.NumMachine = numel(doseS.machine);
        stats.MachineName = 'mixed';
        stats.MachineType = 'mixed';
        stats.MachineVersion = 'mixed';
    else
        stats.NumMachine = 1;
        stats.MachineName = doseS.machine.Name;
        stats.MachineType = doseS.machine.MachineType;
        stats.MachineVersion = doseS.machine.MachineNameAndVersion;
    end

    stats.PatientVolumeName = doseS.PatientVolumeName;
    stats.CT2DensityName = doseS.CtToDensityName;
    
end

%%
clearvars -except stats

%--------------------------------------------------------------------------
function [doseS] = ParseInputs(varargin)

if verLessThan('matlab','7.13')
    iptchecknargin(1,1,nargin,mfilename);
else
    narginchk(1,1);
end

% Check mask
doseS = varargin{1};

%%
clearvars -except doseS
