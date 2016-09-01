function axes_minor2_setupX(h)
%%
h.roitoggle = false;
h.textoggle = false;

cla(h.axes_minor2)
set(h.axes_minor2,'Visible','on')
set(h.axes_minor2,'Color',[0,0,0])
set(h.axes_minor2,'XTick',[])
set(h.axes_minor2,'YTick',[])

if isempty(h.img) || ~isfield(h.img,'array')
    return
end
%%
if strcmpi(h.view_minor2,'a')
    img = sc(ones(size(h.img.array(:,:,h.minor2_z))),[0,1]);
    dose = sc(ones(size(h.img.array(:,:,h.minor2_z))),[0,1]);
    tex = sc(ones(size(h.img.array(:,:,h.minor2_z))),[0,1]);
    roi = sc(ones(size(h.img.array(:,:,h.minor2_z))),[0,1]);
    
    if h.imgtoggle
        img = sc(h.img.array(:,:,h.minor2_z),h.range);
    end

    if h.dosetoggle
        dose = sc(h.dose.array(:,:,h.minor2_z),[1,max(h.dose.array(:))],'jet',[0 0 0]);
    end
    
    if h.textoggle
        tex = sc(h.tex(:,:,h.minor2_z),[0,1],'jet',[0 0 0]);
    end
    
    if h.roitoggle
        roi = sc(h.roi.mask(:,:,h.minor2_z),[0 1]);
    end
        
    display = img.*dose.*tex.*roi;

    if numel(display) == sum(display(:))
        display = sc(zeros(size(h.img.array(:,:,h.minor2_z))),[0,1]);
    end
    
    h.minor2_scan = imshow(display,'DisplayRange',h.range,...
                                 'Parent',h.axes_minor2);

    axis(h.axes_minor2,'square')

    set(h.minor2_scan,'ButtonDownFcn',{@minor2_ax_ButtonDownFcn,h});
        
    if h.roitoggle_curve
        hold(h.axes_minor2,'on')

        z = round(h.roi.z);
        ind = find(z==h.minor2_z);
        scatter(h.axes_minor2,h.roi.x(ind),h.roi.y(ind),25,'r','.')

        hold(h.axes_minor2,'off')
    end
    
    text(0.04,0.04,...
        ['Slice ',num2str(h.minor2_z),': Z = ',num2str(round(h.img.array_zV(h.minor2_z)*1000)/1000)],...
        'Units','normalized',...
        'Parent',h.axes_minor2,...
        'FontUnits','pixels',...
        'FontSize',8,...
        'Color',[0.95 0 0],...
        'Visible','on');
