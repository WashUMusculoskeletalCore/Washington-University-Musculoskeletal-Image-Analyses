% DESC-Allows the user to draw a black and white mask
% IN-Freehand 2d image draw by user
%    handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function [hObject, eventdata, handles] = DrawContour(hObject, eventdata, handles)
% hObject    handle to pushbuttonDrawContour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'bwContour') == 0
    handles.bwContour = false(size(handles.img));
end
% Open freehand drawing tool and create a mask
h = imfreehand(handles.axesIMG);
handles.bwContour(:,:,handles.slice) = createMask(h);
guidata(hObject, handles);
UpdateImage(hObject,eventdata,handles);