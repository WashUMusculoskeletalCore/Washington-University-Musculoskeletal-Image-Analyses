function [hObject,eventdata,handles] = UseForContouring(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    if isfield(handles,'imgOrig') == 0
        handles.imgOrig = handles.img;
    end
    [a b c] = size(handles.img);
    for i = 1:c
        handles.img(:,:,i) = imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)],[]);
    end
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end