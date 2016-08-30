function [extractWrite] = imageConvert_pinnacle_extractX(extractWrite,extractRead,entry)
%%
%Look for the converted image
files = dir(extractWrite.project_patient);

found = false;
for i = 1:numel(files)
    if strcmpi(files(i).name,extractWrite.image_file)
        found = true;
        break
    end
end

%If not found, then convert it...
if ~found
    disp(['TREX-RT>> Entry ',num2str(entry),': Reading image...'])  

    image = imageRead_pinnacle_extractX(extractWrite);

    extractWrite.convertImage = true;
    extractWrite.convertImage_datestr = datestr(now,'yyyymmddHHMMSS');
    
    save(fullfile(extractWrite.project_patient,extractWrite.image_file),'-struct','image')  
    save(fullfile(extractWrite.project_patient,extractWrite.image_file),'-struct','extractWrite','-append')

    disp(['TREX-RT>> Entry ',num2str(entry),': Image saved ',extractWrite.image_file])
else
    extractWrite.convertImage = true;
    extractWrite.convertImage_datestr = extractRead.convertImage_datestr;
end

%%
clearvars -except extractWrite
