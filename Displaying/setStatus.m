% NAME-setStatus
% DESC-sets the textBusy field to the chosen value
% IN-status: the status to be set as a string
% OUT-handles.textBusy: the status textbox
function setStatus(handles, status)
        set(handles.textBusy, 'String', status);
        drawnow nocallbacks
end

