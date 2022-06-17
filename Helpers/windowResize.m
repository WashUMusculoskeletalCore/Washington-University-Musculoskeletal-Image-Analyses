function [handles, hObject] = windowResize(handles, hObject)

    handles.windowWidth = max(max(max(handles.img))) - min(min(min(handles.img)));
    set(handles.editWindowWidth,'String',num2str(handles.windowWidth));
    
    handles.windowLocation = round(handles.windowWidth / 2);
    set(handles.editWindowLocation,'String',num2str(handles.windowLocation));
   
    handles.upperThreshold = max(max(max(handles.img)));
    set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
    
    handles.theMax = double(max(max(max(handles.img))));
    handles.SliderThreshold = resizeSlider(handles.sliderThreshold, 1, handles.theMax, 1, handles.theMax/1000); 
    handles.SliderWindowWidth = resizeSlider(handles.sliderWindowWidth, 1, handles.theMax, 1, handles.theMax/1000); 
    handles.SliderWindowLocation = resizeSlider(handles.sliderWindowLocation, 1, handles.theMax, 1, handles.theMax/1000);
    
    guidata(hObject, handles);
end