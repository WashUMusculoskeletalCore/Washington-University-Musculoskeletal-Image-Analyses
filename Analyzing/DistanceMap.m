function [hObject,eventdata,handles] = DistanceMap(hObject,eventdata,handles)


try
    setStatus(hObject, handles, 'Busy');
    
    handles.bwDist = bwdist(handles.bwContour);
    handles.imgOrig = handles.img;
    handles.img = uint16(handles.bwDist);
    UpdateImage(hObject,eventdata,handles);
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end
