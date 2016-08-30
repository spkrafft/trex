function dose = doseMachineInfo_pinnacle_extractX(extractWrite,dose)
%%
fid = fopen(fullfile(extractWrite.project_dosedata,'plan.Pinnacle.Machines'));
machinedata = textscan(fid,'%s','delimiter','\n');
machinedata = machinedata{1};
fclose(fid);

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
    dose.machine(i).Name = textParserX(machines{i},'Name ');
    dose.machine(i).MachineType = textParserX(machines{i},'MachineType ');
    dose.machine(i).VersionTimestamp = textParserX(machines{i},'VersionTimestamp ');
    
    dose.machine(i).MachineNameAndVersion = [dose.machine(i).Name,': ',dose.machine(i).VersionTimestamp];
    
    photonlist = splitParserX(machines{i},'PhotonEnergyList ={');
    photonlist = photonlist{1};
    electronlist = splitParserX(machines{i},'ElectronEnergyList ={');
    electronlist = electronlist{1};
    
    photonlist = photonlist(1:(numel(photonlist)-numel(electronlist)));
    clear electronlist
    
    photonenergies = splitParserX(photonlist,'MachineEnergy ={');
    clear photonlist
    
    for j = 1:numel(photonenergies)
        dose.machine(i).photon(j).Value = str2double(textParserX(photonenergies{j},'Value '));
        dose.machine(i).photon(j).Name = textParserX(photonenergies{j},'Name ');
        dose.machine(i).photon(j).ReferenceDepth = str2double(textParserX(photonenergies{j},'ReferenceDepth '));
        dose.machine(i).photon(j).SourceToCalibrationPointDistance = str2double(textParserX(photonenergies{j},'SourceToCalibrationPointDistance '));
        dose.machine(i).photon(j).DosePerMuAtCalibration = str2double(textParserX(photonenergies{j},'DosePerMuAtCalibration '));
        dose.machine(i).photon(j).CalculatedCalibrationDose = str2double(textParserX(photonenergies{j},'CalculatedCalibrationDose '));
    end
    clear photonenergies
end
clear machines

%%
clearvars -except dose
