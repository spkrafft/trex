function [preprocess_names,func_names,preprocess] = read_preprocess
%% Get the name of the preprocessing routines
mainDir = fileparts(which('read_preprocess'));

preprocess_names = cell(0);
func_names = cell(0);

list = dir(mainDir);
for i = 1:numel(list)
    if ~isempty(regexpi(list(i).name,'^preprocess(\w*).m$'))
        func_names{end+1,1} = strrep(list(i).name,'.m','');
        [~,preprocess_names{end+1,1}] = feval(func_names{end,1},1);
    end
end

preprocess = strrep(strrep(strrep(strrep(strrep(preprocess_names,' ','_'),'(',''),')',''),'/','_'),'.','p');

%%
clearvars -except preprocess_names func_names preprocess
