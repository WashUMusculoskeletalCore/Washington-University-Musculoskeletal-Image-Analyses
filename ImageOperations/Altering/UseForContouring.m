% NAME-UseForContouring
% DESC-Saves the current image as the original if none exists, and adjusts
% the image's thresholds
% TODO-not sure how this uses the image for contouring
function [hObject,eventdata,handles] = UseForContouring(hObject,eventdata,handles)
try
    setStatus(hObject, handles, 'Busy');
    % Save original image
    if isfield(handles,'imgOrig') == 0
        handles.imgOrig = handles.img;
    end
    % Adjust image threshold
    for i = 1:handles.abc(3)
        handles.img(:,:,i) = imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)],[]);
    end
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end