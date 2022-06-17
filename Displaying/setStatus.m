function setStatus(hObject, handles, status)
        set(handles.textBusy, 'String', status);
        guidata(hObject, handles);
        drawnow nocallbacks
end

