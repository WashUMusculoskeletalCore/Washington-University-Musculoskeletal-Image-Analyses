% NAME-setStatus
% DESC-sets the textBusy field to the chosen value
% IN-status: the status to be set as a string
% OUT-handles.textBusy: the status textbox
function setStatus(handles, status)
        set(handles.textBusy, 'String', status);
        switch status
            case {'Not Busy', 'Image saved'}
                set(handles.textBusy, 'BackgroundColor', 'Green')
            case {'Failed','Input Error', 'Cancelled'}
                set(handles.textBusy, 'BackgroundColor', 'Red')
            otherwise
                set(handles.textBusy, 'BackgroundColor', 'Yellow')
        end
        drawnow nocallbacks
end

