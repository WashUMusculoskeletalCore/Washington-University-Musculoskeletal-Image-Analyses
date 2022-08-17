% NAME-setStatus
% DESC-sets the textBusy field to the chosen value
% IN-status: the status to be set as a string
% OUT-handles.textBusy: the status textbox
function setStatus(hObject, handles, status)
        set(handles.textBusy, 'String', status);
        guidata(hObject, handles);
        drawnow nocallbacks
end

