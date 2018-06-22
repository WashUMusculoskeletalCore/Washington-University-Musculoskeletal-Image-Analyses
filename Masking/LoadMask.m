function [hObject,eventdata,handles] = LoadMask(hObject,eventdata,handles)

answer = get(handles.editMaskName,'String');
handles.bwContour = eval(['handles.' answer]);
guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);
