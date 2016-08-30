function [h] = machineInfo_pinnacle_setupX(h)
%%
h.dose.machine = [];

try
    if h.export.remote
        cd(h.ftp,h.export.plan_path);
        machinePath = mget(h.ftp,'plan.Pinnacle.Machines',h.export.project_path);
        machinePath = machinePath{1};
        cd(h.ftp,h.export.home_path);
    else
        copyfile(fullfile(h.export.plan_path,'plan.Pinnacle.Machines'),h.export.project_path);
        machinePath = fullfile(h.export.project_path,'plan.Pinnacle.Machines');
    end
catch err
    disp('TREX-RT>> No machine data exists for this plan!');
    return
end

fid = fopen(machinePath);
machinedata = textscan(fid,'%s','delimiter','\n');
machinedata = machinedata{1};
fclose(fid);

delete(machinePath)

%So...the machine file doesn't have an easy phrase to simply break up the
%machine file into all of the different machines...what I am doing is
%finding the VersiionTimestamp field, and then I will shift the split back
%three rows, which should correctly split the machine file based on each
%available machine.
[~,rows] = splitParserX(machinedata,'VersionTimestamp ');
rows = rows-3;

machines = [];
if isempty(rows)
    machines = machinedata;
else
    for i = 1:numel(rows)
        if i == numel(rows)
           	machines{end+1,1} = machinedata(rows(i):end);
        else
            machines{end+1,1} = machinedata(rows(i):rows(i+1)-1);
        end
    end
end

for i = 1:numel(machines)
    h.dose.machine(i).Name = textParserX(machines{i},'Name ');
    h.dose.machine(i).MachineType = textParserX(machines{i},'MachineType ');
    h.dose.machine(i).VersionTimestamp = textParserX(machines{i},'VersionTimestamp ');
    
    h.dose.machine(i).MachineNameAndVersion = [h.dose.machine(i).Name,': ',h.dose.machine(i).VersionTimestamp];
    
    photonlist = splitParserX(machines{i},'PhotonEnergyList ={');
    photonlist = photonlist{1};
    electronlist = splitParserX(machines{i},'ElectronEnergyList ={');
    electronlist = electronlist{1};
    
    photonlist = photonlist(1:(numel(photonlist)-numel(electronlist)));
    clear electronlist
    
    photonenergies = splitParserX(photonlist,'MachineEnergy ={');
    clear photonlist
    
    for j = 1:numel(photonenergies)
        h.dose.machine(i).photon(j).Value = str2double(textParserX(photonenergies{j},'Value '));
        h.dose.machine(i).photon(j).Name = textParserX(photonenergies{j},'Name ');
        h.dose.machine(i).photon(j).ReferenceDepth = str2double(textParserX(photonenergies{j},'ReferenceDepth '));
        h.dose.machine(i).photon(j).SourceToCalibrationPointDistance = str2double(textParserX(photonenergies{j},'SourceToCalibrationPointDistance '));
        h.dose.machine(i).photon(j).DosePerMuAtCalibration = str2double(textParserX(photonenergies{j},'DosePerMuAtCalibration '));
        h.dose.machine(i).photon(j).CalculatedCalibrationDose = str2double(textParserX(photonenergies{j},'CalculatedCalibrationDose '));
    end
    clear photonenergies
end
clear machines

%%
clearvars -except h
