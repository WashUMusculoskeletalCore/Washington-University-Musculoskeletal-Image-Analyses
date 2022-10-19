% NAME-windowResize
% DESC-Resizes the brightness window sliders and performs other adjustments. 
% Call this whenever the brightness range of the image changes
% IN-handles.img: the 3D image
% OUT-handles.windowWidth: the width of the brightness window
% handles.windowLocation: the center of the brightness window
% handles.editWindowWidth: the window width text box
% handles.editWindowLocation: the window location text box
% handles.dataMax: the maximum brightness of the image
% handles.dataMin: the minimum brightness of the image
% handles.SliderThreshold: the threshold sliders
function [handles] = windowResize(handles)
    % Resize all window sliders. This will reset their values to 1, 
    handles.dataMax = double(max(handles.img, [], "all"));
    handles.dataMin = double(min(handles.img, [], "all"));
    handles.SliderThreshold = resizeSlider(handles.sliderThreshold, handles.dataMin, handles.dataMax, 1, (handles.dataMax-handles.dataMin)/1000); 
    handles.SliderWindowWidth = resizeSlider(handles.sliderWindowWidth, 1, handles.dataMax-handles.dataMin, 1, (handles.dataMax-handles.dataMin)/1000); 
    handles.SliderWindowLocation = resizeSlider(handles.sliderWindowLocation, handles.dataMin, handles.dataMax, 1, (handles.dataMax-handles.dataMin)/1000);
    % Set width to the maximum value in the image.
    handles.windowWidth = handles.dataMax-handles.dataMin;
    set(handles.editWindowWidth,'String',num2str(handles.windowWidth));
    set(handles.sliderWindowWidth,'Value',handles.windowWidth);
    % Set the location to the center of the width
    handles.windowLocation = round((handles.dataMax+handles.dataMin) / 2);
    set(handles.editWindowLocation,'String',num2str(handles.windowLocation));
    set(handles.sliderWindowLocation,'Value',handles.windowLocation);
   % Set the thresholds
    handles.upperThreshold = int16(handles.dataMax);
    set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
    
    handles.lowerThreshold = int16(handles.dataMin);
    set(handles.textLowerThreshold,'String',num2str(handles.lowerThreshold));

    handles.threshold = round(get(handles.sliderThreshold,'Value'));
    set(handles.editThreshold,'String',num2str(handles.threshold))
end