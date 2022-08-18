% NAME-AlignAboutWideAxis
% DESC-Rotates the image to make the mask as horizontal as possible
% IN-handles.bwContour: the 3D mask
% OUT-handles.img: the 3D image, rotated
% handles.bwContour: the 3D mask , also rotated
function [hObject,eventdata,handles] = AlignAboutWideAxis(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy')
        if isfield(handles, 'bwContour')
            answer = inputdlg("Would you like to use only a portion of the images for determining the rotation? y/n");
            if strcmpi(answer{1},'y') == 1
                answer = inputdlg("Please enter the first slice to use");
                first = str2double(answer{1});
                answer = inputdlg("Please enter the last slice to use");
                last = str2double(answer{1});
                % Identify the degree that gives the widest horizontal axis for any
                % slice in the range
                degree = RotateWidestHorizontal(handles.bwContour(:,:,first:last));    
            else
                degree = RotateWidestHorizontal(handles.bwContour);    
            end
            for i = 1:handles.abc(3)
                displayPercentLoaded(hObject, handles, i/handles.abc(3));
                if i == 1
                    % For the first slice, create the new array first
                    tmp = imrotate(handles.img(:,:,i),degree);
                    imgTmp = zeros([size(tmp) handles.abc(3)],'uint16');
                    bwContourTmp = false(size(imgTmp));
                    imgTmp(:,:,i) = tmp;
                    bwContourTmp(:,:,i) = imrotate(handles.bwContour(:,:,i),degree);
                else
                    imgTmp(:,:,i) = imrotate(handles.img(:,:,i),degree);
                    bwContourTmp(:,:,i) = imrotate(handles.bwContour(:,:,i),degree);
                end
            end
            handles.img = imgTmp;
            handles.bwContour = bwContourTmp;
            [hObject, handles] = abcResize(hObject, handles);
            updateImage(hObject,eventdata,handles);
        else
            noMaskError();
        end
        setStatus(hObject, handles, 'Not Busy')
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end
