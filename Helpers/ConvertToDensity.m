function [handles,eventdata,hObject] = ConvertToDensity(hObject,eventdata,handles)

[handles.img,tmp] = calculateDensityFromDICOM(handles.info,handles.img);
guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);