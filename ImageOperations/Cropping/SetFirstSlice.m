% NAME-SetFirstSlice
% DESC-Crop all slices before the current slice
% IN-handles.slice: the slice to become the new first slice
% OUT-handles.img: the cropped image
% handles.bwCountour: the cropped mask
function [hObject, eventdata, handles] = SetFirstSlice(hObject, eventdata, handles)

    handles.img = handles.img(:,:,handles.slice:end);
    
    if isfield(handles,'bwContour')
        handles.bwContour = handles.bwContour(:,:,handles.slice:end);
    end
    
    abcResize(handles, hObject);
    windowResize(handles, hObject);
    
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);
end