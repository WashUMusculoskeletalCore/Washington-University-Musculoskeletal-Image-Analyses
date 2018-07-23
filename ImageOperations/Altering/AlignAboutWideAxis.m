function [hObject,eventdata,handles] = AlignAboutWideAxis(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy')
    guidata(hObject, handles);
    drawnow();
    answer = inputdlg("Would you like to use only a portion of the images for determining the rotation? y/n");
    if strcmpi(answer{1},'y') == 1
        answer = inputdlg("Please enter the first slice to use");
        first = str2num(answer{1});
        answer = inputdlg("Please enter the last slice to use");
        last = str2num(answer{1});
        img = handles.img(:,:,first:last);
        degree = rotateWidestHorizontal(img, handles.bwContour);    
        clear img;
    else
        degree = rotateWidestHorizontal(handles.img, handles.bwContour);    
    end
    [a b c] = size(handles.img);
    for i = 1:c
        imgTmp(:,:,i) = imrotate(handles.img(:,:,i),degree);
        bwContourTmp(:,:,i) = imrotate(handles.bwContour(:,:,i),degree);
    end
    handles.img = imgTmp;
    handles.bwContour = bwContourTmp;
    guidata(hObject, handles);
    UpdateImage(hObject,eventdata,handles);
    set(handles.textBusy,'String','Not Busy')
catch
    set(handles.textBusy,'String','Failed');
end