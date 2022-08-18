% NAME-LoadMask
% DESC-Loads a saved mask with a given name
% IN-handles.maskName: the name of the mask to be loaded
% handles.savedMasks: a map containing all saved masks
% OUT-handles.bwContour: the 3D mask loaded from savedMasks
function [hObject,eventdata,handles] = LoadMask(hObject,eventdata,handles)
    if isfield(handles, 'savedMasks') && isKey(handles.savedMasks, handles.maskName)
        tmp = handles.savedMasks(handles.maskName);
        if isfield(handles, 'img') && isequal(size(tmp), handles.abc)
            handles.bwContour = tmp;
            handles = updateContour(handles);
            updateImage(hObject, eventdata, handles);
        else
            errorMsg('Saved mask is not the same size as image')
        end
    else
        errorMsg('No saved mask with that name');
    end
