function [hObject, eventdata, handles] = MorphRange(hObject, eventdata, handles)

try
    set(handles.textBusy,'String','Busy');
    bwTemp = interp_shape(handles.bwContour(:,:,handles.startMorph),handles.bwContour(:,:,handles.endMorph),abs(handles.startMorph - handles.endMorph)+1);
    bwTemp = flip(bwTemp,3);
    handles.bwContour(:,:,handles.startMorph:handles.endMorph) = bwTemp;
    guidata(hObject, handles);
    updateImage(hObject,eventdata,handles);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end

