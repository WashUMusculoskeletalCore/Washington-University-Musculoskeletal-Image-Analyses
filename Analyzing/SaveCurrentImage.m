function [hObject,eventdata,handles] = SaveCurrentImage(hObject,eventdata,handles)

try
    setStatus(hObject, handles, 'Busy');
    outFile = fullfile(handles.pathstr,[get(handles.editDICOMPrefix,'String') '.tif']);
    imwrite(getimage(handles.axesIMG),outFile);
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end