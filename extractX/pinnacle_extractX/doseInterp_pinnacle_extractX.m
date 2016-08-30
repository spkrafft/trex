function [dose] = doseInterp_pinnacle_extractX(extractWrite,entry,dose)
%%
disp(['TREX-RT>> Entry ',num2str(entry),': Interpolating dose array'])

dose.array_xV = load(fullfile(extractWrite.project_patient,extractWrite.image_file),'array_xV');
dose.array_xV = dose.array_xV.array_xV;
dose.array_yV = load(fullfile(extractWrite.project_patient,extractWrite.image_file),'array_yV');
dose.array_yV = dose.array_yV.array_yV;
dose.array_zV = load(fullfile(extractWrite.project_patient,extractWrite.image_file),'array_zV');
dose.array_zV = dose.array_zV.array_zV;

[xi,yi,zi] = meshgrid(single(dose.array_xV),...
                      single(dose.array_yV),...
                      single(dose.array_zV));

[x,y,z] = meshgrid(single(dose.original.xV),...
                   single(dose.original.yV),...
                   single(dose.original.zV));

dose.array = interp3(x,y,z,dose.original.array,xi,yi,zi,'linear');

%%
clearvars -except dose
