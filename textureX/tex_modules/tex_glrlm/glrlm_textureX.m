function [test_missing] = glrlm_textureX(extractRead_entry,test_missing)
%% Do some preallocation...
num_missing = numel(test_missing.module);
calculated = false(num_missing,1);

stats = glrlm_features(1);
featureNames = fieldnames(stats);
for nameCount = 1:length(featureNames)    
    test_missing.(['feature_',featureNames{nameCount}]) = nan(num_missing,1);
end

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

%% Get some initial data about the parameters for the 'missing' (aka uncalcualted) data
preprocess = unique(test_missing.parameter_preprocess); %get the unique preprocess names

gl = unique(test_missing.parameter_gl); %get the unique gray limits

test_missing.parameter_bd = cellfun(@str2double,test_missing.parameter_bd);
max_bd = max(test_missing.parameter_bd); %get some information about the bds...
min_bd = min(test_missing.parameter_bd);

%% -----Preprocess Loop-----
for count_preprocess = 1:length(preprocess) %Start loop over each preprocess...
    %Start with each preprocess so we don't have to do this
    %preprocessing/preprocessing every time...helps speed things up, especially
    %in the instances where the applied preprocess takes awhile.

    %Prep the data to get the image I that will be passed into the analysis
    %routines
    [I,current_preprocess] = prepCT(img,mask,'preprocess',preprocess{count_preprocess});

    ind_preprocess = strcmpi(test_missing.parameter_preprocess,current_preprocess); %logical index for current preprocess

    %% -----Gray Limits Loop-----
    for count_gl = 1:length(gl) %start loop over each gray limit...
        current_gl = gl{count_gl}; %get the current distance
        
        ind_gl = strcmpi(test_missing.parameter_gl,current_gl); %logical index for current gray limits
        ind_gl_preprocess = ind_gl & ind_preprocess & ~calculated; %logical index for current gray limit and preprocess, not calculated
        
        %% -----3D-----
        %First look for 3D...we can use this to fill the 2D and 1D offsets
        ind_3d = strcmpi(test_missing.parameter_offset,'3D'); %logical index for the 3D
        ind_3d_gl_preprocess = ind_3d & ind_gl_preprocess & ~calculated; %logical index for 3D, current preprocess, not calculated       

        if sum(ind_3d_gl_preprocess) > 0 %if no entries with 3D, skip this
            for current_bd = max_bd:-1:min_bd %count from max to min bit depth
                ind_bd = test_missing.parameter_bd == current_bd; %logical index for current bit depth
                ind_bd_3d_gl_preprocess = ind_bd & ind_3d_gl_preprocess & ~calculated; %logical index for the max bit depth, 3D, current preprocess, not calculated

                if sum(ind_bd_3d_gl_preprocess) > 1%We should have no more than one entry at this point.
                    error('We should have no more than one entry at this point.') 
                end

                if sum(ind_bd_3d_gl_preprocess) == 0 %If there are no indices for the current bit depth, continue.
                    continue
                end   

                offset = [1 0 0; 0 1 0; 0 0 1; 1 1 0; -1 1 0; 0 1 1; 0 1 -1; 1 0 1; 1 0 -1; 1 1 1; -1 1 1; 1 1 -1; -1 1 -1];

                %Print to the command window...           
                disp(['TREX-RT>> Preprocess (',current_preprocess,'), ',...
                                'Bit Depth (',num2str(current_bd),'), ',...
                                'Gray Limits (',current_gl,'), ',...
                                'Offset (',test_missing.parameter_offset{ind_bd_3d_gl_preprocess,:},')']);

                %Calculate the GLRLM
                [glrlm,~,~] = glrlm_matrix3D(I,...
                                             'NumLevels',2^current_bd,...
                                             'GrayLimits',eval(current_gl),...
                                             'Offset',offset);

                stats_all = glrlm_features(glrlm); %calc stats from the 3D glrlm

                %Write 3D stats to test_missing
                for nameCount = 1:length(featureNames)
                    test_missing.(['feature_',featureNames{nameCount}])(ind_bd_3d_gl_preprocess) = mean(stats_all.(featureNames{nameCount}));
                end

                calculated(ind_bd_3d_gl_preprocess) = true;

                %Write any 2D stats if they are missing
                ind_2d = strcmpi(test_missing.parameter_offset,'2D'); %logical index for the 2D
                ind_bd_2d_gl_preprocess = ind_bd & ind_2d & ind_gl_preprocess & ~calculated; %logical index for the max bit depth, 2D, current preprocess, not calculated

                if sum(ind_bd_2d_gl_preprocess) == 1
                    only2D = glrlm_orderMatrix(glrlm,offset,[1 0 0; 0 1 0; 1 1 0; -1 1 0]); %get only the 2D glrlms
                    stats_only2D = glrlm_features(only2D); %calc stats from the 2D glrlms

                    %Write 2D stats to test_missing
                    for nameCount = 1:length(featureNames)    
                        test_missing.(['feature_',featureNames{nameCount}])(ind_bd_2d_gl_preprocess) = mean(stats_only2D.(featureNames{nameCount}));
                    end

                    calculated(ind_bd_2d_gl_preprocess) = true;
                elseif sum(ind_bd_2d_gl_preprocess) > 1 %We should have no more than one entry at this point.
                    error('We should have no more than one entry at this point.') 
                end

                %Write any 1D stats if they are missing
                for oCount = 1:size(offset,1) %start loop over each offset
                    ind_1d = strcmpi(test_missing.parameter_offset,mat2str(offset(oCount,:))); %logical index for the 1D
                    ind_bd_1d_gl_preprocess = ind_bd & ind_1d & ind_gl_preprocess & ~calculated; %logical index for the max bit depth, 1D, current preprocess, not calculated

                    if sum(ind_bd_1d_gl_preprocess) == 1

                        %Write 1D stats to test_missing
                        for nameCount = 1:length(featureNames)    
                            test_missing.(['feature_',featureNames{nameCount}])(ind_bd_1d_gl_preprocess) = stats_all.(featureNames{nameCount})(oCount);
                        end

                        calculated(ind_bd_1d_gl_preprocess) = true;
                    elseif sum(ind_bd_1d_gl_preprocess) > 1 %We should have no more than one entry at this point.
                        error('We should have no more than one entry at this point.') 
                    end
                end %end loop over each offset        
            end %end count from max to min bit depth                
        end

        %% -----2D-----
        %First look for 2D...we can use this to fill the1D offsets
        ind_2d = strcmpi(test_missing.parameter_offset,'2D'); %logical index for the 2D
        ind_2d_gl_preprocess = ind_2d & ind_gl_preprocess & ~calculated; %logical index for 2D, current preprocess, not calculated        

        if sum(ind_2d_gl_preprocess) > 0 %if no entries with 2D, skip this         
            for current_bd = max_bd:-1:min_bd %count from max to min bit depth
                ind_bd = test_missing.parameter_bd == current_bd; %logical index for current bit depth
                ind_bd_2d_gl_preprocess = ind_bd & ind_2d_gl_preprocess & ~calculated; %logical index for the max bit depth, 3D, current preprocess, not calculated

                if sum(ind_bd_2d_gl_preprocess) > 1%We should have no more than one entry at this point.
                    error('We should have no more than one entry at this point.') 
                end

                if sum(ind_bd_2d_gl_preprocess) == 0 %If there are no indices for the current bit depth, continue. 
                    continue
                end  

                offset = [1 0 0; 0 1 0; 1 1 0; -1 1 0];

                %Print to the command window...           
                disp(['TREX-RT>> Preprocess (',current_preprocess,'), ',...
                                'Bit Depth (',num2str(current_bd),'), ',...
                                'Gray Limits (',current_gl,'), ',...
                                'Offset (',test_missing.parameter_offset{ind_bd_2d_gl_preprocess,:},')']);

                %Calculate the GLRLM
                [glrlm,~,~] = glrlm_matrix3D(I,...
                                             'NumLevels',2^current_bd,...
                                             'GrayLimits',eval(current_gl),...
                                             'Offset',offset);

                stats_2Donly = glrlm_features(glrlm); %calc stats from the 2D glrlm

                %Write 2D stats to test_missing
                for nameCount = 1:length(featureNames)
                    test_missing.(['feature_',featureNames{nameCount}])(ind_bd_2d_gl_preprocess) = mean(stats_2Donly.(featureNames{nameCount}));
                end

                calculated(ind_bd_2d_gl_preprocess) = true;

                % Write any 1D stats if they are missing
                for oCount = 1:size(offset,1) %start loop over each offset
                    ind_1d = strcmpi(test_missing.parameter_offset,mat2str(offset(oCount,:))); %logical index for the 1D
                    ind_bd_1d_gl_preprocess = ind_bd & ind_1d & ind_gl_preprocess & ~calculated; %logical index for the max bit depth, 1D, current preprocess, not calculated

                    if sum(ind_bd_1d_gl_preprocess) == 1
                        %Write 1D stats to test_missing
                        for nameCount = 1:length(featureNames)    
                            test_missing.(['feature_',featureNames{nameCount}])(ind_bd_1d_gl_preprocess) = stats_2Donly.(featureNames{nameCount})(oCount);
                        end

                        calculated(ind_bd_1d_gl_preprocess) = true;
                    elseif sum(ind_bd_1d_gl_preprocess) > 1 %We should have no more than one entry at this point.
                        error('We should have no more than one entry at this point.') 
                    end
                end %end loop over each offset
            end %end count from max to min bit depth                
        end

        %% -----1D-----
        %Then do any of the leftovers
        ind_1d_gl_preprocess = ~ind_2d & ~ind_3d & ind_gl_preprocess & ~calculated; %logical index for 1D, current preprocess, not calculated        

        if sum(ind_1d_gl_preprocess) > 0 %if no entries with 2D, skip this         
            for current_bd = max_bd:-1:min_bd %count from max to min bit depth
                ind_bd = test_missing.parameter_bd == current_bd; %logical index for current bit depth
                ind_bd_1d_gl_preprocess = ind_bd & ind_1d_gl_preprocess & ~calculated; %logical index for the max bit depth, 3D, current preprocess, not calculated

                if sum(ind_bd_1d_gl_preprocess) == 0 %If there are no indices for the current bit depth, continue. 
                    continue
                end  

                offset = test_missing.parameter_offset(ind_bd_1d_gl_preprocess);
                offset = str2num(char(unique(offset)));

                gl = test_missing.parameter_gl{find(ind_bd_1d_gl_preprocess,1,'first')};

                %Print to the command window...           
                disp(['TREX-RT>> Preprocess (',current_preprocess,'), ',...
                                'Bit Depth (',num2str(current_bd),'), ',...
                                'Gray Limits (',gl,'), ',...
                                'Offset (',mat2str(offset),')']);

                %Calculate the GLRLM
                [glrlm,~,~] = glrlm_matrix3D(I,...
                                             'NumLevels',2^current_bd,...
                                             'GrayLimits',eval(gl),...
                                             'Offset',offset);

                stats_1D = glrlm_features(glrlm); %calc stats from the glrlm

                % Write any 1D stats if they are missing
                for oCount = 1:size(offset,1) %start loop over each offset
                    ind_1d = cellfun(@isequal,test_missing.parameter_offset,repmat({offset(oCount,:)},[num_missing,1])); %logical index for the 1D
                    ind_1d = ind_1d & ind_bd_1d_gl_preprocess & ~calculated; %logical index for the max bit depth, 1D, current preprocess, not calculated

                    if sum(ind_1d) == 1
                        %Write 1D stats to test_missing
                        for nameCount = 1:length(featureNames)    
                            test_missing.(['feature_',featureNames{nameCount}])(ind_1d) = stats_1D.(featureNames{nameCount})(oCount);
                        end

                        calculated(ind_1d) = true;
                    elseif sum(ind_1d) > 1 %We should have no more than one entry at this point.
                        error('We should have no more than one entry at this point.') 
                    end
                end %end loop over each offset
            end %end count from max to min bit depth                
        end
    end %end loop over each gl
end  %end loop over each preprocess

test_missing.parameter_bd = cellfun(@num2str,num2cell(test_missing.parameter_bd),'UniformOutput',false);

%%
clearvars -except test_missing
