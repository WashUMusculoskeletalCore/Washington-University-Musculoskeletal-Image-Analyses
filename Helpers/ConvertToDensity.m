% NAME-ConvertToDensity
% DESC-Converts the image to a density map using mgHA/cc or Hounsfield
% units
% IN-handles.img: The 3D image
% handles.info: the DICOM info struct
% type: the density tyoe to use, 1 for mgHA/cc, 2 for Hounsfield units
% OUT-handles.img: The density map
function ConvertToDensity(hObject, handles, type)
    if isfield(handles, 'img')
        if isfield(handles, 'imgOrig')
            answer = questdlg('There is a saved image. Do you want to overwrite it?', 'Save Image?', 'Overwrite', 'Proceed without saving', 'Cancel', 'Cancel');
            switch answer
                case 'Overwrite'
                    % Save the current image
                    handles = SaveImage(handles);
                case 'Proceed without saving'
                    % Do nothing
                otherwise
                    setStatus(handles, 'Canceled');
                    return;
            end
        else
            % Save the current image
            handles = SaveImage(handles);
        end    
        switch type
            case 1
                [handles.img, ~] = calculateDensityFromDICOM(handles.info, handles.img);
            case 2
                [~, handles.img] = calculateDensityFromDICOM(handles.info, handles.img);
        end
        handles = windowResize(handles);   
        updateWindow(hObject, handles);
    else
        noImgError;
    end