% NAME-SubtractContour
% DESC-Allows the user to draw a black and white mask to be removed from the 
% current mask
% IN-Freehand 2D image draw by user
% handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function [hObject, eventdata, handles] = SubtractContour(hObject, eventdata, handles)
    if isfield(handles, 'bwContour')
        % Open freehand drawing tool and create a mask
        h = drawfreehand(handles.axesIMG);
        % Remove area covered by new mask from existing mask
        tmp = handles.bwContour(:,:,handles.slice);
        tmp(h.createMask)=0;
        handles.bwContour(:,:,handles.slice)=tmp;
        handles = updateContour(handles);
        updateImage(hObject, eventdata, handles);
    else
        noMaskError();
    end