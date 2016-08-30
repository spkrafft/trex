function correct2BaselineX(project_dir)

baseline_roi_name = 'TotalLung_0_5Gy';

%%
extractRead = read_extractX(project_dir, false);
mrns = unique(extractRead.patient_mrn);

%%
for i = 1:numel(mrns)
    
    %Find the "baseline" (i.e. week 0) plan
    ind_patient = find(extractRead.patient_mrn == mrns(i));
    plan_name = extractRead.plan_name(ind_patient);
   
    temp = ~cellfun(@isempty,regexpi(plan_name, 'wk 0')) | ~cellfun(@isempty,regexpi(plan_name, 'prelim'));
   
    ind_plan = ind_patient(temp);
    
    clear temp
    
    %% Find the "baseline" ROI
    ind_roi = find(strcmpi(extractRead.roi_name, baseline_roi_name));
    
    ind_baseline = intersect(ind_plan, ind_roi);
    
    %% Run a check...
    if numel(ind_baseline) ~= 1
        error(mrns(i))
    end
   
    %% Get the mean baseline HU
    img = load(fullfile(extractRead.project_patient{ind_baseline}, extractRead.image_file{ind_baseline}), 'array');
    img = img.array;

    mask = load(fullfile(extractRead.project_patient{ind_baseline}, extractRead.roi_file{ind_baseline}), 'mask');
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
    ind_2correct = intersect(ind_patient, ind_roi);
    
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

