function [output] = readcsvX(filename)
%%
fid = fopen(filename);   % Open the file

lineIndex = 1;               % Index of cell to place the next line in
nextLine = fgetl(fid);       % Read the first line from the file
while ~isequal(nextLine,-1)         % Loop while not at the end of the file
    lineArray{lineIndex} = nextLine;  % Add the line to the cell array
    lineIndex = lineIndex+1;          % Increment the line index
    nextLine = fgetl(fid);            % Read the next line from the file
end
fclose(fid);

for i = 1:lineIndex-1              % Loop over lines
    lineData = textscan(lineArray{i},'%s','Delimiter',',');
    lineData = lineData{1};  
    % Remove cell encapsulation
    if strcmp(lineArray{i}(end),',')  % Account for when the line
      lineData{end+1} = '';                     %   ends with a delimiter
    end
    output(i,1:numel(lineData)) = lineData;  % Overwrite line data
end

%%
clearvars -except output
