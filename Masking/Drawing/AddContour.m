% NAME-AddContour
% DESC-Allows the user to draw a black and white mask to be added to the 
% current mask
% IN-Freehand 2D image draw by user
% handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function [hObject, eventdata, handles] = AddContour(hObject, eventdata, handles)
    if isfield(handles, 'img') 
        if ~isfield(handles, 'bwContour')
            handles.bwContour = false(size(handles.img));
        end
        % Ensure that the mask is displayed
        handles.toggleMask = true;
        set(handles.togglebuttonToggleMask,'Value',1);
        updateImage(hObject,eventdata,handles);
        % Open freehand drawing tool and create a mask
        h = drawfreehand(handles.axesIMG);
        % Add new mask to existing mask
        tmp = handles.bwContour(:,:,handles.slice);
        tmp(h.createMask)=1;
        handles.bwContour(:,:,handles.slice)=tmp;       
        guidata(hObject, handles);
        updateImage(hObject,eventdata,handles);
    else
        noImgError();
    end

