% NAME-SaveCurrentImage
% DESC-Saves the image of the current slice, including any overlays, as a .tif
% IN: handle.axesIMG: the axes for displaying the image
% handles.editDICOMPrefix: the filename to save the image as.
% OUT: outfile: writes a tif file to the current directory
function [hObject,eventdata,handles] = SaveCurrentImage(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        if isfield(handles, 'img')
            % Write the image to [prefix].tif in the current folder
            outFile = fullfile(handles.pathstr,[get(handles.editDICOMPrefix,'String') '.tif']);
            imwrite(getimage(handles.axesIMG),outFile);
        else
            noImgError();
        end
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end