% NAME-SetFirstSlice
% DESC-Crop all slices before the current slice
% IN-handles.slice: the slice to become the new first slice
% OUT-handles.img: the cropped image
% handles.bwCountour: the cropped mask
function [hObject, eventdata, handles] = SetFirstSlice(hObject, eventdata, handles)
    if isfield(handles, 'img')
        handles.img = handles.img(:,:,handles.slice:end);

        if isfield(handles,'bwContour')
            handles.bwContour = handles.bwContour(:,:,handles.slice:end);
        end

        [hObject, handles] = abcResize(hObject, handles);
        handles = windowResize(handles);

        guidata(hObject, handles);
        updateImage(hObject, eventdata, handles);
    end
end