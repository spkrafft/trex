function totallung_correct2BaselineX(project_dir, project_dir_shells)

baseline_roi_name = 'TotalLung_0_5Gy';

%%
extractRead = read_extractX(project_dir, false);
extractRead_shells = read_extractX(project_dir_shells, false);

mrns = unique(extractRead.patient_mrn);

%%
for i = 1:numel(mrns)
    disp(mrns(i))
    
    %Find the "baseline" (i.e. week 0) plan
    ind_patient = find(extractRead_shells.patient_mrn == mrns(i));
    plan_name = extractRead_shells.plan_name(ind_patient);
   
    temp = ~cellfun(@isempty,regexpi(plan_name, 'wk 0')) | ~cellfun(@isempty,regexpi(plan_name, 'prelim'));
   
    ind_plan = ind_patient(temp);
    
    clear temp
    
    %% Find the "baseline" ROI
    ind_roi = find(strcmpi(extractRead_shells.roi_name, baseline_roi_name));
    
    ind_baseline = intersect(ind_plan, ind_roi);
    
    %% Run a check...
    if numel(ind_baseline) ~= 1
        error(mrns(i))
    end
   
    %% Get the mean baseline HU
    img = load(fullfile(extractRead_shells.project_patient{ind_baseline}, extractRead_shells.image_file{ind_baseline}), 'array');
    img = img.array;

    mask = load(fullfile(extractRead_shells.project_patient{ind_baseline}, extractRead_shells.roi_file{ind_baseline}), 'mask');
    mask = mask.mask;

    I = prepCT(img, mask);
    
    clear img
    clear mask

    %Calculate the histogram stats
    stats = hist_features(I);
    
    baselineHU = stats.Mean;
    
    clear I
    clear stats
    
    %%
    ind_2correct = find(extractRead.patient_mrn == mrns(i));
        
    for j = 1:numel(ind_2correct)
    %%
        img = load(fullfile(extractRead.project_patient{ind_2correct(j)}, extractRead.image_file{ind_2correct(j)}), 'array');
        img = img.array;

        mask = load(fullfile(extractRead.project_patient{ind_2correct(j)}, extractRead.roi_file{ind_2correct(j)}), 'mask');
        mask = mask.mask;

        I = prepCT(img, mask);

        clear mask

        %Calculate the histogram stats
        stats = hist_features(I);

        correctHU = baselineHU - stats.Mean;

        clear I
        clear stats
        
        %Can we force the original array to double?
        array = double(img) + correctHU;
                
        save(fullfile(extractRead.project_patient{ind_2correct(j)}, extractRead.image_file{ind_2correct(j)}), '-append', 'array')
        
        clear array
        clear img
        
    end
end

