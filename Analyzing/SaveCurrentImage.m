% NAME-SaveCurrentImage
% DESC-Saves the image of the current slice, including any overlays, as a .tif
% IN: handles.axesIMG: the axes for displaying the image
% handles.editDICOMPrefix: the filename to save the image as.
% OUT: outfile: writes a tif file to the current directory
function SaveCurrentImage(handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'img')
            % Write the image to [prefix].tif in the current folder
            outFile = fullfile(handles.pathstr,[get(handles.editDICOMPrefix,'String') '.tif']);
            imwrite(getimage(handles.axesIMG),outFile);
        else
            noImgError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end