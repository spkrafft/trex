%--------------------------------------------------------------------------
function [data_dir] = scanDir_dicomX(project_dir)
%%
w = waitbar(0,'Please wait...');

mainDir = fileparts(which('TREX'));
fields = readcsvX(fullfile(mainDir,'utilities','dicom_fields.trex'));

files = subdirX(project_dir);
numel(files)

[g] = emptyg(fields);
data_dir = cell(numel(files),numel(fieldnames(g)));

for j = 1:numel(files)
    waitbar(j/numel(files),w);

    [g] = emptyg(fields);

    if ~isempty(regexpi(files(j).name,'\w*.(img|dcm)')) || ~isempty(regexpi(files(j).name,'^(CT|PT)'))

        info = dicominfo(files(j).name);
%         info = dicominfo(fullfile(project_dir,files(j).name));
%         fields = fieldnames(info);

        for k = 1:numel(fields)
%             switch fields{k}
            try
                g.(['dicom_', fields{k}]) = info.(fields{k});
            catch err
            end

        end
    end

    data_dir(j,:) = struct2cell(g);
end

data_dir = [fieldnames(g)'; data_dir];

data_dir(all(cellfun(@isempty,data_dir),2),:) = [];
% data_dir = cell2dataset(data_dir);
% data_dir = cell2struct(data_dir(2:end,:),data_dir(1,:),2);

close(w)

% save('image_data.mat','data_dir')
%%
clearvars -except data_dir

%%
function [g] = emptyg(fields)

g = cell(0);

for i = 1:numel(fields)
   g.(['dicom_', fields{i}]) = '';
end
%
