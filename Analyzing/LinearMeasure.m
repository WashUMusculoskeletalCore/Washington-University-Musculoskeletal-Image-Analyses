% NAME-LinearMeasure
% DESC-Creates a movable line  over the image that displays the distance between the endpoints
% IN-UI: User draws a line
% handles.info.SliceThickness: the conversion factor for pixels to mm
% OUT-UI: Displays the length of the line
function LinearMeasure(handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'img')
            % Create an interactive distance line tool
            % TODO-find a way to end this if image changes
            setStatus(handles, 'Draw a line');
            ruler = drawline(handles.axesIMG);
            UpdateLabel(ruler, ruler.Position, handles.info.SliceThickness)
            addlistener(ruler, 'MovingROI', @(src, event)MoveLineCallback(src, event, handles.info.SliceThickness));
        else
            noImgError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end
end

% NAME-MoveLineCallback
% DESC-Called when the line is moved, updates the label
% IN-event.CurrentPosition: The position of the line after the movement
% that triggered the callback
% src: The line that triggered the callback
% scale: the scale to pass to UpdateLabel, should be set when the callback
% is created
function MoveLineCallback(src, event, scale)
    UpdateLabel(src, event.CurrentPosition, scale);
end

% NAME-UpdateLabel
% DESC-Sets the label to show the physical distance
% IN-pos: the position of the line endpoints
% scale: the scale from pixels to mm
% OUT-line.label: the label displayed on the line
function UpdateLabel(line, pos, scale)      
    % Calculates the distance from the position
    pix = pdist(pos,'euclidean');
    pixPhys = pix * scale;
    % Overwrites the normal label to show physical distance
    line.Label = [num2str(pixPhys) ' mm'];
    drawnow();
end
