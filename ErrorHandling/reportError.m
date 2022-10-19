% NAME-reportError
% DESC-prints caught error message to console for debugging, change this as
% needed
% IN-err: The error to be reported 
% OUT-IO:Writes to console
function reportError(err, handles)
    % Set the status message
    switch err.identifier
        case 'ContouringGUI:InputCanceled'
            setStatus(handles, 'Cancelled');
            return;
        case 'ContouringGUI:InputError'
            setStatus(handles, 'Input Error');
            errorMsg(err.message);
            return;
        otherwise
            setStatus(handles, 'Failed');
    end
    disp(err.message);
    disp(err.identifier);
    for i = 1:length(err.stack)     
        disp(err.stack(i));
    end
end

