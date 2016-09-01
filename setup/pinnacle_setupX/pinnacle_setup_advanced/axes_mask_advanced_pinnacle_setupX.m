function axes_mask_advanced_pinnacle_setupX(h)
%%
cla(h.axes_mask)
set(h.axes_mask,'Visible','on')
set(h.axes_mask,'Color',[0,0,0])
set(h.axes_mask,'XTick',[])
set(h.axes_mask,'YTick',[])

img = sc(h.input.img.array(:,:,h.input.main_z),h.input.range);
roi = sc(h.mask(:,:,h.input.main_z),[0 1]);

display = img.*roi;

if numel(display) == sum(display(:))
    display = sc(zeros(size(h.input.img.array(:,:,h.input.main_z))),[0,1]);
end

h.main_scan = imshow(display,'DisplayRange',h.input.range,...
                             'Parent',h.axes_mask);

axis(h.axes_mask,'square')

%%
clear
