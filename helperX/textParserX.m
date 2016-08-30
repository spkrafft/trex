function [str,row] = textParserX(text,field)
%%
if ~iscell(text)
    disp('Input text data is not cell array')
end

for row = 1:numel(text)
    if ~isempty(regexpi(text{row},[field,'\w*']))
        str = text{row};
        break
    else
        str = ' ';
    end
end

if ~strcmpi(str,' ')
    [index] = regexpi(str,'"');
    if numel(index) == 2    %Just take the string within quoutes
        str = str(index(1)+1:index(2)-1);
    else    %Otherwise, take whatever is after an = or :
        [index] = regexpi(str,'[=:]');
        index = index(1);   %Just take the first index in case there are multiple =/: (i.e. time stamps)

        %If there is a space after the delimiting character, ignore it
        if strcmpi(str(index+1),' ')
            str = str(index+2:end); 
        else
            str = str(index+1:end);
        end

        if numel(str) > 0
            if strcmpi(str(end),';')
                str = strrep(str,';','');
            elseif strcmpi(str(end),',')
                str = strrep(str,',','');
            end
        end
    end
end

%%
clearvars -except str row
