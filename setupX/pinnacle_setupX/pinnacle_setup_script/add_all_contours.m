function [roi_name,roi_source,roi_int,roi_ext] = add_all_contours(h)
%%
roi_name = cell(0);
roi_source = cell(0);
roi_int = cell(0);
roi_ext = cell(0);

for i = 1:numel(h.roi_namelist)
    roi_name{end+1,1} = h.roi_namelist{i};
    roi_source{end+1,1} = h.roi_namelist{i};
    roi_int{end+1,1} = [];
    roi_ext{end+1,1} = [];
end

%%
clearvars -except roi_name roi_source roi_int roi_ext
