% NAME-DrawContour
% DESC-Allows the user to draw a black and white mask
% IN-Freehand 2d image draw by user
%    handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function [hObject, eventdata, handles] = DrawContour(hObject, eventdata, handles)
    if isfield(handles, 'img')
        if ~isfield(handles, 'bwContour')
            handles.bwContour = false(size(handles.img));
        end
        % Open freehand drawing tool and create a mask
        h = drawfreehand(handles.axesIMG);
        handles.bwContour(:,:,handles.slice) = createMask(h);
        handles = updateContour(handles);
        updateImage(hObject, eventdata, handles);
    else
        noImgErorr();
    end