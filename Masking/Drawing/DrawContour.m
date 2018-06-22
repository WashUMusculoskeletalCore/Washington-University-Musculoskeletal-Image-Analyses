function [hObject, eventdata, handles] = DrawContour(hObject, eventdata, handles)
% hObject    handle to pushbuttonDrawContour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'bwContour') == 0
    handles.bwContour = false(size(handles.img));
end
h = imfreehand(handles.axesIMG);
handles.bwContour(:,:,handles.slice) = createMask(h);
guidata(hObject, handles);
UpdateImage(hObject,eventdata,handles);