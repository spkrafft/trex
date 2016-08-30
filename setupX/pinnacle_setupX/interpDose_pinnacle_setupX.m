function [array] = interpDose_pinnacle_setupX(h)
%%
[Xq,Yq,Zq] = meshgrid(single(h.img.array_xV),...
                      single(h.img.array_yV),...
                      single(h.img.array_zV));

[X,Y,Z] = meshgrid(single(h.dose.array_xV),...
                   single(h.dose.array_yV),...
                   single(h.dose.array_zV));

disp('TREX-RT>> Interpolating dose array...')

array = interp3(X,Y,Z,h.dose.array_original,Xq,Yq,Zq,'linear');

disp('TREX-RT>> Dose array interpolation complete!')

%%
clearvars -except array
