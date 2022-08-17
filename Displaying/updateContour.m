% NAME-updateContour
% DESC-Performs actions needed after updating handles.bwContour
function handles = updateContour(handles)
    if strcmp(get(handles.pushbuttonSetMaskToComponent, 'Enable'), 'on')
        set(handles.pushbuttonSetMaskToComponent, 'Enable', 'off');
        set(handles.popupmenuMaskComponents, 'Value', 1);
        set(handles.popupmenuMaskComponents, 'String', 'Mask Components');
    end
end

