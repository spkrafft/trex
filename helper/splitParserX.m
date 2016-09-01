function [split,rows] = splitParserX(text,field)
%%
if ~iscell(text)
    disp('Input text data is not cell array')
end

split = cell(0);

[~,loc] = regexpi(text,[field,'\w*'],'split');
emptyCells = cellfun(@isempty,loc);
rows = find(emptyCells==0);

if isempty(rows)
    split = text;
else
    for i = 1:numel(rows)
        if i == numel(rows)
            split{end+1,1} = text(rows(i):end);
        else
            split{end+1,1} = text(rows(i):rows(i+1)-1);
        end
    end
end

%%
clearvars -except split rows
