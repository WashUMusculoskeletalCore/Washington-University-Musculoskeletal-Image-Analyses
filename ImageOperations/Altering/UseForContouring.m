% NAME-UseForContouring
% DESC-Adjust the image to match the brightness window for easier
% contouring, and saves the original image as a backup
% IN-handles.img: the 3D image
% handles.lOut: the lower range of the brightness window
% handles.hOut: the upper range of the brightness window
% OUT-handles.imgOrig: a saved copy of the original image
function [hObject,eventdata,handles] = UseForContouring(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        if isfield(handles, 'img')
            % Save original image so it can be reverted to when done contouring
            if isfield(handles,'imgOrig') == 0
                handles.imgOrig = handles.img;
            end
            % Adjust image threshold to the window
            for i = 1:handles.abc(3)
                handles.img(:,:,i) = imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)],[]);
            end
            guidata(hObject, handles);
            updateImage(hObject, eventdata, handles);
        end
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end