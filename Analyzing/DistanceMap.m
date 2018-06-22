function [hObject,eventdata,handles] = DistanceMap(hObject,eventdata,handles)


try
    set(handles.textBusy,'String','Busy');
    drawnow();
    
    handles.bwDist = bwdist(handles.bwContour);
    handles.imgOrig = handles.img;
    handles.img = uint16(handles.bwDist);
    UpdateImage(hObject,eventdata,handles);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end
