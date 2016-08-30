function axes_main_setupX(h)
%%
h.roitoggle = false;
h.textoggle = false;

cla(h.axes_main)
set(h.axes_main,'Visible','on')
set(h.axes_main,'Color',[0,0,0])
set(h.axes_main,'XTick',[])
set(h.axes_main,'YTick',[])

if isempty(h.img) || ~isfield(h.img,'array')
    return
end
%%
if strcmpi(h.view_main,'a')
    img = sc(ones(size(h.img.array(:,:,h.main_z))),[0,1]);
    dose = sc(ones(size(h.img.array(:,:,h.main_z))),[0,1]);
    tex = sc(ones(size(h.img.array(:,:,h.main_z))),[0,1]);
    roi = sc(ones(size(h.img.array(:,:,h.main_z))),[0,1]);
    
    if h.imgtoggle
        img = sc(h.img.array(:,:,h.main_z),h.range);
    end

    if h.dosetoggle
        dose = sc(h.dose.array(:,:,h.main_z),[1,max(h.dose.array(:))],'jet',[0 0 0]);
    end
    
    if h.textoggle
        tex = sc(h.tex(:,:,h.main_z),[0,1],'jet',[0 0 0]);
    end
    
    if h.roitoggle
        roi = sc(h.roi.mask(:,:,h.main_z),[0 1]);
    end
        
    display = img.*dose.*tex.*roi;
    
    if numel(display) == sum(display(:))
        display = sc(zeros(size(h.img.array(:,:,h.main_z))),[0,1]);
    end

    h.main_scan = imshow(display,'DisplayRange',h.range,...
                                 'Parent',h.axes_main);

    axis(h.axes_main,'square')

    set(h.main_scan,'ButtonDownFcn',{@main_ax_ButtonDownFcn,h});
        
    if h.roitoggle_curve
        hold(h.axes_main,'on')

        z = round(h.roi.z);
        ind = find(z==h.main_z);
        scatter(h.axes_main,h.roi.x(ind),h.roi.y(ind),25,'r','.')

        hold(h.axes_main,'off')
    end
    
    text(0.02,0.02,...
        ['Slice ',num2str(h.main_z),': Z = ',num2str(round(h.img.array_zV(h.main_z)*1000)/1000)],...
        'Units','normalized',...
        'Parent',h.axes_main,...
        'FontUnits','pixels',...
        'FontSize',12,...
        'Color',[0.95 0 0],...
        'Visible','on');
