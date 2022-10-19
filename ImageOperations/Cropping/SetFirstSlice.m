% NAME-SetFirstSlice
% DESC-Crop all slices before the current slice
% IN-handles.slice: the slice to become the new first slice
% OUT-handles.img: the cropped image
% handles.bwCountour: the cropped mask
function SetFirstSlice(hObject, handles)
    if isfield(handles, 'img')
        first = handles.slice;
        handles.img = handles.img(:,:,first:end);
        handles = abcResize(handles);
        handles = windowResize(handles);
        if isfield(handles,'bwContour')
            handles.bwContour = handles.bwContour(:,:,first:end);
            updateContour(hObject, handles);
        else
            updateImage(hObject, handles);
        end
    else
        noImgError;
    end
end