function [map_files] = findmapfiles_mapX(project_path,module)
%%
extractRead = read_extractX(project_path,false);

map_files = cell(0);

for i = 1:numel(extractRead.patient_mrn)
    list = dir(fullfile(extractRead.project_patient{i},'mapx'));
    
    for fCount = 1:numel(list)
        if ~isempty(regexpi(list(fCount).name,['^',module,'.*',extractRead.roi_file{i},'$']))
            map_files{end+1,1} = list(fCount).name;
        end
    end
end

%%
clearvars -except map_files
