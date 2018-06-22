function [hObject,eventdata,handles] = RevertImage(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    handles.img = handles.imgOrig;
    
    handles.windowWidth = max(max(max(handles.img))) - min(min(min(handles.img)));
    set(handles.editWindowWidth,'String',num2str(handles.windowWidth));
    
    handles.abc = size(handles.img);
    
    handles.windowLocation = round(handles.windowWidth / 2);
    set(handles.editWindowLocation,'String',num2str(handles.windowLocation));
    
    handles.primitiveCenter(1) = round(handles.abc(2)/2);
    handles.primitiveCenter(2) = round(handles.abc(1)/2);
    answer = inputdlg('Would you like to reset the contour? If you changed the image size, you must. y or n');
    if strcmpi(answer{1},'y') == 1
        if isfield(handles,'bwContour') == 1
            handles.bwContour = [];
            handles = rmfield(handles,'bwContour');
        end
    end
    % handles.bwContour = false(size(handles.img));
    % handles.bwContourOrig = handles.bwContour;
    
    handles.upperThreshold = max(max(max(handles.img)));
    set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
    
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    handles.theMax = double(max(max(max(handles.img))));
    set(handles.sliderThreshold,'Value',1);
    set(handles.sliderThreshold,'min',1);
    set(handles.sliderThreshold,'max',handles.theMax);
    set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowWidth,'Value',1);
    set(handles.sliderWindowWidth,'min',1);
    set(handles.sliderWindowWidth,'max',handles.theMax);
    set(handles.sliderWindowWidth,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowLocation,'Value',1);
    set(handles.sliderWindowLocation,'min',1);
    set(handles.sliderWindowLocation,'max',handles.theMax);
    set(handles.sliderWindowLocation,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end