end
%%
if strcmpi(h.view_main,'s')
    img = sc(ones(size(squeeze(h.img.array(:,h.main_x,:))))',[0,1]);
    dose = sc(ones(size(squeeze(h.img.array(:,h.main_x,:))))',[0,1]);
    tex = sc(ones(size(squeeze(h.img.array(:,h.main_x,:))))',[0,1]);
    roi = sc(ones(size(squeeze(h.img.array(:,h.main_x,:))))',[0,1]);
    
    if h.imgtoggle
        img = sc(squeeze(h.img.array(:,h.main_x,:))',h.range);
    end

    if h.dosetoggle
        dose = sc(squeeze(h.dose.array(:,h.main_x,:))',[1,max(h.dose.array(:))],'jet',[0 0 0]);
    end
    
    if h.textoggle
        tex = sc(squeeze(h.tex(:,h.main_x,:))',[0,1],'jet',[0 0 0]);
    end
    
    if h.roitoggle
        roi = sc(squeeze(h.roi.mask(:,h.main_x,:))',[0 1]);
    end
        
    display = img.*dose.*tex.*roi;

    if numel(display) == sum(display(:))
        display = sc(zeros(size(h.img.array(:,h.main_x,:))),[0,1]);
    end
    
    h.main_scan = imshow(display,'DisplayRange',h.range,...
                         'Parent',h.axes_main);

    axis(h.axes_main,'square')

    set(h.main_scan,'ButtonDownFcn',{@main_sag_ButtonDownFcn,h});
    
    if h.roitoggle_curve
        hold(h.axes_main,'on')

        x = round(h.roi.x);
        ind = find(x==h.main_x);
        scatter(h.axes_main,h.roi.y(ind),h.roi.z(ind),25,'r','.')

        hold(h.axes_main,'off')
    end

    text(0.02,0.02,...
        ['Slice ',num2str(h.main_x),': X = ',num2str(round(h.img.array_xV(h.main_x)*1000)/1000)],...
        'Units','normalized',...
        'Parent',h.axes_main,...
        'FontUnits','pixels',...
        'FontSize',12,...
        'Color',[0.95 0 0],...
        'Visible','on');
end  
%%
if strcmpi(h.view_main,'c')    
    img = sc(ones(size(squeeze(h.img.array(h.main_y,:,:))))',[0,1]);
    dose = sc(ones(size(squeeze(h.img.array(h.main_y,:,:))))',[0,1]);
    tex = sc(ones(size(squeeze(h.img.array(h.main_y,:,:))))',[0,1]);
    roi = sc(ones(size(squeeze(h.img.array(h.main_y,:,:))))',[0,1]);
    
    if h.imgtoggle
        img = sc(squeeze(h.img.array(h.main_y,:,:))',h.range);
    end

    if h.dosetoggle
        dose = sc(squeeze(h.dose.array(h.main_y,:,:))',[1,max(h.dose.array(:))],'jet',[0 0 0]);
    end
    
    if h.textoggle
        tex = sc(squeeze(h.tex(h.main_y,:,:))',[0,1],'jet',[0 0 0]);
    end
    
    if h.roitoggle
        roi = sc(squeeze(h.roi.mask(h.main_y,:,:))',[0 1]);
    end
        
    display = img.*dose.*tex.*roi;
    
    if numel(display) == sum(display(:))
        display = sc(zeros(size(h.img.array(h.main_y,:,:))),[0,1]);
    end

    h.main_scan = imshow(display,'DisplayRange',h.range,...
                         'Parent',h.axes_main);

    axis(h.axes_main,'square')

    set(h.main_scan,'ButtonDownFcn',{@main_cor_ButtonDownFcn,h});
    
    if h.roitoggle_curve
        hold(h.axes_main,'on')

        y = round(h.roi.y);
        ind = find(y==h.main_y);
        scatter(h.axes_main,h.roi.x(ind),h.roi.z(ind),25,'r','.')

        hold(h.axes_main,'off')
    end
    
    text(0.02,0.02,...
        ['Slice ',num2str(h.main_y),': Y = ',num2str(round(h.img.array_yV(h.main_y)*1000)/1000)],...
        'Units','normalized',...
        'Parent',h.axes_main,...
        'FontUnits','pixels',...
        'FontSize',12,...
        'Color',[0.95 0 0],...
        'Visible','on');
end

%%
clear

%--------------------------------------------------------------------------
function main_ax_ButtonDownFcn(hObject,eventdata,h)
%%
text_push1 = [];
text_push2 = [];
text_push3 = [];

pt = get(h.axes_main,'currentpoint');
x = pt(1,1);
y = pt(1,2);

indx = round(x);
x = round(h.img.array_xV(indx)*10)/10;

indy = round(y);
y = round(h.img.array_yV(indy)*10)/10;

indz = h.main_z;
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

text_push1 = text(0.02,0.975,str1,'Units','normalized',...
            'Parent',h.axes_main,...
            'FontUnits','pixels',...
            'FontSize',12,...
            'Color',[0.95 0 0],...
            'Visible','on');     
        
if ~isempty(str2)
    text_push2 = text(0.02,0.95,str2,'Units','normalized',...
                'Parent',h.axes_main,...
                'FontUnits','pixels',...
                'FontSize',12,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

if ~isempty(str3)
    text_push3 = text(0.02,0.925,str3,'Units','normalized',...
                'Parent',h.axes_main,...
                'FontUnits','pixels',...
                'FontSize',12,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

setappdata(h.axes_main,'push1',text_push1)
setappdata(h.axes_main,'push2',text_push2)
setappdata(h.axes_main,'push3',text_push3)

%%
clear

%--------------------------------------------------------------------------
function main_sag_ButtonDownFcn(hObject,eventdata,h)
%%
text_push1 = [];
text_push2 = [];
text_push3 = [];

pt = get(h.axes_main,'currentpoint');
y = pt(1,1);
z = pt(1,2);

indx = h.main_x;
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

text_push1 = text(0.02,0.975,str1,'Units','normalized',...
            'Parent',h.axes_main,...
            'FontUnits','pixels',...
            'FontSize',12,...
            'Color',[0.95 0 0],...
            'Visible','on');     
        
if ~isempty(str2)
    text_push2 = text(0.02,0.95,str2,'Units','normalized',...
                'Parent',h.axes_main,...
                'FontUnits','pixels',...
                'FontSize',12,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

if ~isempty(str3)
    text_push3 = text(0.02,0.925,str3,'Units','normalized',...
                'Parent',h.axes_main,...
                'FontUnits','pixels',...
                'FontSize',12,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

setappdata(h.axes_main,'push1',text_push1)
setappdata(h.axes_main,'push2',text_push2)
setappdata(h.axes_main,'push3',text_push3)

%%
clear

%--------------------------------------------------------------------------
function main_cor_ButtonDownFcn(hObject,eventdata,h)
%%
text_push1 = [];
text_push2 = [];
text_push3 = [];

pt = get(h.axes_main,'currentpoint');
x = pt(1,1);
z = pt(1,2);

indx = round(x);
x = round(h.img.array_xV(indx)*10)/10;

indy = h.main_y;
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

text_push1 = text(0.02,0.975,str1,'Units','normalized',...
            'Parent',h.axes_main,...
            'FontUnits','pixels',...
            'FontSize',12,...
            'Color',[0.95 0 0],...
            'Visible','on');     
        
if ~isempty(str2)
    text_push2 = text(0.02,0.95,str2,'Units','normalized',...
                'Parent',h.axes_main,...
                'FontUnits','pixels',...
                'FontSize',12,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

if ~isempty(str3)
    text_push3 = text(0.02,0.925,str3,'Units','normalized',...
                'Parent',h.axes_main,...
                'FontUnits','pixels',...
                'FontSize',12,...
                'Color',[0.95 0 0],...
                'Visible','on');
end

setappdata(h.axes_main,'push1',text_push1)
setappdata(h.axes_main,'push2',text_push2)
setappdata(h.axes_main,'push3',text_push3)

%%
clear
