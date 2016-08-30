function [extractWrite] = roiDownload_pinnacle_extractX(extractWrite,extractRead,entry)
%%
extractWrite.project_roidata = fullfile(extractWrite.project_pinndata,['ROI.',extractWrite.roi_internalUID]);
extractWrite.roi_file = ['ROI.',extractWrite.roi_name,'.',extractWrite.roi_internalUID,'.mat'];

[s,mess,messid] = mkdir(extractWrite.project_pinndata,['ROI.',extractWrite.roi_internalUID]);
disp(['TREX-RT>> Entry ',num2str(entry),': ','ROI data directory ',extractWrite.project_roidata]);

%Check for a previously downloaded roi file...
files = dir(extractWrite.project_roidata);
found = false;
for i = 1:numel(files)
    if strcmpi(files(i).name,'plan.roi')
        found = true;
        break
    end
end

%If roi file has already been downloaded...
if found
    %Read the previously downloaded data...
    fid = fopen(fullfile(extractWrite.project_roidata,'plan.roi'));
    roi = textscan(fid,'%s','delimiter','\n');
    roi = roi{1};
    fclose(fid);        

    %Download/copy the new roi data...
    if extractWrite.remote
        extractWrite.ftp = ftp(extractWrite.server_name,extractWrite.server_user,extractWrite.server_pass);
        cd(extractWrite.ftp,extractWrite.plan_path);

        dlPath = mget(extractWrite.ftp,'plan.roi',extractWrite.project_path);
        dlPath = dlPath{1};
        
        pPath = mget(extractWrite.ftp,'plan.Pinnacle',extractWrite.project_path);
        pPath = pPath{1};

        close(extractWrite.ftp);
    else
        copyfile(fullfile(extractWrite.plan_path,'plan.roi'),extractWrite.project_path);
        dlPath = fullfile(extractWrite.project_path,'plan.roi');
        
        copyfile(fullfile(extractWrite.plan_path,'plan.Pinnacle'),extractWrite.project_path);
        pPath = fullfile(extractWrite.project_path,'plan.Pinnacle');
    end

    %...and read it
    fid = fopen(dlPath);
    dlROI = textscan(fid,'%s','delimiter','\n');
    dlROI = dlROI{1};
    fclose(fid);
  
    %Start with the assumption that the previous data is correct...
    good = true;
        
    if isequal(roi,dlROI)
        %They are the same and we don't need to redownload
        delete(dlPath)
        delete(pPath)  
        
        extractWrite.dlROI = true;
        extractWrite.dlROI_datestr = extractRead.dlROI_datestr;
    else
        %Compare the previous roi data to the downloaded data and if they
        %are not the same then...
        
        %So this is a bit convoluted...but I don't want to have to rewrite
        %all of the roimask data if the curve data is the same...say if the
        %only thing that has changed is the file date. So...this goes
        %through and parses each roi structure and selects just the
        %curve/point data for each structure and compares them. If there is
        %any detected difference, the previous mask data is removed,
        %otherwiese it is left as is.
        oldroi = [];
        oldroi.data = splitParserX(roi,'roi={');
        newroi = [];
        newroi.data = splitParserX(dlROI,'roi={');

        oldroi.namelist = cell(0);
        for cellInd = 1:numel(oldroi.data)
            oldroi.namelist{end+1,1} = textParserX(oldroi.data{cellInd},'name');
        end
        
        newroi.namelist = cell(0);
        for cellInd = 1:numel(newroi.data)
            newroi.namelist{end+1,1} = textParserX(newroi.data{cellInd},'name');
        end

        names = cell(0);
        if ~isempty(extractWrite.roi_source)
            names = [names,regexpi(extractWrite.roi_source,'/','split')];
        end
        
        if ~isempty(extractWrite.roi_int)
            names = [names,regexpi(extractWrite.roi_int,'/','split')];
        end
        
        if ~isempty(extractWrite.roi_ext)
            names = [names,regexpi(extractWrite.roi_ext,'/','split')];
        end
        
        for i = numel(names):-1:1
            if ~isempty(regexpi(names{i},'Subvolume'))
                i1 = regexpi(names{i},'(');
                names{i} = names{i}(1:i1-2);
            elseif ~isempty(extractWrite.dose_name) && ~isempty(regexpi(names{i},['(',extractWrite.dose_name,')']))
                names(i) = [];
            end
        end
        
        names = unique(names);
        
        if numel(intersect(oldroi.namelist,names)) ~= numel(names)
            %Here we are checking that all of the names in the extractWrite of
            %interest are contained in the old plan.roi data. If they
            %aren't then this is license to try to delete the old roi data
            %(which shouldn't even exist), and to then proceed.
            good = false; 
        else
            for i = 1:numel(names)
                oldind = strcmpi(oldroi.namelist,names{i});
                newind = strcmpi(newroi.namelist,names{i});
                
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
                    good = false;
                    break
                end
            end 
        end
        
        if good
            delete(dlPath)
            delete(pPath)  
        
            extractWrite.dlROI = true;
            extractWrite.dlROI_datestr = extractRead.dlROI_datestr;
        else
            time = datestr(now,'yyyymmddHHMMSS');
            %Find all of the previous roi data files and rename them
            %(just by appending the time). I want to save these rather than
            %delete them in case we need to revert back to the original
            %data for whatever reason.
            movefile(fullfile(extractWrite.project_roidata,'plan.roi'),fullfile(extractWrite.project_roidata,[time,'_plan.roi']));
            movefile(fullfile(extractWrite.project_roidata,'plan.Pinnacle'),fullfile(extractWrite.project_roidata,[time,'_plan.Pinnacle']));

            movefile(dlPath,fullfile(extractWrite.project_roidata,'plan.roi'));
            movefile(pPath,fullfile(extractWrite.project_roidata,'plan.Pinnacle'));

            extractWrite.dlROI = true;
            extractWrite.dlROI_datestr = datestr(now,'yyyymmddHHMMSS');
            disp(['TREX-RT>> Entry ',num2str(entry),': ','ROI data downloaded/copied to ',extractWrite.project_roidata]);

            %Also try to delete the previously converted roi data to force the new
            %roi data to be converted
            try
                %This will move all of the roi files with the same internal
                %UID to force recalculation of everything
                roifiles = dir(extractWrite.project_patient);
                for i = 1:numel(roifiles)
                    if ~isempty(regexpi(roifiles(i).name,[extractWrite.roi_internalUID,'.mat$']))
                        movefile(fullfile(extractWrite.project_patient,roifiles(i).name),fullfile(extractWrite.project_patient,[time,'_',roifiles(i).name]));
                    end
                end
            catch err
            end
            
            %Also delete any previously calculated mapx stuff
            try
                mapfiles = dir(fullfile(extractWrite.project_patient,'mapx'));
                for i = 1:numel(mapfiles)
                    if ~isempty(regexpi(mapfiles(i).name,[extractWrite.roi_internalUID,'.mat$']))
                        movefile(fullfile(extractWrite.project_patient,'mapx',mapfiles(i).name),fullfile(extractWrite.project_patient,'mapx',[time,'_',mapfiles(i).name]));
                    end
                end
            catch err
            end
            
            disp(['TREX-RT>> Entry ',num2str(entry),': ROI data has changed']);
        end
    end
else
    %Download/copy if it doesn't exist, if ~found
    if extractWrite.remote
        extractWrite.ftp = ftp(extractWrite.server_name,extractWrite.server_user,extractWrite.server_pass);
        cd(extractWrite.ftp,extractWrite.plan_path);

        mget(extractWrite.ftp,'plan.roi',extractWrite.project_roidata);
        mget(extractWrite.ftp,'plan.Pinnacle',extractWrite.project_roidata);

        close(extractWrite.ftp);
    else
        copyfile(fullfile(extractWrite.plan_path,'plan.roi'),extractWrite.project_roidata);
        copyfile(fullfile(extractWrite.plan_path,'plan.Pinnacle'),extractWrite.project_roidata);
    end

    extractWrite.dlROI = true;
    extractWrite.dlROI_datestr = datestr(now,'yyyymmddHHMMSS');
    disp(['TREX-RT>> Entry ',num2str(entry),': ','ROI data downloaded/copied to ',extractWrite.project_roidata]);
end

%%
clearvars -except extractWrite
