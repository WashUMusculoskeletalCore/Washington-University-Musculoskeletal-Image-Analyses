% NAME-ConvertToDensity
% DESC-Converts the image to a density map using mgHA/cc or Hounsfield
% units
% IN-handles.img: The 3D image
% handles.info: the DICOM info struct
% type: the density tyoe to use, 1 for mgHA/cc, 2 for Hounsfield units
% OUT-handles.img: The density map
function [handles, eventdata, hObject] = ConvertToDensity(hObject, eventdata, handles, type)
    if isfield(handles, 'imgOrig')
        answer = questdlg('There is a saved image. Do you want to overwrite it?', 'Save Image?', 'Overwrite', 'Proceed without saving', 'Cancel', 'Cancel');
        switch answer
            case 'Overwrite'
                % Save the current image
                handles.imgOrig = handles.img;
            case 'Proceed without saving'
                % Do nothing
            otherwise
                setStatus(hObject, handles, 'Canceled');
                return;
        end
    else
        % Save the current image
        handles.imgOrig = handles.img;
    end
    switch type
        case 1
            [handles.img, ~] = calculateDensityFromDICOM(handles.info, handles.img);
        case 2
            [~, handles.img] = calculateDensityFromDICOM(handles.info, handles.img);
    end
    handles = windowResize(handles);   
    guidata(hObject, handles);
    updateWindow(hObject, eventdata, handles);