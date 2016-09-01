function [out] = rawdvh_exportX(project_path, module, output_path)

try
    files = dir(fullfile(project_path,'Log'));

    %Find the most current _TEXTUREX file
    date = 0;
    for i = 1:numel(files)
        if ~isempty(regexpi(files(i).name,['_',module,'_doseX.mat$']))
            filedate = str2double(files(i).name(1:14));

            if filedate > date
                date = filedate;
            end
        end
    end
    
    %Create the filename
    filename = [num2str(date),'_',module,'_doseX.mat'];

    %Load the data
    dvh = load(fullfile(project_path,'Log',filename));
    

    %%
    bin_length = nan(numel(dvh.patient_mrn),1);
    for i = 1:numel(dvh.patient_mrn)
        bin_length(i) = length(dvh.bins_dvh{i});
    end

    out = dvh;

    out.diff_dvh = nan(numel(dvh.patient_mrn),max(bin_length));
    out.cumul_dvh = nan(numel(dvh.patient_mrn),max(bin_length));

    [~,ind] = max(bin_length);
    out.bins_dvh = dvh.bins_dvh{ind};

    for i = 1:numel(dvh.patient_mrn)
        out.diff_dvh(i,1:length(dvh.diff_dvh{i,1})) = dvh.diff_dvh{i,1};
        out.cumul_dvh(i,1:length(dvh.cumul_dvh{i,1})) = dvh.cumul_dvh{i,1};
    end
    
    if ~isempty(output_path)
        save(fullfile(output_path,['RAW',upper(module),'.mat']),'-struct','out')
    end
    
catch err
    out = [];
end