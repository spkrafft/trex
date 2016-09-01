function cleanup_roidataX(project_path)

extractRead = read_extractX(project_path);

h = waitbar(0, 'Please wait...');

for j = 1:numel(extractRead.project_path)

    waitbar(j/numel(extractRead.project_path),h)
    
    roi = load(fullfile(extractRead.project_patient{j},extractRead.roi_file{j}));
%%   
    namelist = cell(0);
    for cellInd = 1:numel(roi.data)
        namelist{end+1,1} = textParserX(roi.data{cellInd},'name');
    end

    names = cell(0);
    if ~isempty(roi.roi_source)
        names = [names,regexpi(roi.roi_source,'/','split')];
    end

    if ~isempty(roi.roi_int)
        names = [names,regexpi(roi.roi_int,'/','split')];
    end

    if ~isempty(roi.roi_ext)
        names = [names,regexpi(roi.roi_ext,'/','split')];
    end

    for i = numel(names):-1:1
        if ~isempty(regexpi(names{i},'Subvolume'))
            i1 = regexpi(names{i},'(');
            names{i} = names{i}(1:i1-2);
        elseif ~isempty(roi.dose_name) && ~isempty(regexpi(names{i},['(',roi.dose_name,')']))
            names(i) = [];
        end
    end

    names = unique(names);

    [~,keep_ind] = intersect(namelist,names);
    roi.data = roi.data(keep_ind);

%%
    save(fullfile(extractRead.project_patient{j},extractRead.roi_file{j}), '-struct', 'roi')

end

close(h)
