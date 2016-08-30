function [h] = handlesoff_pinnacle_setupX(h,field)
%%
if strcmpi(field,'institution')
    set(h.drop_institution,'Enable','off')
    set(h.drop_institution,'String',{' '})
    set(h.drop_institution,'Value',1);
    
    set(h.push_institution,'Enable','off')
    
elseif strcmpi(field,'patient')
    h.filedata = [];
        
    set(h.drop_patient,'Enable','off')
    set(h.drop_patient,'String',{' '})
    set(h.drop_patient,'Value',1)
    
    set(h.push_patient,'Enable','off')
    
elseif strcmpi(field,'plan')
    set(h.drop_plan,'Enable','off')
    set(h.drop_plan,'String',{' '})
    set(h.drop_plan,'Value',1)
    
    set(h.push_plan,'Enable','off')
    
elseif strcmpi(field,'image')
    h.img = [];
    
    set(h.menu_displayscan,'Enable','off')
    
    set(h.slider_level,'Enable','off')
    set(h.text_window,'Enable','off')
    set(h.text_level,'Enable','off')
    set(h.edit_level,'Enable','off')
    set(h.edit_window,'Enable','off')
    set(h.text_preset,'Enable','off')
    set(h.drop_preset,'Enable','off')
    set(h.slider_window,'Enable','off')
    
    set(h.push_scaninfo,'Enable','off')
    set(h.menu_scaninfo,'Enable','off')
    
elseif strcmpi(field,'roi')
    h.roi = [];
    h.roi.curvedata = [];
    h.roitoggle_curve = 0;
    
    set(h.drop_roi,'Enable','off')
    set(h.drop_roi,'String',{' '})
    set(h.drop_roi,'Value',1)
    
    set(h.push_displaycurveroi,'Enable','off')
    set(h.push_displaycurveroi,'Value',0)
    set(h.menu_displaycurveroi,'Enable','off')
    set(h.menu_displaycurveroi,'Checked','off')
    
    set(h.menu_roiadvanced,'Enable','off')
    set(h.menu_roisubvolumes,'Enable','off')

elseif strcmpi(field,'dose')
    h.dose = [];
    h.dosetoggle = 0;
    
    set(h.drop_dose,'Enable','off')
    set(h.drop_dose,'String',{' '})
    set(h.drop_dose,'Value',1)
    
    set(h.push_doseinfo,'Enable','off')
    set(h.menu_doseinfo,'Enable','off')
    
    set(h.push_displaydose,'Enable','off')
    set(h.push_displaydose,'Value',0)
    set(h.menu_displaydose,'Enable','off')
    set(h.menu_displaydose,'Checked','off')
    
end

