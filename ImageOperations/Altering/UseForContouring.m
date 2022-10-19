% NAME-UseForContouring
% DESC-Adjust the image to match the brightness window for easier
% contouring, and saves the original image as a backup
% IN-handles.img: the 3D image
% handles.lOut: the lower range of the brightness window
% handles.hOut: the upper range of the brightness window
% OUT-handles.imgOrig: a saved copy of the original image
function UseForContouring(hObject,handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'img')
            % Save original image so it can be reverted to when done contouring
            if ~isfield(handles,'imgOrig')
                handles = SaveImage(handles);
            end
            % Adjust image threshold to the window
            for i = 1:handles.abc(3)
                handles.img(:,:,i) = uint16(imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)]));
            end
            handles = windowResize(handles);
            updateWindow(hObject, handles);
        else
            noImgError;
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end