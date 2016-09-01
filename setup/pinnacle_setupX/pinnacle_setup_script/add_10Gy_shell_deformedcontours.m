function [roi_name,roi_source,roi_int,roi_ext] = add_10Gy_shell_deformedcontours(h)
%%
roi_name = cell(0);
roi_source = cell(0);
roi_int = cell(0);
roi_ext = cell(0);

if isempty(h.export.roi_source)
    msgbox('Select a source roi!')
    return
end

source = h.export.roi_source;

%%
iso_ind = regexpi(h.roi_namelist,'^Deformed: (\w*)00cGy');

if sum(cell2mat(iso_ind)) ~= 0
    iso_num = [];
    iso_str = cell(0);
    for i = 1:numel(iso_ind)
        if iso_ind{i}
            iso_num(end+1) = str2double(strrep(strrep(h.roi_namelist{i},'cGy',''),'Deformed: ',''));
            iso_str{end+1} = h.roi_namelist{i};
        end
    end

    roi_name{end+1,1} = [source,'_0_5Gy'];
    roi_source{end+1,1} = source;
    roi_int{end+1,1} = 'Deformed: 500cGy';
    roi_ext{end+1,1} = [];

    lines = 500:1000:max(iso_num);

    for i = 2:numel(lines)
        t1 = num2str(lines(i-1)/100);
        t2 = num2str(lines(i)/100);

        roi_name{end+1,1} = [source,'_',t1,'_',t2,'Gy'];
        roi_source{end+1,1} = source;
        roi_int{end+1,1} = ['Deformed: ',num2str(lines(i)),'cGy'];
        roi_ext{end+1,1} = ['Deformed: ',num2str(lines(i-1)),'cGy'];
    end
end

%%
clearvars -except roi_name roi_source roi_int roi_ext
