function [h] = push_add_pinnacle_setupX(h)
%%
for i = 1:size(h.tableHeadings,1)
    if i == 1 %adds a new row to the roi table data
        h.data{size(h.data,1)+1,i} = h.export.(h.tableHeadings{i,2});
    else
        h.data{size(h.data,1),i} = h.export.(h.tableHeadings{i,2});
    end
end
               
set(h.table_data,'Data',h.data);

sNames = fieldnames(h.setupWrite);
for i = 1:numel(sNames)
    if ischar(h.export.(sNames{i})) || isempty(h.export.(sNames{i}))
        h.setupWrite.(sNames{i}){end+1,1} = h.export.(sNames{i});
    elseif iscell(h.export.(sNames{i}))
        h.setupWrite.(sNames{i}){end+1,1} = h.export.(sNames{i}){1};
    else
        h.setupWrite.(sNames{i})(end+1,1) = h.export.(sNames{i});
    end
end

disp(['TREX-RT>> New entry added: Name(',h.export.roi_name,...
    ') Source(',h.export.roi_source,') Avoid Int(',h.export.roi_int,...
    ') Avoid Ext(',h.export.roi_ext,')']);

%%
clearvars -except h
