function [extractRead] = read_extractX(project_path,varargin)

disp_flag = true;

if nargin > 1
    disp_flag = varargin{1};
    if ~islogical(disp_flag)
        error('I should really validate attributes...')
    end
end

%%
extractRead = [];

try
    files = dir(fullfile(project_path,'Log'));

    %Find the most current _extractX file
    date = 0;
    for i = 1:numel(files)
        if ~isempty(regexpi(files(i).name,'_extractX.mat$'))
            filedate = str2double(files(i).name(1:14));

            if filedate > date
                date = filedate;
            end
        end
    end
    
    extractRead = load(fullfile(project_path,'Log',[num2str(date),'_extractX.mat']));
    
    if disp_flag
        disp(['TREX-RT>> Importing extractX data: ',num2str(date),'_extractX.mat']);
    end
    
catch err
    
end

%%
clearvars -except extractRead
