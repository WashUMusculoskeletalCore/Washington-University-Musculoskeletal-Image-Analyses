function [hObject,eventdata,handles] = SaveCurrentImage(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    outFile = fullfile(handles.pathstr,[get(handles.editDICOMPrefix,'String') '.tif']);
    imwrite(getimage(handles.axesIMG),outFile);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end