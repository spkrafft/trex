function [h] = scaleCurvedata_pinnacle_setupX(h)
%%
start_rngx = [h.img.array_xV(1),h.img.array_xV(end)];
rngx = [1,h.export.image_xdim];

start_rngy = [h.img.array_yV(1),h.img.array_yV(end)];
rngy = [1,h.export.image_ydim];

start_rngz = [h.img.array_zV(1),h.img.array_zV(end)];
rngz = [1,h.export.image_zdim];

h.roi.x = [];
h.roi.y = [];
h.roi.z = [];

for cCount = 1:numel(h.roi.curvedata)
    tempx = rngx(1)+((rngx(2)-rngx(1))*(h.roi.curvedata{cCount}(:,1)-start_rngx(1)))./...
                                           (start_rngx(2)-start_rngx(1));
                                       
    tempy = rngy(1)+((rngy(2)-rngy(1))*(h.roi.curvedata{cCount}(:,2)-start_rngy(1)))./...
                                           (start_rngy(2)-start_rngy(1));
                                       
    tempz = rngz(1)+((rngz(2)-rngz(1))*(h.roi.curvedata{cCount}(:,3)-start_rngz(1)))./...
                                           (start_rngz(2)-start_rngz(1));
                                       
    h.roi.x = [h.roi.x; tempx];
    h.roi.y = [h.roi.y; tempy];
    h.roi.z = [h.roi.z; tempz];                                   
end

%%
clearvars -except h
