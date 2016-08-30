function [h] = readDose_pinnacle_setupX(h)
%%
disp('TREX-RT>> Reading dose array data...')

legitdose = 1;

dosedim = [h.dose.ydim,h.dose.xdim,h.dose.zdim];
h.dose.array_original = zeros(dosedim);

for i = 1:numel(h.dose.beam)
    if ~strcmpi(h.dose.beam(i).Modality,'Photons')
        disp('TREX-RT>> Plan includes electron beams which have not been validated!');
        legitdose = 0;
        break
    end
    
    %Find the dose/mu calibration factor
    dosemu = [];
    for j = 1:numel(h.dose.machine)
        if strcmpi(h.dose.machine(j).MachineNameAndVersion,h.dose.beam(i).MachineNameAndVersion)
            for k = 1:numel(h.dose.machine(j).photon)
                if strcmpi(h.dose.machine(j).photon(k).Name,h.dose.beam(i).MachineEnergyName)
                    dosemu = h.dose.machine(j).photon(k).DosePerMuAtCalibration;
                    break
                end 
            end
        end 
    end
    
    if isempty(dosemu)
        disp('TREX-RT>> Cannot find the dose per mu factor!');
        legitdose = 0;
        break
    end
    
    filename = h.dose.beam(i).DoseVolume;
    filename = filename(regexpi(filename,'[0-9]'));

    while length(filename) < 3
        filename = ['0',filename];
    end

    filename = ['plan.Trial.binary.',filename];

    %Get the trialBinary files
    try
        if h.export.remote
            cd(h.ftp,h.export.plan_path);
            trialBinary = mget(h.ftp,filename,h.export.project_path);
            trialBinary = trialBinary{1};
            cd(h.ftp,h.export.home_path);
        else
            copyfile(fullfile(h.export.plan_path,filename),h.export.project_path);
            trialBinary = fullfile(h.export.project_path,filename);
        end
    catch err
        disp('TREX-RT>> No dose data exists for this plan!');
        legitdose = 0;
        break
    end

    fid = fopen(trialBinary,'r','b');
    dosebeam = fread(fid,prod(dosedim),'single=>single');
    fclose(fid);

    delete(trialBinary)

    dosebeam = reshape(dosebeam,dosedim([2 1 3]));
    dosebeam = permute(dosebeam,[2 1 3]);

    for j = 1:numel(h.dose.prescription)
        if strcmpi(h.dose.prescription(j).Name,h.dose.beam(i).PrescriptionName)
            break
        end 
    end

    h.dose.array_original = h.dose.array_original + dosebeam*...
                            h.dose.prescription(j).NumberOfFractions*...
                            h.dose.beam(i).PrescriptionDose/...
                            (h.dose.beam(i).NormalizedDose*...
                            h.dose.beam(i).CollimatorOutputFactor*...
                            h.dose.beam(i).TotalTransmissionFraction*...
                            dosemu); 
end

h.dose.array = [];

if sum(h.dose.array_original(:)) == 0 || ~legitdose
    disp('TREX-RT>> Dose for selected trial is invalid (i.e. not calculated)')
    h.dose = [];
else
    disp('TREX-RT>> Dose data extraction complete!')
end

%%
clearvars -except h
