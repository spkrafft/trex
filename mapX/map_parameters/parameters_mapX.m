function parameters = parameters_mapX(input_profile)
% PARAMETERS_MAPX Create programmatic GUI with uitree to select
%   parameters for testureX
%
%   Notes
%   -----
%   Blerg...used nested functions for the callbacks to get the correct
%   output when the figure is closed.
%
%   Parts are borrowed from uitree code posted on the undocumentedmatlab 
%   blog (http://undocumentedmatlab.com/blog/customizing-uitree-nodes-2)
%
%   $SPK

import javax.swing.*
import javax.swing.tree.*;
 
h.profile = input_profile;

% figure window
f = figure('Units','normalized','Position',[0 0 0.25 0.50],...
           'Menubar','none',...
           'WindowStyle','modal',...
           'CloseRequestFcn',@myCloseRequestFcn);
       
    %--------------------------------------------------------------------------
    function myCloseRequestFcn(hObject,~)

        selection = questdlg('Apply currently selected parameters?',...
                             'Map Parameters',...
                             'Apply','No','No'); 
        switch selection, 
            case 'Apply',
                h.apply = true;
            case 'No'
                h.apply = false;
        end

        if isequal(get(hObject, 'waitstatus'), 'waiting')
            uiresume(hObject);
        else
            delete(hObject);
        end
        
        clear
    end  %end of myCloseRequestFcn
    %--------------------------------------------------------------------------  
       
movegui(f,'center')

[h] = parameterfields_mapX(h);

[I,map] = checkedIcon;
h.javaImage_checked = im2java(I,map);
 
[I,map] = uncheckedIcon;
h.javaImage_unchecked = im2java(I,map);
 
% h.javaImage_checked/unchecked are assumed to have the same width
iconWidth = h.javaImage_unchecked.getWidth;
 
h.node.root = uitreenode('v0','root','Image Feature Extraction Parameters',[],0);

for mCount = 1:numel(h.module_names)
    h = createNodes(h,h.module_names{mCount});
end
 
mainDir = fileparts(which('TREX'));
h.parameter_path = fullfile(mainDir,'mapX','Map Parameter Profiles');

if isempty(h.profile)
    h.profile = readcsvX(fullfile(h.parameter_path,'parameters_default.trex'));
end

%Load all profiles
for mCount = 1:numel(h.module_names)
   loadProfile(h,h.module_names{mCount}) 
end
    
% set treeModel
treeModel = DefaultTreeModel(h.node.root);
 
% create the tree
tree = uitree('v0');
tree.setModel(treeModel);

% we often rely on the underlying java tree
jtree = handle(tree.getTree,'CallbackProperties');
% some layout
drawnow;
set(tree,'Units','normalized','position',[0 0 0.6 1]);
set(tree,'NodeSelectedCallback',@selected_cb);

    %--------------------------------------------------------------------------
    function path = selected_cb(tree,~)
        nodes = tree.getSelectedNodes;
        node = nodes(1);
        path = node2path(node);
    end  %end of selected_cb
    %-------------------------------------------------------------------------- 

    %--------------------------------------------------------------------------
    function path = node2path(node)
        path = node.getPath;

        for i=1:length(path);
            p{i} = char(path(i).getName);
        end

        if length(p) > 1
            path = fullfile(p{:});
        else
            path = p{1};
        end
    end  %end of node2path
    %-------------------------------------------------------------------------- 
 
% make root the initially selected node
tree.setSelectedNode(h.node.root);
tree.expand(h.node.root);
for mCount = 1:numel(h.module_names)
   tree.expand(h.node.(h.module_names{mCount}).root); 
end

% MousePressedCallback is not supported by the uitree, but by jtree
set(jtree,'MousePressedCallback',@mousePressedCallback);

    %--------------------------------------------------------------------------
    % Set the mouse-press callback
    function mousePressedCallback(~,eventData) %,additionalVar)
        % if eventData.isMetaDown % right-click is like a Meta-button
        % if eventData.getClickCount==2 % how to detect double clicks

        % Get the clicked node
        clickX = eventData.getX;
        clickY = eventData.getY;
        treePath = jtree.getPathForLocation(clickX, clickY);
        % check if a node was clicked
        if ~isempty(treePath)
            % check if the checkbox was clicked
            if clickX <= (jtree.getPathBounds(treePath).x+iconWidth)
            node = treePath.getLastPathComponent;
            nodeValue = node.getValue;
            % as the value field is the selected/unselected flag,
            % we can also use it to only act on nodes with these values
                switch nodeValue
                    case 'selected'
                        node.setValue('unselected');
                        node.setIcon(h.javaImage_unchecked);
                        jtree.treeDidChange();
                    case 'unselected'
                        node.setValue('selected');
                        node.setIcon(h.javaImage_checked);
                        jtree.treeDidChange();
                end
            end
        end
    end  %end of mousePressedCallback
    %-------------------------------------------------------------------------- 