end
%%
if strcmpi(h.view_minor2,'s')
    img = sc(ones(size(squeeze(h.img.array(:,h.minor2_x,:))))',[0,1]);
    dose = sc(ones(size(squeeze(h.img.array(:,h.minor2_x,:))))',[0,1]);
    tex = sc(ones(size(squeeze(h.img.array(:,h.minor2_x,:))))',[0,1]);
    roi = sc(ones(size(squeeze(h.img.array(:,h.minor2_x,:))))',[0,1]);
    
    if h.imgtoggle
        img = sc(squeeze(h.img.array(:,h.minor2_x,:))',h.range);
    end

    if h.dosetoggle
        dose = sc(squeeze(h.dose.array(:,h.minor2_x,:))',[1,max(h.dose.array(:))],'jet',[0 0 0]);
    end
    
    if h.textoggle
        tex = sc(squeeze(h.tex(:,h.minor2_x,:))',[0,1],'jet',[0 0 0]);
    end
    
    if h.roitoggle
        roi = sc(squeeze(h.roi.mask(:,h.minor2_x,:))',[0 1]);
    end
        
    display = img.*dose.*tex.*roi;

    if numel(display) == sum(display(:))
        display = sc(zeros(size(h.img.array(:,h.minor2_x,:))),[0,1]);
    end
    
    h.minor2_scan = imshow(display,'DisplayRange',h.range,...
                         'Parent',h.axes_minor2);

    axis(h.axes_minor2,'square')

    set(h.minor2_scan,'ButtonDownFcn',{@minor2_sag_ButtonDownFcn,h});

    if h.roitoggle_curve
        hold(h.axes_minor2,'on')

        x = round(h.roi.x);
        ind = find(x==h.minor2_x);
        scatter(h.axes_minor2,h.roi.y(ind),h.roi.z(ind),25,'r','.')

        hold(h.axes_minor2,'off')
    end
    
    text(0.04,0.04,...
        ['Slice ',num2str(h.minor2_x),': X = ',num2str(round(h.img.array_xV(h.minor2_x)*1000)/1000)],...
        'Units','normalized',...
        'Parent',h.axes_minor2,...
        'FontUnits','pixels',...
        'FontSize',8,...
        'Color',[0.95 0 0],...
        'Visible','on');
end  
%%
if strcmpi(h.view_minor2,'c')    
    img = sc(ones(size(squeeze(h.img.array(h.minor2_y,:,:))))',[0,1]);
    dose = sc(ones(size(squeeze(h.img.array(h.minor2_y,:,:))))',[0,1]);
    tex = sc(ones(size(squeeze(h.img.array(h.minor2_y,:,:))))',[0,1]);
    roi = sc(ones(size(squeeze(h.img.array(h.minor2_y,:,:))))',[0,1]);
    
    if h.imgtoggle
        img = sc(squeeze(h.img.array(h.minor2_y,:,:))',h.range);
    end

    if h.dosetoggle
        dose = sc(squeeze(h.dose.array(h.minor2_y,:,:))',[1,max(h.dose.array(:))],'jet',[0 0 0]);
    end
    
    if h.textoggle
        tex = sc(squeeze(h.tex(h.minor2_y,:,:))',[0,1],'jet',[0 0 0]);
    end
    
    if h.roitoggle
        roi = sc(squeeze(h.roi.mask(h.minor2_y,:,:))',[0 1]);
    end
        
    display = img.*dose.*tex.*roi;

    if numel(display) == sum(display(:))
        display = sc(zeros(size(h.img.array(h.minor2_y,:,:))),[0,1]);
    end
    
    h.minor2_scan = imshow(display,'DisplayRange',h.range,...
                         'Parent',h.axes_minor2);

    axis(h.axes_minor2,'square')

    set(h.minor2_scan,'ButtonDownFcn',{@minor2_cor_ButtonDownFcn,h});

    if h.roitoggle_curve
        hold(h.axes_minor2,'on')

        y = round(h.roi.y);
        ind = find(y==h.minor2_y);
        scatter(h.axes_minor2,h.roi.x(ind),h.roi.z(ind),25,'r','.')

        hold(h.axes_minor2,'off')
    end
    
    text(0.04,0.04,...
        ['Slice ',num2str(h.minor2_y),': Y = ',num2str(round(h.img.array_yV(h.minor2_y)*1000)/1000)],...
        'Units','normalized',...
        'Parent',h.axes_minor2,...
        'FontUnits','pixels',...
        'FontSize',8,...
        'Color',[0.95 0 0],...
        'Visible','on');
end

%%
clear

%--------------------------------------------------------------------------
function minor2_ax_ButtonDownFcn(hObject,eventdata,h)
%%
text_push1 = [];
text_push2 = [];
text_push3 = [];

pt = get(h.axes_minor2,'currentpoint');
x = pt(1,1);
y = pt(1,2);

indx = round(x);
x = round(h.img.array_xV(indx)*10)/10;

indy = round(y);
y = round(h.img.array_yV(indy)*10)/10;

indz = h.minor2_z;
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

if h.dosetoggle
    if isempty(str2)
        str2 = ['Dose: ',num2str(round(h.dose.array(indy,indx,indz))),' cGy'];
    else
        str3 = ['Dose: ',num2str(round(h.dose.array(indy,indx,indz))),' cGy'];
    end
end
   
if h.textoggle
    if isempty(str2)
        str2 = ['Map Value: ',num2str(round(h.tex(indy,indx,indz)))];
    else
        str3 = ['Map Value: ',num2str(round(h.tex(indy,indx,indz)))];
    end
end

text_push1 = text(0.04,0.96,str1,'Units','normalized',...
            'Parent',h.axes_minor2,...
            'FontUnits','pixels',...
            'FontSize',8,...
            'Color',[0.95 0 0],...
            'Visible','on');     
        
if ~isempty(str2)
    text_push2 = text(0.04,0.92,str2,'Units','normalized',...
                'Parent',h.axes_minor2,...
                'FontUnits','pixels',...
                'FontSize',8,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

if ~isempty(str3)
    text_push3 = text(0.04,0.88,str3,'Units','normalized',...
                'Parent',h.axes_minor2,...
                'FontUnits','pixels',...
                'FontSize',8,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

setappdata(h.axes_minor2,'push1',text_push1)
setappdata(h.axes_minor2,'push2',text_push2)
setappdata(h.axes_minor2,'push3',text_push3)

%%
clear

%--------------------------------------------------------------------------
function minor2_sag_ButtonDownFcn(hObject,eventdata,h)
%%
text_push1 = [];
text_push2 = [];
text_push3 = [];

pt = get(h.axes_minor2,'currentpoint');
y = pt(1,1);
z = pt(1,2);

indx = h.minor2_x;
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

if h.dosetoggle
    if isempty(str2)
        str2 = ['Dose: ',num2str(round(h.dose.array(indy,indx,indz))),' cGy'];
    else
        str3 = ['Dose: ',num2str(round(h.dose.array(indy,indx,indz))),' cGy'];
    end
end
   
if h.textoggle
    if isempty(str2)
        str2 = ['Map Value: ',num2str(round(h.tex(indy,indx,indz)))];
    else
        str3 = ['Map Value: ',num2str(round(h.tex(indy,indx,indz)))];
    end
end

text_push1 = text(0.04,0.96,str1,'Units','normalized',...
            'Parent',h.axes_minor2,...
            'FontUnits','pixels',...
            'FontSize',8,...
            'Color',[0.95 0 0],...
            'Visible','on');     
        
if ~isempty(str2)
    text_push2 = text(0.04,0.92,str2,'Units','normalized',...
                'Parent',h.axes_minor2,...
                'FontUnits','pixels',...
                'FontSize',8,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

if ~isempty(str3)
    text_push3 = text(0.04,0.88,str3,'Units','normalized',...
                'Parent',h.axes_minor2,...
                'FontUnits','pixels',...
                'FontSize',8,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

setappdata(h.axes_minor2,'push1',text_push1)
setappdata(h.axes_minor2,'push2',text_push2)
setappdata(h.axes_minor2,'push3',text_push3)

%%
clear

%--------------------------------------------------------------------------
function minor2_cor_ButtonDownFcn(hObject,eventdata,h)
%%
text_push1 = [];
text_push2 = [];
text_push3 = [];

pt = get(h.axes_minor2,'currentpoint');
x = pt(1,1);
z = pt(1,2);

indx = round(x);
x = round(h.img.array_xV(indx)*10)/10;

indy = h.minor2_y;
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

if h.dosetoggle
    if isempty(str2)
        str2 = ['Dose: ',num2str(round(h.dose.array(indy,indx,indz))),' cGy'];
    else
        str3 = ['Dose: ',num2str(round(h.dose.array(indy,indx,indz))),' cGy'];
    end
end
   
if h.textoggle
    if isempty(str2)
        str2 = ['Map Value: ',num2str(round(h.tex(indy,indx,indz)))];
    else
        str3 = ['Map Value: ',num2str(round(h.tex(indy,indx,indz)))];
    end
end

text_push1 = text(0.04,0.96,str1,'Units','normalized',...
            'Parent',h.axes_minor2,...
            'FontUnits','pixels',...
            'FontSize',8,...
            'Color',[0.95 0 0],...
            'Visible','on');     
        
if ~isempty(str2)
    text_push2 = text(0.04,0.92,str2,'Units','normalized',...
                'Parent',h.axes_minor2,...
                'FontUnits','pixels',...
                'FontSize',8,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

if ~isempty(str3)
    text_push3 = text(0.04,0.88,str3,'Units','normalized',...
                'Parent',h.axes_minor2,...
                'FontUnits','pixels',...
                'FontSize',8,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

setappdata(h.axes_minor2,'push1',text_push1)
setappdata(h.axes_minor2,'push2',text_push2)
setappdata(h.axes_minor2,'push3',text_push3)

%%
clear
