% DESC-Allows the user to draw a black and white mask to be removed from 
% the current mask
% IN-Freehand 2d image draw by user
%    handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function [hObject, eventdata, handles] = pushbuttonSubtractContourk(hObject, eventdata, handles)
% Open freehand drawing tool and create a mask
h = imfreehand(handles.axesIMG);
tmp = h.createMask;
tmp2 = handles.bwContour(:,:,handles.slice);
% Remove area covered by new mask from existing mask
tmp2(tmp) = 0;
handles.bwContour(:,:,handles.slice) = tmp2;
guidata(hObject, handles);
UpdateImage(hObject,eventdata,handles);