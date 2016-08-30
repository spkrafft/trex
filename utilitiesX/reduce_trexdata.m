function reduce_trexdata(data_path)
%%
modules = {'HIST','GLCM','GLRLM','NGTDM','LAWS2D','LUNG','SHAPE'};
%%
for i = 1:length(modules)
    %%
    read_dat = load(fullfile(data_path,modules{i}));
    
    out = cell(0);
    out.patient_mrn = read_dat.patient_mrn;
    out.plan_name = read_dat.plan_name;
    out.image_seriesUID = read_dat.image_seriesUID;
    out.parameter_headings = read_dat.parameter_headings;
    out.parameter_names = read_dat.parameter_names;
    out.feature_names = read_dat.feature_names;
    out.feature_space = read_dat.feature_space;
    
    save(fullfile(data_path,[modules{i},'_reduce.mat']),'-struct','out')
end

