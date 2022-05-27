function [hObject, eventdata, handles] = AdjustCurrentSlice(hObject, eventdata, handles)

try
    set(handles.textBusy,'String','Busy');
    % Get image and mask for current slice
    img = handles.img(:,:,handles.slice);
    bw = handles.bwContour(:,:,handles.slice);
    % Apply active contour algorithm to match mask to nearby object
    % boundaries in image
    bw = activecontour(img,bw,...
        handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
    % Set mask to new mask
    handles.bwContour(:,:,handles.slice) = bw;
    guidata(hObject, handles);
    UpdateImage(hObject,eventdata,handles);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end