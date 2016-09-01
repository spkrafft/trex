function [h] = profileread_doseX(h,profile)
%% Read parameter profile list and sort into appropriate fields
for i = 1:size(profile,1)
    module = profile{i,1};
    parameter = profile{i,2};

    if strcmpi(parameter,'toggle')
        h.(module).(parameter) = profile{i,3}; 
    else
        h.(module).(parameter){end+1,1} = profile{i,3}; 
    end
end
            
%%
clearvars -except h
