function axes_minor1_viewerX(h)
%%
cla(h.axes_minor1)
%%
if strcmpi(h.view_minor1,'a')
    img = sc(ones(size(h.img.array(:,:,h.minor1_z))),[0,1]);
    roi = sc(ones(size(h.img.array(:,:,h.minor1_z))),[0,1]);
    
    if h.imgtoggle
        img = sc(h.img.array(:,:,h.minor1_z),h.range);
    end
    
    if h.roitoggle
        roi = sc(h.roi.mask(:,:,h.minor1_z),[0 1]);
    end
        
    display = img.*roi;
    
    if h.textoggle
        tex = sc(h.tex.norm(:,:,h.minor1_z),[0,max(h.tex.norm(:))],'jet',[0 0 0]);
        
        ind = h.tex.norm(:,:,h.minor1_z) > 0;
        ind = repmat(ind,[1,1,3]);

        display(ind) = display(ind).*tex(ind);
    end
    
    if h.dosetoggle
        dose = sc(h.dose.array(:,:,h.minor1_z),[1,max(h.dose.array(:))],'jet',[0 0 0]);
        
        ind = h.dose.array(:,:,h.minor1_z) > 100;
        ind = repmat(ind,[1,1,3]);

        display(ind) = display(ind).*dose(ind);
    end
    
    h.minor1_scan = imshow(display,'DisplayRange',h.range,...
                                 'Parent',h.axes_minor1);

    axis(h.axes_minor1,'square')

    set(h.minor1_scan,'ButtonDownFcn',{@minor1_ax_ButtonDownFcn,h});
        
    if h.roitoggle_curve
        hold(h.axes_minor1,'on')

        B = bwboundaries(h.roi.mask(:,:,h.minor1_z));
    
        for i = 1:numel(B)
           plot(h.axes_minor1,B{i}(:,2),B{i}(:,1),'-r','LineWidth',2) 
        end

        hold(h.axes_minor1,'off')
    end
    
    text(0.04,0.04,...
        ['Slice ',num2str(h.minor1_z),': Z = ',num2str(round(h.img.array_zV(h.minor1_z)*1000)/1000)],...
        'Units','normalized',...
        'Parent',h.axes_minor1,...
        'FontUnits','pixels',...
        'FontSize',12,...
        'Color',[0.95 0 0],...
        'Visible','on');