push_loadprofile = uicontrol('string','Load Parameter Profile',...
                             'fontsize',10,...
                             'units','normalized',...
                             'position',[0.62 0.89 0.36 0.10],...
                             'callback',@push_loadprofile_Callback);

    %--------------------------------------------------------------------------
    function push_loadprofile_Callback(~,~)
        
        for mCount = 1:numel(h.module_names)
            resetProfile(h,h.module_names{mCount}) 
        end

        [filename,pathname] = uigetfile('*.trex','Select parameter profile',h.parameter_path);
        [h.profile] = readcsvX(fullfile(pathname,filename));
       
        for mCount = 1:numel(h.module_names)
            loadProfile(h,h.module_names{mCount}) 
        end


        tree.collapse(h.node.root);
        for mCount = 1:numel(h.module_names)
            tree.collapse(h.node.(h.module_names{mCount}).root);
        end
        
        tree.setSelectedNode(h.node.root);
        
        tree.expand(h.node.root);
        for mCount = 1:numel(h.module_names)
            tree.expand(h.node.(h.module_names{mCount}).root);
        end

    end  %end of push_loadprofile_Callback
    %-------------------------------------------------------------------------- 
    
push_saveprofile = uicontrol('string','Save Parameter Profile',...
                             'fontsize',10,...
                             'units','normalized',...
                             'position',[0.62 0.78 0.36 0.10],...
                             'callback',@push_saveprofile_Callback);

    %--------------------------------------------------------------------------
    function push_saveprofile_Callback(~,~)

        out = [];
        out.module_names = h.module_names;
        for mCount = 1:numel(h.module_names) 
            out = readTreeValues(h,out,h.module_names{mCount});
        end
        
        profile = profilewrite_mapX(out);

        prompt = {'Enter profile name:'};
        dlg_title = 'Save Profile';
        filename = inputdlg(prompt,dlg_title);
        filename = ['parameters_',filename{1},'.trex'];

        dlmcellX(fullfile(h.parameter_path,filename),profile)
    end  %end of push_saveprofile_Callback
    %-------------------------------------------------------------------------- 
    
push_apply = uicontrol('string','Apply Parameters',...
                       'fontsize',10,...
                       'units','normalized',...
                       'position',[0.62 0.67 0.36 0.10],...
                       'callback',@push_apply_Callback);

	%--------------------------------------------------------------------------
    function push_apply_Callback(~,~)

        h.apply = true;
        uiresume(f);
        
    end  %end of push_apply_Callback
    %-------------------------------------------------------------------------- 
    
push_cancel = uicontrol('string','Cancel',...
                        'fontsize',10,...
                        'units','normalized',...
                        'position',[0.62 0.56 0.36 0.10],...
                        'callback',@push_cancel_Callback);
                    
    %--------------------------------------------------------------------------
    function push_cancel_Callback(~,~)

        h.apply = false;
        uiresume(f);

    end  %end of push_cancel_Callback
    %-------------------------------------------------------------------------- 
    
