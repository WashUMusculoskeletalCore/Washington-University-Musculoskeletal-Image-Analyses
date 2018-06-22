function [hObject,eventdata,handles] = ExecuteFilter(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    rad = str2num(get(handles.editRadius,'String'));
    weight = str2num(get(handles.editSigma,'String'));
    
    str = get(handles.popupmenuFilter,'String');
    val = get(handles.popupmenuFilter,'Value');
    switch str{val}
        case '3D Median'
            handles.img = uint16(smooth3(handles.img,'box',[rad rad rad]));
        case '3D Gaussian'
            handles.img = imgaussfilt3(handles.img,weight,'FilterSize',rad);
        case '2D Median'
            [a b c] = size(handles.img);
            for i = 1:c
                handles.img(:,:,i) = medfilt2(handles.img(:,:,i),[rad rad]);
            end
        case '2D Gaussian'
            handles.img = imgaussfilt(handles.img,weight,'FilterSize',rad);
        case '2D Mean'
            h = fspecial('average',rad);
            handles.img = imfilter(handles.img,h);
        case 'Local Standard Deviation'
            handles.img = stdfilt(handles.img,true([rad rad rad]));
        case 'Range'
            handles.img = rangefilt(handles.img,true([rad rad rad]));
        case 'Entropy'
            handles.img = entropyfilt(handles.img,true([rad rad rad]));
            
            
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