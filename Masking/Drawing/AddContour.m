% NAME-AddContour
% DESC-Allows the user to draw a black and white mask to be added to the 
% current mask
% IN-Freehand 2D image draw by user
% handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function AddContour(hObject, handles)
    if isfield(handles, 'img') 
        if ~isfield(handles, 'bwContour')
            handles.bwContour = false(size(handles.img));
        end
        % Open freehand drawing tool and create a mask
        h = drawfreehand(handles.axesIMG);
        % Add new mask to existing mask
        tmp = handles.bwContour(:,:,handles.slice);
        tmp(h.createMask)=1;
        handles.bwContour(:,:,handles.slice)=tmp;
        updateContour(hObject, handles);
    else
        noImgError;
    end

