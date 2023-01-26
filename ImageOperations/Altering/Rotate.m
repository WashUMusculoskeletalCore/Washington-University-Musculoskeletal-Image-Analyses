% NAME-Rotate
% DESC-Executes on button press, rotates the image and mask a selected 
% number of degrees
% IN-handles.rotateDegrees: The number of degrees to rotate
% OUT-handles.img: The rotated image
% handles.bwContour: The rotated mask
function Rotate(hObject, handles, angle)
    % For multiples of 90
    if mod(handles.rotateDegrees, 90) == 0
        % Get the number of 90 degree rotations needed
        numRotate = mod(handles.rotateDegrees, 360)/90;
        % 3 is Z-axis
        handles.img = rot90_3D(handles.img, 3, numRotate);
        handles = abcResize(handles);
        if isfield(handles,'bwContour')
            handles.bwContour = rot90_3D(handles.bwContour, 3, numRotate);
            updateContour(hObject, handles);
        else
            updateImage(hObject, handles);
        end
    else 
        %Create temp storage with the same depth as the image
        tmp = cell([1, handles.abc(3)]);
        if isfield(handles, 'bwContour')
            tmp2 = cell([1, handles.abc(3)]);
        end
        % For each slice, rotate the image and mask and store the new
        % image/mask slice in tmp and tmp2
        for i = 1:handles.abc(3)
            tmp{i} = imrotate(handles.img(:,:,i),angle,'crop');
            if isfield(handles,'bwContour')
                tmp2{i} = imrotate(handles.bwContour(:,:,i),angle,'crop');
            end
        end
        clear handles.img;
        % Replace the image with the rotated version
        for i = 1:handles.abc(3)
            handles.img(:,:,i) = tmp{i};
        end
        handles = abcResize(handles);
        % Replace the mask with the rotated version
        if isfield(handles,'bwContour')
            for i = 1:handles.abc(3)
                handles.bwContour(:,:,i) = tmp2{i};
            end
            updateContour(hObject, handles);
        else
            updateImage(hObject, handles);
        end
    end
end

