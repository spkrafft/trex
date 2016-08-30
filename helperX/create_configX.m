function create_configX(mainDir)

config = cell(0);
config{1,1} = 'notifier-mail = ';
config{2,1} = 'notifier-password = ';
config{3,1} = 'pinnacle-server = ';
config{4,1} = 'default-project = ';
config{5,1} = 'default-directory = ';

dlmcellX(fullfile(mainDir,'config.trex'),config)
