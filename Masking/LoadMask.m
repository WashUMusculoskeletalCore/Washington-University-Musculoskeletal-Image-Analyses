function [hObject,eventdata,handles] = LoadMask(hObject,eventdata,handles)
%Sets mask to chosen saved mask
answer = get(handles.editMaskName,'String');
% TODO-potential injection
handles.bwContour = eval(['handles.' answer]);
guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);
