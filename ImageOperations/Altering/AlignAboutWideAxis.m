function [hObject,eventdata,handles] = AlignAboutWideAxis(hObject,eventdata,handles)

try
    setStatus(hObject, handles, 'Busy')
    answer = inputdlg("Would you like to use only a portion of the images for determining the rotation? y/n");
    if strcmpi(answer{1},'y') == 1
        answer = inputdlg("Please enter the first slice to use");
        first = str2num(answer{1});
        answer = inputdlg("Please enter the last slice to use");
        last = str2num(answer{1});
        img = handles.img(:,:,first:last);
        % Identify the degree that gives the widest horizontal axis for any
        % slice in the range
        degree = RotateWidestHorizontal(img, handles.bwContour(:,:,first:last));    
        clear img;
    else
        degree = RotateWidestHorizontal(handles.img, handles.bwContour);    
    end
    [a, b, c] = size(handles.img);
    for i = 1:c
        displayPercentLoaded(i/c);
        if i == 1
            % For the first slice, create the new array first
            tmp = imrotate(handles.img(:,:,i),degree);
            imgTmp = zeros([size(tmp) c],'uint16');
            bwContourTmp = false(size(imgTmp));
            % TODO- apply first slice of mask
            imgTmp(:,:,i) = tmp;
        else
            imgTmp(:,:,i) = imrotate(handles.img(:,:,i),degree);
            bwContourTmp(:,:,i) = imrotate(handles.bwContour(:,:,i),degree);
        end
    end
    handles.img = imgTmp;
    handles.bwContour = bwContourTmp;
    guidata(hObject, handles);
    UpdateImage(hObject,eventdata,handles);
    setStatus(hObject, handles, 'Not Busy')
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end
