function [hObject, eventdata, handles] = updateThreshold(hObject, eventdata, handles)
    if isfield(handles, 'img')
        % Display the area currently within the threshold
        lowThresh = handles.threshold;
        highThresh = handles.upperThreshold;
        thresh= false(size(handles.img(:,:,handles.slice)));
        thresh(handles.img(:,:,handles.slice) > lowThresh) = 1;
        thresh(handles.img(:,:,handles.slice) > highThresh) = 0;
        superimpose(handles, thresh);
        guidata(hObject, handles);
    end
end