end
%%
if strcmpi(h.view_minor1,'s')
    img = sc(ones(size(squeeze(h.img.array(:,h.minor1_x,:))))',[0,1]);
    roi = sc(ones(size(squeeze(h.img.array(:,h.minor1_x,:))))',[0,1]);
    
    if h.imgtoggle
        img = sc(squeeze(h.img.array(:,h.minor1_x,:))',h.range);
    end

    if h.roitoggle
        roi = sc(squeeze(h.roi.mask(:,h.minor1_x,:))',[0 1]);
    end
        
    display = img.*roi;
    
    if h.textoggle
        tex = sc(squeeze(h.tex.norm(:,h.minor1_x,:))',[0,max(h.tex.norm(:))],'jet',[0 0 0]);
        
        ind = squeeze(h.tex.norm(:,h.minor1_x,:) > 0)';
        ind = repmat(ind,[1,1,3]);

        display(ind) = display(ind).*tex(ind);
    end
    
    if h.dosetoggle
        dose = sc(squeeze(h.dose.array(:,h.minor1_x,:))',[1,max(h.dose.array(:))],'jet',[0 0 0]);
        
        ind = squeeze(h.dose.array(:,h.minor1_x,:) > 100)';
        ind = repmat(ind,[1,1,3]);

        display(ind) = display(ind).*dose(ind);
    end
    
    h.minor1_scan = imshow(display,'DisplayRange',h.range,...
                         'Parent',h.axes_minor1);

    axis(h.axes_minor1,'square')

    set(h.minor1_scan,'ButtonDownFcn',{@minor1_sag_ButtonDownFcn,h});

    if h.roitoggle_curve
        hold(h.axes_minor1,'on')
        
        B = bwboundaries(squeeze(h.roi.mask(:,h.minor1_x,:)));
        
        for i = 1:numel(B)
           plot(h.axes_minor1,B{i}(:,1),B{i}(:,2),'-r','LineWidth',2) 
        end
        
        hold(h.axes_minor1,'off')
    end
        
    text(0.04,0.04,...
        ['Slice ',num2str(h.minor1_x),': X = ',num2str(round(h.img.array_xV(h.minor1_x)*1000)/1000)],...
        'Units','normalized',...
        'Parent',h.axes_minor1,...
        'FontUnits','pixels',...
        'FontSize',12,...
        'Color',[0.95 0 0],...
        'Visible','on');
end  
%%
if strcmpi(h.view_minor1,'c')    
    img = sc(ones(size(squeeze(h.img.array(h.minor1_y,:,:))))',[0,1]);
    roi = sc(ones(size(squeeze(h.img.array(h.minor1_y,:,:))))',[0,1]);
    
    if h.imgtoggle
        img = sc(squeeze(h.img.array(h.minor1_y,:,:))',h.range);
    end

    if h.roitoggle
        roi = sc(squeeze(h.roi.mask(h.minor1_y,:,:))',[0 1]);
    end
        
    display = img.*roi;
    
    if h.textoggle
        tex = sc(squeeze(h.tex.norm(h.minor1_y,:,:))',[0,max(h.tex.norm(:))],'jet',[0 0 0]);        
        
        ind = squeeze(h.tex.norm(h.minor1_y,:,:) > 0)';
        ind = repmat(ind,[1,1,3]);

        display(ind) = display(ind).*tex(ind);
    end
    
    if h.dosetoggle
        dose = sc(squeeze(h.dose.array(h.minor1_y,:,:))',[1,max(h.dose.array(:))],'jet',[0 0 0]);        
        
        ind = squeeze(h.dose.array(h.minor1_y,:,:) > 100)';
        ind = repmat(ind,[1,1,3]);

        display(ind) = display(ind).*dose(ind);
    end
    
    h.minor1_scan = imshow(display,'DisplayRange',h.range,...
                         'Parent',h.axes_minor1);

    axis(h.axes_minor1,'square')

    set(h.minor1_scan,'ButtonDownFcn',{@minor1_cor_ButtonDownFcn,h});
    
    if h.roitoggle_curve
        hold(h.axes_minor1,'on')
        
        B = bwboundaries(squeeze(h.roi.mask(h.minor1_y,:,:)));
        
        for i = 1:numel(B)
           plot(h.axes_minor1,B{i}(:,1),B{i}(:,2),'-r','LineWidth',2) 
        end

        hold(h.axes_minor1,'off')
    end
    
    text(0.04,0.04,...
        ['Slice ',num2str(h.minor1_y),': Y = ',num2str(round(h.img.array_yV(h.minor1_y)*1000)/1000)],...
        'Units','normalized',...
        'Parent',h.axes_minor1,...
        'FontUnits','pixels',...
        'FontSize',12,...
        'Color',[0.95 0 0],...
        'Visible','on');
end

%%
clear

%--------------------------------------------------------------------------
function minor1_ax_ButtonDownFcn(hObject,eventdata,h)
%%
text_push1 = [];
text_push2 = [];
text_push3 = [];

pt = get(h.axes_minor1,'currentpoint');
x = pt(1,1);
y = pt(1,2);

indx = round(x);
x = round(h.img.array_xV(indx)*10)/10;

indy = round(y);
y = round(h.img.array_yV(indy)*10)/10;

indz = h.minor1_z;
z = round(h.img.array_zV(indz)*10)/10;

xyz = ['(',num2str(x),',',num2str(y),',',num2str(z),')'];
ijk = ['(',num2str(indx),',',num2str(indy),',',num2str(indz),')'];

str1 = {['Current Point: ',xyz,'/',ijk]};
str2 = [];
str3 = [];
   
if h.imgtoggle
    if isempty(str2)
        str2 = ['Scan #: ', num2str(h.img.array(indy,indx,indz))];
    else
        str3 = ['Scan #: ', num2str(h.img.array(indy,indx,indz))];
    end
end

if h.textoggle
    if isempty(str2)
        str2 = ['Map Value: ',num2str(round(h.tex.array(indy,indx,indz),3))];
    else
        str3 = ['Map Value: ',num2str(round(h.tex.array(indy,indx,indz),3))];
    end
end

if h.dosetoggle
    if isempty(str2)
        str2 = ['Dose: ',num2str(round(h.dose.array(indy,indx,indz))),' cGy'];
    else
        str3 = ['Dose: ',num2str(round(h.dose.array(indy,indx,indz))),' cGy'];
    end
end

text_push1 = text(0.04,0.96,str1,'Units','normalized',...
            'Parent',h.axes_minor1,...
            'FontUnits','pixels',...
            'FontSize',12,...
            'Color',[0.95 0 0],...
            'Visible','on');     
        
if ~isempty(str2)
    text_push2 = text(0.04,0.92,str2,'Units','normalized',...
                'Parent',h.axes_minor1,...
                'FontUnits','pixels',...
                'FontSize',12,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

if ~isempty(str3)
    text_push3 = text(0.04,0.88,str3,'Units','normalized',...
                'Parent',h.axes_minor1,...
                'FontUnits','pixels',...
                'FontSize',12,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

setappdata(h.axes_minor1,'push1',text_push1)
setappdata(h.axes_minor1,'push2',text_push2)
setappdata(h.axes_minor1,'push3',text_push3)

%%
clear

%--------------------------------------------------------------------------
function minor1_sag_ButtonDownFcn(hObject,eventdata,h)
%%
text_push1 = [];
text_push2 = [];
text_push3 = [];

pt = get(h.axes_minor1,'currentpoint');
y = pt(1,1);
z = pt(1,2);

indx = h.minor1_x;
x = round(h.img.array_xV(indx)*10)/10;

indy = round(y);
y = round(h.img.array_yV(indy)*10)/10;

indz = round(z);
z = round(h.img.array_zV(indz)*10)/10;

xyz = ['(',num2str(x),',',num2str(y),',',num2str(z),')'];
ijk = ['(',num2str(indx),',',num2str(indy),',',num2str(indz),')'];

str1 = {['Current Point: ',xyz,'/',ijk]};
str2 = [];
str3 = [];
   
if h.imgtoggle
    if isempty(str2)
        str2 = ['Scan #: ', num2str(h.img.array(indy,indx,indz))];
    else
        str3 = ['Scan #: ', num2str(h.img.array(indy,indx,indz))];
    end
end

if h.textoggle
    if isempty(str2)
        str2 = ['Map Value: ',num2str(round(h.tex.array(indy,indx,indz),3))];
    else
        str3 = ['Map Value: ',num2str(round(h.tex.array(indy,indx,indz),3))];
    end
end

if h.dosetoggle
    if isempty(str2)
        str2 = ['Dose: ',num2str(round(h.dose.array(indy,indx,indz))),' cGy'];
    else
        str3 = ['Dose: ',num2str(round(h.dose.array(indy,indx,indz))),' cGy'];
    end
end
   


text_push1 = text(0.04,0.96,str1,'Units','normalized',...
            'Parent',h.axes_minor1,...
            'FontUnits','pixels',...
            'FontSize',12,...
            'Color',[0.95 0 0],...
            'Visible','on');     
        
if ~isempty(str2)
    text_push2 = text(0.04,0.92,str2,'Units','normalized',...
                'Parent',h.axes_minor1,...
                'FontUnits','pixels',...
                'FontSize',12,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

if ~isempty(str3)
    text_push3 = text(0.04,0.88,str3,'Units','normalized',...
                'Parent',h.axes_minor1,...
                'FontUnits','pixels',...
                'FontSize',12,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

setappdata(h.axes_minor1,'push1',text_push1)
setappdata(h.axes_minor1,'push2',text_push2)
setappdata(h.axes_minor1,'push3',text_push3)

%%
clear

%--------------------------------------------------------------------------
function minor1_cor_ButtonDownFcn(hObject,eventdata,h)
%%
text_push1 = [];
text_push2 = [];
text_push3 = [];

pt = get(h.axes_minor1,'currentpoint');
x = pt(1,1);
z = pt(1,2);

indx = round(x);
x = round(h.img.array_xV(indx)*10)/10;

indy = h.minor1_y;
y = round(h.img.array_yV(indy)*10)/10;

indz = round(z);
z = round(h.img.array_zV(indz)*10)/10;

xyz = ['(',num2str(x),',',num2str(y),',',num2str(z),')'];
ijk = ['(',num2str(indx),',',num2str(indy),',',num2str(indz),')'];

str1 = {['Current Point: ',xyz,'/',ijk]};
str2 = [];
str3 = [];
   
if h.imgtoggle
    if isempty(str2)
        str2 = ['Scan #: ', num2str(h.img.array(indy,indx,indz))];
    else
        str3 = ['Scan #: ', num2str(h.img.array(indy,indx,indz))];
    end
end

if h.textoggle
    if isempty(str2)
        str2 = ['Map Value: ',num2str(round(h.tex.array(indy,indx,indz),3))];
    else
        str3 = ['Map Value: ',num2str(round(h.tex.array(indy,indx,indz),3))];
    end
end

if h.dosetoggle
    if isempty(str2)
        str2 = ['Dose: ',num2str(round(h.dose.array(indy,indx,indz))),' cGy'];
    else
        str3 = ['Dose: ',num2str(round(h.dose.array(indy,indx,indz))),' cGy'];
    end
end

text_push1 = text(0.04,0.96,str1,'Units','normalized',...
            'Parent',h.axes_minor1,...
            'FontUnits','pixels',...
            'FontSize',12,...
            'Color',[0.95 0 0],...
            'Visible','on');     
        
if ~isempty(str2)
    text_push2 = text(0.04,0.92,str2,'Units','normalized',...
                'Parent',h.axes_minor1,...
                'FontUnits','pixels',...
                'FontSize',12,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

if ~isempty(str3)
    text_push3 = text(0.04,0.88,str3,'Units','normalized',...
                'Parent',h.axes_minor1,...
                'FontUnits','pixels',...
                'FontSize',12,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

setappdata(h.axes_minor1,'push1',text_push1)
setappdata(h.axes_minor1,'push2',text_push2)
setappdata(h.axes_minor1,'push3',text_push3)

%%
clear
