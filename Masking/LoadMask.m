% NAME-LoadMask
% DESC-Loads a saved mask with a given name
% IN-handles.maskName: the name of the mask to be loaded
% handles.savedMasks: a map containing all saved masks
% OUT-handles.bwContour: the 3D mask loaded from savedMasks
function LoadMask(hObject, handles)
    if isfield(handles, 'savedMasks') && isKey(handles.savedMasks, handles.maskName)
        tmp = handles.savedMasks(handles.maskName);
        if isfield(handles, 'img') && isequal(size(tmp), handles.abc)
            handles.bwContour = tmp;
            updateContour(hObject, handles);
        else
            errorMsg('Saved mask is not the same size as image');
        end
    else
        errorMsg('No saved mask with that name');
    end
