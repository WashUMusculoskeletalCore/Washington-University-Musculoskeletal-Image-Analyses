% NAME-SetLastSlice
% DESC-Crop all slices after the current slice
% IN-handles.slice: the slice to become the new last slice
% OUT-handles.img: the cropped image
% handles.bwCountour: the cropped mask
function [hObject, handles] = SetLastSlice(hObject, handles)
    if isfield(handles, 'img')
        handles.img = handles.img(:,:,1:handles.slice);

        handles = abcResize(handles);
        handles = windowResize(handles);

        handles.slice = handles.abc(3); % Set the current slice to the previous current slice (new last slice)
        set(handles.editSliceNumber,'String',num2str(handles.slice));
        set(handles.sliderIMG,'Value',handles.slice);

        if isfield(handles,'bwContour')
            handles.bwContour = handles.bwContour(:,:,1:handles.abc(3));
            updateContour(hObject, handles);
        else
            updateImage(hObject, handles);
        end
    else
        noImgError;
    end
end