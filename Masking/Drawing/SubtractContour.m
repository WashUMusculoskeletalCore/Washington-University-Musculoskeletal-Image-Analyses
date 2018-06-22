function [hObject, eventdata, handles] = pushbuttonSubtractContourk(hObject, eventdata, handles)

h = imfreehand(handles.axesIMG);
tmp = h.createMask;
tmp2 = handles.bwContour(:,:,handles.slice);
tmp2(tmp) = 0;
handles.bwContour(:,:,handles.slice) = tmp2;
guidata(hObject, handles);
UpdateImage(hObject,eventdata,handles);