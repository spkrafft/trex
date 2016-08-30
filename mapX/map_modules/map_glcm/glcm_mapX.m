function [test_missing] = glcm_mapX(extractRead_entry,test_missing)
%% Do some preallocation...
num_missing = numel(test_missing.module);

test_missing.map_file = cell(num_missing,1);
test_missing.map_createdate = cell(num_missing,1);

fields_extract = fieldnames(extractRead_entry);
fields_test = fieldnames(test_missing);

%%
ind_param = cellfun(@(x) ~isempty(regexpi(x,'parameter_')),fields_test); 
fields_param = strrep(fields_test(ind_param),'parameter_','');

%% Load the data, do some sanity checks of the passed data first
project_patient = unique(extractRead_entry.project_patient); 
image_file = unique(extractRead_entry.image_file);
roi_file = unique(extractRead_entry.roi_file);
if numel(project_patient) == 1 && numel(image_file) == 1 && numel(roi_file) == 1 
    project_patient = project_patient{1};
    image_file = image_file{1};
    roi_file = roi_file{1};
else
    error('All of the data in extractRead_entry should have the same project_patient, image_file, and roi_file')
end
    
img = load(fullfile(project_patient,image_file),'array');
img = img.array;   

mask = load(fullfile(project_patient,roi_file),'mask');
mask = mask.mask;

[s,mess,messid] = mkdir(project_patient,'mapx');

%% Get some initial data about the parameters for the 'missing' (aka uncalcualted) data
test_missing.parameter_bd = cellfun(@str2double,test_missing.parameter_bd);
bds = unique(test_missing.parameter_bd);

%%
for i = 1:num_missing
    if isempty(test_missing.map_file{i})
        %%
        map = [];
        %Add fields from extractRead_entry
        for j = 1:numel(fields_extract)
            if ~strcmpi(fields_extract{j},'ftp')
                map.(fields_extract{j}) = extractRead_entry.(fields_extract{j})(1,:);
            end
        end

        %Add fields from test_missing
        for j = 1:numel(fields_test)
            map.(fields_test{j}) = test_missing.(fields_test{j})(i,:);
        end   

        %Change from cell2mat
        mNames = fieldnames(map);
        for j = 1:numel(mNames)
            if iscell(map.(mNames{j}))
                map.(mNames{j}) = cell2mat(map.(mNames{j}));
            end
        end 

        map.map_file = [];
        map.map_createdate = [];
        
        %%
        if strcmpi(map.parameter_offset,'3D')
            offset =   [1 0 0; 0 1 0; 0 0 1; 1 1 0; -1 1 0; 0 1 1; 0 1 -1; 1 0 1; 1 0 -1; 1 1 1; -1 1 1; 1 1 -1; -1 1 -1];
            dim = '3D';
        elseif isequal(map.parameter_offset,'2D')
            offset =   [1 0 0; 0 1 0; 1 1 0; -1 1 0];
            dim = '2D';
        else
            offset = eval(map.parameter_offset);
            if offset(3) == 0
                dim = '2D';
            else
                dim = '3D';
            end
        end

        [map.I,~,map.mask,map.crop] = prepCT(img,mask,...
                                             'Preprocess',map.parameter_preprocess,...
                                             'Pad',[0,0,0]);

        %Pad here instead of prep4Tex...prep4Tex stops at boundaries, but in
        %this case we don't want that...
        pre = floor(eval(map.parameter_block_size)/2);
        post = ceil(eval(map.parameter_block_size)/2) - 1;

        if strcmpi(dim,'3D')
            map.I = padarray(map.I,[pre,pre,pre],nan,'pre');
            map.mask = padarray(map.mask,[pre,pre,pre],false,'pre');
            map.crop = padarray(map.crop,[pre,pre,pre],nan,'pre');

            map.I = padarray(map.I,[post,post,post],nan,'post');
            map.mask = padarray(map.mask,[post,post,post],false,'post');
            map.crop = padarray(map.crop,[post,post,post],nan,'post');

        else
            map.I = padarray(map.I,[pre,pre,0],nan,'pre');
            map.mask = padarray(map.mask,[pre,pre,0],false,'pre');
            map.crop = padarray(map.crop,[pre,pre,0],nan,'pre');

            map.I = padarray(map.I,[post,post,0],nan,'post');
            map.mask = padarray(map.mask,[post,post,0],false,'post');
            map.crop = padarray(map.crop,[post,post,0],nan,'post');
        end

        disp('TREX-RT>> Starting GRAYCOMAP')

        if strcmpi(map.parameter_shift,'Random_2D')
            [X,Y,Z] = random2D_mask_points(map.mask,...
                                           eval(map.parameter_block_size),...
                                           eval(map.parameter_overlap));    
        else
            [X,Y,Z] = mask_points(map.mask,...
                                  eval(map.parameter_block_size),...
                                  eval(map.parameter_overlap),...
                                  eval(map.parameter_shift),...
                                  dim);
        end
