function [hObject, eventdata, handles] = AdjustCurrentSlice(hObject, eventdata, handles)

try
    set(handles.textBusy,'String','Busy');
    img = handles.img(:,:,handles.slice);
    bw = handles.bwContour(:,:,handles.slice);
    bw = activecontour(img,bw,...
        handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
    handles.bwContour(:,:,handles.slice) = bw;
    guidata(hObject, handles);
    UpdateImage(hObject,eventdata,handles);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end