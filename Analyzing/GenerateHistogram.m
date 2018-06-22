function [hObject,eventdata,handles] = GenerateHistogram(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    [a b c] = size(handles.img);
    img = reshape(handles.img,[1,a*b*c]);
    figure;
    histogram(img(find(img > 0)),320);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end