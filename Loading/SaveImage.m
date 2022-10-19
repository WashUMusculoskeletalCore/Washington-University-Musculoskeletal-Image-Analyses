% NAME-SaveImage
% DESC-Saves the current image as the original
% IN-handles.img: The image to be saved
% handles.info.SliceThickness: The slice thickness of the original image
% OUT-handles.imgOrig: The saved copy of the image
% handles.thicknessOrig: The saved slice thickness
function handles = SaveImage(handles)
    if isfield(handles, 'img')
        % Save the image
        handles.imgOrig = handles.img;
        % Save the image resolution
        handles.ResolutionOrig = [handles.info.PixelSpacing(1), handles.info.PixelSpacing(2), handles.info.SliceThickness];
    else
        noImgError;
    end
end

