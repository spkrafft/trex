function [roi_name,roi_source,roi_int,roi_ext] = add_10Gy_shell_dose(h)
%%
roi_name = cell(0);
roi_source = cell(0);
roi_int = cell(0);
roi_ext = cell(0);

if isempty(h.export.roi_source)
    msgbox('Select a source roi!')
    return
end

if isempty(h.dose) || isempty(h.export.dose_name)
    msgbox('Select the dose trial!')
    return
end

source = h.export.roi_source;

%%
max_iso = round(max(h.dose.array_original(:))/100)*100;

roi_name{end+1,1} = [source,'_0_5Gy'];
roi_source{end+1,1} = source;
roi_int{end+1,1} = ['500cGy (',h.export.dose_name,')'];
roi_ext{end+1,1} = [];

lines = 500:1000:max_iso;

for i = 2:numel(lines)
    
    t1 = num2str(lines(i-1)/100);
    t2 = num2str(lines(i)/100);
    
    roi_name{end+1,1} = [source,'_',t1,'_',t2,'Gy'];
    roi_source{end+1,1} = source;
    roi_int{end+1,1} = [num2str(lines(i-1)),'cGy (',h.export.dose_name,')/',num2str(lines(i)),'cGy (',h.export.dose_name,')'];
    roi_ext{end+1,1} = [];
    
end

%%
clearvars -except roi_name roi_source roi_int roi_ext
