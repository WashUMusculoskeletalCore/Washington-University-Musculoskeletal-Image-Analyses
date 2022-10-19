% NAME-RevertImage
% DESC-Reverts the image to a saved version
% OUT-handles.img: the image reverted to a the saved version
% handles.bwContour: the mask, removed if the image is resized
function RevertImage(hObject, handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'imgOrig')
            prevABC = handles.abc;
            handles.img = handles.imgOrig; 
            % Load resolution info
            handles.info.PixelSpacing(1) = handles.ResolutionOrig(1);
            handles.info.PixelSpacing(2) = handles.ResolutionOrig(2);
            handles.info.SliceThickness = handles.ResolutionOrig(3);
            % Resize the image to the original size
            handles = abcResize(handles);
            handles = windowResize(handles);
            % If the image has changed size, remove the mask, otherwise keep it
            if any(handles.abc ~= prevABC) && isfield(handles, 'bwContour')
                handles.bwContour = [];
                handles = rmfield(handles,'bwContour');
                updateContour(hObject, handles);
            end
            updateWindow(hObject, handles);
        else
            errorMsg('No original image set');
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end