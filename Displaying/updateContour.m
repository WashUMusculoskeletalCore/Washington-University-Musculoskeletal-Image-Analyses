% NAME-updateContour
% DESC-Performs actions needed after updating handles.bwContour
function handles = updateContour(handles)
    % If there is a mask, ensure it is shown
    if isfield(handles, 'bwContour') && any(handles.bwContour, 'all')
        handles.toggleMask = true;
        set(handles.togglebuttonToggleMask,'Value',1);
    else
        handles.toggleMask = false;
        set(handles.togglebuttonToggleMask,'Value',0);
    end
end

