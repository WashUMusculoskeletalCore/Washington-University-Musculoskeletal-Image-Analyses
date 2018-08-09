function [handles,eventdata,hObject] = ConvertToHounsfield(hObject,eventdata,handles)

[~,handles.img] = calculateDensityFromDICOM(handles.info,handles.img);
guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);