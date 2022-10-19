% NAME-updateWindow
% DESC-sets the high and low output values for the brightness window
% IN-handles.windowWidth: the range of the window
% handles.windowLocation: the center of the window
% OUT-handles.lOut: the low end of the window
% handles.hOut: the high end of the window
function updateWindow(hObject, handles)
    if isfield(handles, 'img')
        % Set lOut and hOut to the location of left and right side of window
        % divided by the window range
        handles.lOut = (handles.windowLocation-0.5*handles.windowWidth) / (2^16-1);
        handles.hOut = (handles.windowLocation+0.5*handles.windowWidth)  / (2^16-1);
        % Ensure that lOut and hOut do not go past minimum/maximum
        if handles.lOut < 0
            handles.lOut = 0;
        end
        if handles.hOut > 1
            handles.hOut = 1;
        end
        updateImage(hObject, handles);
    end
end


