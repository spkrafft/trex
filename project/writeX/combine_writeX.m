function [moduleOut] = combine_writeX(module1,link1,module2,link2)

%Link1/link2 are the fields used to join data from module1 and module2
%%
m1 = [];
m2 = [];

if isfield(module1,'module')
    m1 = [module1.module{1},'_'];
end

if isfield(module2,'module')
    m2 = [module2.module{1},'_'];
end
%%
num1 = numel(module1.(link1));
num2 = numel(module2.(link2));
mrn = intersect(module1.(link1),module2.(link2));
i1 = ismember(module1.(link1),mrn);
i2 = ismember(module2.(link2),mrn);

%% Remove non-intersecting mrns from module1
fields1 = fieldnames(module1);
for fCount = 1:numel(fields1)
    if size(module1.(fields1{fCount}),1) == num1
        module1.(fields1{fCount}) = module1.(fields1{fCount})(i1,:);
    elseif size(module1.(fields1{fCount}),1) == 1
        module1.(fields1{fCount}) = module1.(fields1{fCount});
    else
        module1 = rmfield(module1,fields1{fCount});
    end
end

%% Remove non-intersecting mrns from module1
fields2 = fieldnames(module2);
for fCount = 1:numel(fields2)
    if size(module2.(fields2{fCount}),1) == num2
        module2.(fields2{fCount}) = module2.(fields2{fCount})(i2,:);
    elseif size(module2.(fields2{fCount}),1) == 1
        module2.(fields2{fCount}) = module2.(fields2{fCount});
    else
        module2 = rmfield(module2,fields2{fCount});
    end
end

%%
num1 = numel(module1.(link1)); % The number has now changed after removing the non-intersecting mrns
num2 = numel(module2.(link2));
[~,sor1] = sort(module1.(link1));
[~,sor2] = sort(module2.(link2));

%% Sort fields from module1
fields1 = fieldnames(module1);
for fCount = 1:numel(fields1)
    if size(module1.(fields1{fCount}),1) == num1
        module1.(fields1{fCount}) = module1.(fields1{fCount})(sor1,:);
    end
end

%% Sort fields from module2
fields2 = fieldnames(module2);
for fCount = 1:numel(fields2)
    if size(module2.(fields2{fCount}),1) == num2
        module2.(fields2{fCount}) = module2.(fields2{fCount})(sor2,:);
    end
end

%% Rename dvh, metric, feature fields for module 1
fields1 = fieldnames(module1);
for fCount = 1:numel(fields1)
    if ~isempty(regexpi(fields1{fCount},'^dvh')) ||...
            ~isempty(regexpi(fields1{fCount},'^metric_')) ||...
            ~isempty(regexpi(fields1{fCount},'^feature_')) ||...
            ~isempty(regexpi(fields1{fCount},'^log_file'))||...
            ~isempty(regexpi(fields1{fCount},'^module'))
        module1.([m1,fields1{fCount}]) = module1.(fields1{fCount});
        module1 = rmfield(module1,fields1{fCount});
    end
end

%% Rename dvh, metric, feature fields for module 2
fields2 = fieldnames(module2);
for fCount = 1:numel(fields2)
    if ~isempty(regexpi(fields2{fCount},'^dvh')) ||...
            ~isempty(regexpi(fields2{fCount},'^metric_')) ||...
            ~isempty(regexpi(fields2{fCount},'^feature_')) ||...
            ~isempty(regexpi(fields2{fCount},'^log_file'))||...
            ~isempty(regexpi(fields2{fCount},'^module'))
        module2.([m2,fields2{fCount}]) = module2.(fields2{fCount});
        module2 = rmfield(module2,fields2{fCount});
    end
end

%% Double check
if isequal(module1.(link1),module2.(link2))
else
    error('here')
end

%% Find intersecting/different fieldnames
fields1 = fieldnames(module1);
fields2 = fieldnames(module2);

diff1 = setdiff(fields1,fields2);
diff1 = fields1(ismember(fields1,diff1));

diff2 = setdiff(fields2,fields1);
diff2 = fields2(ismember(fields2,diff2));

same = intersect(fields1,fields2);
same = fields1(ismember(fields1,same)); %Done with ismember to preserve original ordering of fields

%% Combine data
moduleOut = [];

for fCount = 1:numel(same)
    if isequal(module1.(same{fCount}), module2.(same{fCount}))
        moduleOut.(same{fCount}) = module1.(same{fCount});
    else
        error('here1') %All fields with the same name that contain different data should have already been renamed
    end
end

%%
if ~isempty(diff1)
    for fCount = 1:numel(diff1)
        moduleDiff.(diff1{fCount}) = module1.(diff1{fCount});
    end
end

%%
if ~isempty(diff2)
    for fCount = 1:numel(diff2)
        moduleDiff.(diff2{fCount}) = module2.(diff2{fCount});
    end
end

%%
fieldsDiff = fieldnames(moduleDiff);
for fCount = 1:numel(fieldsDiff)
    moduleOut.(fieldsDiff{fCount}) = moduleDiff.(fieldsDiff{fCount});
end

%%
clearvars -except moduleOut
