% NAME-SetLastSlice
% DESC-Crop all slices after the current slice
% IN-handles.slice: the slice to become the new last slice
% OUT-handles.img: the cropped image
% handles.bwCountour: the cropped mask
function [hObject, eventdata, handles] = SetLastSlice(hObject, eventdata, handles)

    handles.img = handles.img(:,:,1:handles.slice);

    if isfield(handles,'bwContour') == 1
        handles.bwContour = handles.bwContour(:,:,1:handles.slice);
    end

    [handles, ~] = abcResize(handles, hObject);
    windowResize(handles, hObject);
    
    handles.slice = handles.abc(3); % Set the current slice to the previous current slice (new last slice)
    set(handles.editSliceNumber,'String',num2str(handles.slice));
    set(handles.sliderIMG,'Value',handles.slice);
    
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);
end