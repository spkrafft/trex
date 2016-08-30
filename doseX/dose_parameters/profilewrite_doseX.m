function [profile] = profilewrite_doseX(h)
%%Write the texture parameter profile to a cell array.
profile = cell(0);

for i = 1:numel(h.module_names)
    module = h.module_names{i};
    parameters = fieldnames(h.(module));    

    for j = 1:numel(parameters)
        if ischar(h.(module).(parameters{j}))
            profile{end+1,1} = module;
            profile{end,2} = parameters{j};
            profile{end,3} = h.(module).(parameters{j});
            
        else
            for k = 1:numel(h.(module).(parameters{j}))
                profile{end+1,1} = module;
                profile{end,2} = parameters{j};
                profile{end,3} = h.(module).(parameters{j}){k};
            end
        end
    end
end

%%
clearvars -except profile
