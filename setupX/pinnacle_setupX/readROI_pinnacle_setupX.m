function [h] = readROI_pinnacle_setupX(h)
%%
disp('TREX-RT>> Extracting ROI curve data...');

for cellInd = 1:numel(h.roi.data)
    name = textParserX(h.roi.data{cellInd},'name');
    if strcmpi(h.export.roi_name,name)
        break
    end 
end

curveCell = splitParserX(h.roi.data{cellInd},'points={');

h.roi.curvedata = cell(numel(curveCell),1);

for i = 1:numel(curveCell)
    endjunk = splitParserX(curveCell{i},'End of points');
    tempCurve = curveCell{i}(2:numel(curveCell{i})-numel(endjunk{1}));
    clear endjunk

    for j = 1:numel(tempCurve)
        points = cell2mat(textscan(tempCurve{j},'%f %f %f'));
        h.roi.curvedata{i}(j,:) = points;
        clear points
    end
    clear tempCurve
end
clear curveCell

emp = [];
for i = 1:numel(h.roi.curvedata)
    if isempty(h.roi.curvedata{i})
        emp(end+1) = i;
    end
end
h.roi.curvedata(emp) = [];

disp(['TREX-RT>> Extracted ROI data for ', num2str(length(h.roi.curvedata)),' curves!']);

%%
clearvars -except h
