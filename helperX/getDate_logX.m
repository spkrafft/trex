function [date] = getDate_logX(project_path,module)
% Returns 0 if file not found

date = 0;
files = dir(fullfile(project_path,'Log'));

% Look for a file matching the module
good = 0;
for i = 1:numel(files)
    if ~isempty(regexpi(files(i).name,['(\w*)_',module,'(\w*)X.mat']))
        good = 1;
        break
    end
end

if ~good
    return
end

% Find the most recent one to read in
for i = 1:numel(files)
    if ~isempty(regexpi(files(i).name,['(\w*)_',module,'(\w*)X.mat']))
%         filedate = str2double(strrep(files(i).name,['_',module,'X.mat'],''));
        filedate = str2double(files(i).name(1:14));
        
        if filedate > date
            date = filedate;
        end
    end
end

%%
clearvars -except date
