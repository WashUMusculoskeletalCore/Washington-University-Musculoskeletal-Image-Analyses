% DESC-Uses mask at start and end of morph range as template to generate
% mask in the middle
% IN-handles.endMorph: The slice at the top of the area to be generated
% handles.startMorph: The slice at the bottom of the area to be generated
% handles.bwContour: The 3d mask, must have values at startMorph and 
% endMorph slices
% OUT-handles.bwContour: The 3d mask between startMorph and endMorph slices
function [hObject, eventdata, handles] = MorphRange(hObject, eventdata, handles)

try
    setStatus(hObject, handles, 'Busy');
    % Get the shape formed by the mask at startMorph and endMorph
    bwTemp = interp_shape(handles.bwContour(:,:,handles.startMorph),handles.bwContour(:,:,handles.endMorph),abs(handles.startMorph - handles.endMorph)+1);
    bwTemp = flip(bwTemp,3); % Flips the shape in z dirrection
    handles.bwContour(:,:,handles.startMorph:handles.endMorph) = bwTemp; % Apply the shape to the mask between start and end
    guidata(hObject, handles);
    updateImage(hObject,eventdata,handles);
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end

