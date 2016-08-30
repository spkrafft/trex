function roiCheck_pinnacle_extractX(extractRead,entry)
%%
disp(['TREX-RT>> Entry ',num2str(entry),': Checking roi...'])

%Look for previously converted roi data...
files = dir(extractRead.project_patient);
found = false;
for i = 1:numel(files)
    if strcmpi(files(i).name,extractRead.roi_file)
        found = true;
        break
    end
end

if ~found
    %Do nothing
else
    %Check the file
    oldroi = load(fullfile(extractRead.project_patient,extractRead.roi_file));

    oldroi.namelist = cell(0);
    if isfield(oldroi,'data')
        for cellInd = 1:numel(oldroi.data)
            [oldroi.namelist{end+1,1}] = textParserX(oldroi.data{cellInd},'name');
        end
    end
  
    newroi = [];
    fid = fopen(fullfile(extractRead.project_roidata,'plan.roi'));
    newroi.data = textscan(fid,'%s','delimiter','\n');
    newroi.data = newroi.data{1};
    fclose(fid);
    newroi.data = splitParserX(newroi.data,'roi={');
    newroi.namelist = cell(0);
    for cellInd = 1:numel(newroi.data)
        newroi.namelist{end+1,1} = textParserX(newroi.data{cellInd},'name');
    end

    names = cell(0);
    if ~isempty(extractRead.roi_source)
        names = [names,regexpi(extractRead.roi_source,'/','split')];
    end

    if ~isempty(extractRead.roi_int)
        names = [names,regexpi(extractRead.roi_int,'/','split')];
    end

    if ~isempty(extractRead.roi_ext)
        names = [names,regexpi(extractRead.roi_ext,'/','split')];
    end

    for i = numel(names):-1:1
        if ~isempty(regexpi(names{i},'Subvolume')) 
            i1 = regexpi(names{i},'(');
            names{i} = names{i}(1:i1-2);
            
        elseif ~isempty(extractRead.dose_name) && ~isempty(regexpi(names{i},['(',extractRead.dose_name,')']))
            names(i) = [];
        end
    end

    names = unique(names);

    good = true;
    if ~isempty(setdiff(names,oldroi.namelist)) || ~isempty(setdiff(names,oldroi.namelist))
        %If there is an roi identified from sourc/ext/int that doesn't
        %match, then no good...
        good = false;
    else       
        if numel(intersect(oldroi.namelist,names))~= numel(intersect(newroi.namelist,names))
            %If one of the source/ext/int rois does not exist on either the
            %old or new data, then no good...
            good = false;    
        else
            for i = 1:numel(names)
                %Cycle through each source/ext/int...
                [~,oldind] = intersect(oldroi.namelist,names{i});
                [~,newind] = intersect(newroi.namelist,names{i});
                
                oldcurve = splitParserX(oldroi.data{oldind},'num_curve =');        
                oldcurve = oldcurve{1};
                junk = splitParserX(oldcurve,'surface_mesh={');
                junk = junk{1};
                oldcurve = oldcurve(1:(length(oldcurve)-length(junk)));

                newcurve = splitParserX(newroi.data{newind},'num_curve =');        
                newcurve = newcurve{1};
                junk = splitParserX(newcurve,'surface_mesh={');
                junk = junk{1};
                newcurve = newcurve(1:(length(newcurve)-length(junk)));
            
                if ~isequal(oldcurve,newcurve)
                    %If the old and new roi data don't match, then no
                    %good...
                    good = false;
                    break
                end
            end
        end
    end

    if ~good
        disp(['TREX-RT>> Entry ',num2str(entry),': Checking roi...file changed!'])
        
        time = datestr(now,'yyyymmddHHMMSS');
        
        %Also try to delete the previously converted roi data to force the new
        %roi data to be converted
        try
            %This will move all of the roi files with the same internal
            %UID to force recalculation of everything
            roifiles = dir(extractRead.project_patient);
            for i = 1:numel(roifiles)
                if ~isempty(regexpi(roifiles(i).name,[extractRead.roi_internalUID,'.mat$']))
                    movefile(fullfile(extractRead.project_patient,roifiles(i).name),fullfile(extractRead.project_patient,[time,'_',roifiles(i).name]));
                end
            end
        catch err
        end

        %Also delete any previously calculated mapx stuff
        try
            mapfiles = dir(fullfile(extractRead.project_patient,'mapx'));
            for i = 1:numel(mapfiles)
                if ~isempty(regexpi(mapfiles(i).name,[extractRead.roi_internalUID,'.mat$']))
                    movefile(fullfile(extractRead.project_patient,'mapx',mapfiles(i).name),fullfile(extractRead.project_patient,'mapx',[time,'_',mapfiles(i).name]));
                end
            end
        catch err
        end
    end
end

disp(['TREX-RT>> Entry ',num2str(entry),': Checking roi...DONE'])

%%
clearvars