uiwait(f);

parameters = [];

if h.apply == 1
    for mCount = 1:numel(h.module_names) 
        parameters = readTreeValues(h,parameters,h.module_names{mCount});
    end
else
    msgbox('Selected Parameters Not Applied!','Map Parameters')
end

delete(f)

%%
clearvars -except parameters

end %end of parameters_mapX
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function [I,map] = checkedIcon()
%% Checked icon
    I = uint8(...
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0;
        2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,1;
        2,2,2,2,2,2,2,2,2,2,2,2,0,2,3,1;
        2,2,1,1,1,1,1,1,1,1,1,0,2,2,3,1;
        2,2,1,1,1,1,1,1,1,1,0,1,2,2,3,1;
        2,2,1,1,1,1,1,1,1,0,1,1,2,2,3,1;
        2,2,1,1,1,1,1,1,0,0,1,1,2,2,3,1;
        2,2,1,0,0,1,1,0,0,1,1,1,2,2,3,1;
        2,2,1,1,0,0,0,0,1,1,1,1,2,2,3,1;
        2,2,1,1,0,0,0,0,1,1,1,1,2,2,3,1;
        2,2,1,1,1,0,0,1,1,1,1,1,2,2,3,1;
        2,2,1,1,1,0,1,1,1,1,1,1,2,2,3,1;
        2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
        1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1]);

    map = ...
        [0.023529,0.4902,0;
        1,1,1;
        0,0,0;
        0.50196,0.50196,0.50196;
        0.50196,0.50196,0.50196;
        0,0,0;
        0,0,0;
        0,0,0];

end %end of checkedIcon

%--------------------------------------------------------------------------
function [I,map] = uncheckedIcon()
%% Unchecked icon
    I = uint8(...
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1;
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
        2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
        2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
        2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
        2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
        2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
        2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
        2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
        2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
        2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
        2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
        1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1]);
    map = ...
        [0.023529,0.4902,0;
        1,1,1;
        0,0,0;
        0.50196,0.50196,0.50196;
        0.50196,0.50196,0.50196;
        0,0,0;
        0,0,0;
        0,0,0];
    
end %end of uncheckedIcon

%--------------------------------------------------------------------------
function [h] = createNodes(h,module)
%% Create tree nodes for the given module
    switch module
        case 'hist'
            str = 'First Order/Histogram Statistics';
        case 'shape'
            str = 'Shape/Minkowski Features';
        case 'glcm'
            str = 'Gray Level Co-occurrence';
        case 'glrlm'
            str = 'Gray Level Run Length';
        case 'ngtdm'
            str = 'Neighborhood Gray Tone Difference';
        case 'laws2D'
            str = 'Laws Filter Features (2D)';
        case 'lung'
            str = 'Lung CT Specific Features';
        case 'fractal'
            str = 'Fractal Features';
        otherwise
            error('here')
    end

    h.node.(module).root = uitreenode('v0','unselected', str, [], 0);
    h.node.(module).root.setIcon(h.javaImage_unchecked);
    h.node.root.add(h.node.(module).root);
    
    for pCount = 1:numel(h.param_fields)
        p_field = h.param_fields{pCount};
        
        switch p_field
            case 'block_size'
                p_str = 'Block Size (Pixels)';
            case 'overlap'
                p_str = 'Overlap (Pixels)';
            case 'shift'
                p_str = 'Shift (Pixels)';
            case 'preprocess'
                p_str = 'Preprocess';
            case 'bd'
                p_str = 'Bit Depth';
            case 'gl'
                p_str = 'Gray Limits';
            case 'offset'
                p_str = 'Offset';
            case 'dim'
                p_str = 'Dimension';
            case 'dist'
                p_str = 'Distance (Pixels)';
            case 'toggle'
                p_str = 'na';
            otherwise
                error('here')
        end
    
        if strcmpi(p_field,'toggle')
            %Nothing

        elseif isfield(h.(module),p_field) && strcmpi(p_field,'preprocess')
            h.node.(module).([p_field,'root']) = uitreenode('v0','dummy',p_str,[],0);
            h.node.(module).root.add(h.node.(module).([p_field,'root']));
            h.node.(module).(p_field) = cell(size(h.(p_field)));
            for k = 1:numel(h.(p_field))
                h.node.(module).(p_field){k} = uitreenode('v0','unselected',h.([p_field,'_strings']){k},[],0);
                h.node.(module).(p_field){k}.setIcon(h.javaImage_unchecked);
                h.node.(module).([p_field,'root']).add(h.node.(module).(p_field){k});
            end    

        elseif isfield(h.(module),p_field)
            h.node.(module).([p_field,'root']) = uitreenode('v0','dummy',p_str,[],0);
            h.node.(module).root.add(h.node.(module).([p_field,'root']));
            h.node.(module).(p_field) = cell(size(h.(p_field)));
            for k = 1:numel(h.(p_field))
                h.node.(module).(p_field){k} = uitreenode('v0','unselected',h.(p_field){k},[],0);
                h.node.(module).(p_field){k}.setIcon(h.javaImage_unchecked);
                h.node.(module).([p_field,'root']).add(h.node.(module).(p_field){k});
            end
        end
    end
