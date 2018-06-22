function [hObject,eventdata,handles] = updateImage(hObject,eventdata,handles)

if isfield(handles,'bwContour') == 0
    imshow(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[]),'Parent',handles.axesIMG);
    colormap(handles.axesIMG,handles.colormap);
else
    imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
    %     handles.colormap = 'gray';
    colormap(handles.axesIMG,handles.colormap);
end
impixelinfo(handles.axesIMG);
guidata(hObject,handles);