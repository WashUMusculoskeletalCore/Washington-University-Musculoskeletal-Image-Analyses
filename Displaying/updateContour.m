% NAME-updateContour
% DESC-Performs actions needed after updating handles.bwContour
% IN-handles.bwContour: The 3D mask
% OUT-handles.toggleMask: Whether or not to show the mask
% handles.togglebuttonToggleMask: The button to show or hide the mask
function updateContour(hObject, handles)
    % If there is a mask, ensure it is shown
    if isfield(handles, 'bwContour') && any(handles.bwContour, 'all')
        handles.toggleMask = true;
        set(handles.togglebuttonToggleMask,'Value',1);
    else
        handles.toggleMask = false;
        set(handles.togglebuttonToggleMask,'Value',0);
    end
    updateImage(hObject, handles)
end