end %end of createNodes

%--------------------------------------------------------------------------
function resetProfile(h,module)
%% Reset all checkboxes for the given module
    for pCount = 1:numel(h.param_fields)
        p_field = h.param_fields{pCount};
        
        if strcmpi(p_field,'toggle')
            node = h.node.(module).root;
            node.setValue('unselected');
            node.setIcon(h.javaImage_unchecked);
            
        elseif isfield(h.node.(module),p_field)
            for k = 1:numel(h.node.(module).(p_field))
                node = h.node.(module).(p_field){k};
                node.setValue('unselected');
                node.setIcon(h.javaImage_unchecked);
            end
        end
    end
end %end resetProfile

%--------------------------------------------------------------------------
function loadProfile(h,module)
%% Check the boxes based on h.profile  for the given module  
    for pCount = 1:numel(h.param_fields)
        p_field = h.param_fields{pCount};
        
        if strcmpi(p_field,'toggle')
            load_param = h.profile(strcmpi(h.profile(:,1),module) & strcmpi(h.profile(:,2),'toggle'),3);
            
            if strcmpi(load_param,'on')
                node = h.node.(module).root;
                node.setValue('selected');
                node.setIcon(h.javaImage_checked);
            end
        elseif isfield(h.node.(module),p_field)
            load_param = h.profile(strcmpi(h.profile(:,1),module) & strcmpi(h.profile(:,2),p_field),3);
            
            [~,nodeIndex] = intersect(h.(p_field),load_param);
            
            for k = 1:numel(nodeIndex)
                node = h.node.(module).(p_field){nodeIndex(k)};
                node.setValue('selected');
                node.setIcon(h.javaImage_checked);
            end
        end
    end 
end %end of loadProfile

%--------------------------------------------------------------------------
function [out] = readTreeValues(h,out,module)
%% Read the checkboxes from the tree for the given module
    for pCount = 1:numel(h.param_fields)
        p_field = h.param_fields{pCount};

        if strcmpi(p_field,'toggle')
            node = h.node.(module).root;

            if strcmpi(node.getValue,'selected')
                out.(module).toggle = 'on';
            else
                out.(module).toggle = 'off';
            end

        elseif isfield(h.(module),p_field)
            read_param = false(size(h.node.(module).(p_field)));

            for k = 1:numel(read_param)
                node = h.node.(module).(p_field){k};

                if strcmpi(node.getValue,'selected')
                    read_param(k) = true;
                end
            end
            out.(module).(p_field) = h.(p_field)(read_param,:);
        end   
    end
end %end of readTreeValues
