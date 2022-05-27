% DESC-Allows the user to draw a black and white mask to be added to the 
% current mask
% IN-Freehand 2d image draw by user
%    handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function [hObject, eventdata, handles] = AddContour(hObject, eventdata, handles)

% Open freehand drawing tool and create a mask
% TODO- replace freehand with recomended function
h = imfreehand(handles.axesIMG);
tmp = h.createMask;
tmp2 = handles.bwContour(:,:,handles.slice);
% Add new mask to existing mask
tmp2(tmp) = 1;
handles.bwContour(:,:,handles.slice) = tmp2;
guidata(hObject, handles);
UpdateImage(hObject,eventdata,handles);

