function oldROI_deleteX(project_path)
%%
extractRead = read_extractX(project_path);

project_patient = unique(extractRead.project_patient);

for j = 1:numel(project_patient)
   list = dir(project_patient{j});
   
   for i = 1:numel(list)
      if ~isempty(regexpi(list(i).name, '^2015')) || ~isempty(regexpi(list(i).name, '^2014')) || ~isempty(regexpi(list(i).name, '^2013'))
          disp(list(i).name)
          delete(fullfile(project_patient{j},list(i).name))
      end
   end
end