% NAME-RevertImage
% DESC-Reverts the image to a saved version
% OUT-handles.img: the image reverted to a the saved version
% handles.bwContour: the mask, removed if the image is resized
function [hObject,eventdata,handles] = RevertImage(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        prevABC = handles.abc;
        handles.img = handles.imgOrig;   
        [hObject, handles] = abcResize(hObject, handles);
        handles = windowResize(handles);

        %answer = inputdlg('Would you like to reset the contour? If you changed the image size, you must. y or n');
        %if strcmpi(answer{1}, 'y') == 1
        if handles.abc ~= prevABC
            if isfield(handles, 'bwContour') == 1
                handles.bwContour = [];
                handles = rmfield(handles,'bwContour');
                handles = updateContour(handles);
            end
        end
        % handles.bwContour = false(size(handles.img));
        % handles.bwContourOrig = handles.bwContour;

        updateImage(hObject, eventdata, handles);
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end