%%
        out = glcm_map(map.I,X,Y,Z,...
                       'BitDepths',bds,...
                       'GrayLimits',eval(map.parameter_gl),...
                       'Distance',eval(map.parameter_dist),...
                       'Offset',offset);
                   
        name_stats = unique(out.all_stats);
%% 
        ind_bd = strcmpi(test_missing.parameter_block_size,map.parameter_block_size) & ...
              	 strcmpi(test_missing.parameter_overlap,map.parameter_overlap) & ...
                 strcmpi(test_missing.parameter_shift,map.parameter_shift) & ...
                 strcmpi(test_missing.parameter_preprocess,map.parameter_preprocess) & ...
                 strcmpi(test_missing.parameter_gl,map.parameter_gl) & ...
                 strcmpi(test_missing.parameter_dist,map.parameter_dist) & ...
                 strcmpi(test_missing.parameter_offset,map.parameter_offset);
        
        ind_bd = find(ind_bd);
%%
        for count_bd = 1:numel(ind_bd)
            for count_stats = 1:numel(name_stats)
                map.(name_stats{count_stats}) = [];
            end
            map.X = [];
            map.Y = [];
            map.Z = [];
            
            current_bd = test_missing.parameter_bd(ind_bd(count_bd));
            map.parameter_bd = num2str(current_bd);
            
            parameter_str = {'.'}; %This is used to group based on the unique combination of parameters
            for j = 1:numel(fields_param) %Loop over each parameter

                if strcmpi(fields_param{j},'bd')
                    parameter_str = strcat(parameter_str,{num2str(current_bd)},{'.'}); 
                else
                    %Concatenate the new parameters to parameter_str
                    parameter_str = strcat(parameter_str,map.(['parameter_',fields_param{j}]),{'.'}); 
                end
            end

            test_missing.map_file(ind_bd(count_bd)) = strcat('GLCM.MAP',parameter_str,map.roi_file);
            map.map_file = test_missing.map_file{ind_bd(count_bd)};
            test_missing.map_createdate{ind_bd(count_bd)} = datestr(now,'yyyymmddHHMMSS');
            map.map_createdate = test_missing.map_createdate{ind_bd(count_bd)};
%%
            for count_stats = 1:numel(name_stats)
                ind_temp = strcmpi(out.all_stats,name_stats{count_stats}) & ...
                           out.all_bd == current_bd;
                       
                map.(name_stats{count_stats}) = out.par_maps(:,ind_temp); 
            end
            map.X = out.X;
            map.Y = out.Y;
            map.Z = out.Z;
            
            disp(['TREX-RT>> Saving GRAYCOMAP: ',test_missing.map_file{ind_bd(count_bd)}])
            save(fullfile(project_patient,'mapx',test_missing.map_file{ind_bd(count_bd)}),'-struct','map')
        end 
    end
    
    clear out
    clear map    
end     

test_missing.parameter_bd = cellfun(@num2str,num2cell(test_missing.parameter_bd),'UniformOutput',false);

%%
clearvars -except test_missing
