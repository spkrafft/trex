function [dose] = doseRead_pinnacle_extractX(extractWrite,dose)
%%
dosedim = [dose.original.ydim,dose.original.xdim,dose.original.zdim];
dose.original.array = zeros(dosedim);

for i = 1:numel(dose.beam)
    %Find the dose/mu calibration factor
    dosemu = [];
    for j = 1:numel(dose.machine)
        if strcmpi(dose.machine(j).MachineNameAndVersion,dose.beam(i).MachineNameAndVersion)
            for k = 1:numel(dose.machine(j).photon)
                if strcmpi(dose.machine(j).photon(k).Name,dose.beam(i).MachineEnergyName)
                    dosemu = dose.machine(j).photon(k).DosePerMuAtCalibration;
                    break
                end 
            end
        end 
    end
    
    filename = dose.beam(i).DoseVolume;
    filename = filename(regexpi(filename,'[0-9]'));

    while length(filename) < 3
        filename = ['0',filename];
    end

    filename = ['plan.Trial.binary.',filename];

    fid = fopen(fullfile(extractWrite.project_dosedata,filename),'r','b');
    dosebeam = fread(fid,prod(dosedim),'single=>single');
    fclose(fid);

    dosebeam = reshape(dosebeam,dosedim([2 1 3]));
    dosebeam = permute(dosebeam,[2 1 3]);

    for j = 1:numel(dose.prescription)
        if strcmpi(dose.prescription(j).Name,dose.beam(i).PrescriptionName)
            break
        end 
    end

    dosebeam = dosebeam*...
        dose.prescription(j).NumberOfFractions*...
        dose.beam(i).PrescriptionDose/...
        (dose.beam(i).NormalizedDose*...
        dose.beam(i).CollimatorOutputFactor*...
        dose.beam(i).TotalTransmissionFraction*...
        dosemu);

    if sum(isnan(dosebeam(:))) ~= numel(dosebeam)
        dose.original.array = dose.original.array + dosebeam;
    end
end

%%
clearvars -except dose
