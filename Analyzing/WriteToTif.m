% NAME-WriteToTif
% DESC-Save the image as a series of .tif files
% IN-handles.img: the current image
% handles.DICOMPrefix: the prefix to add to the beginning of every output filename
% OUT-IO:Writes a set of .tif files
function [hObject,eventdata,handles] = WriteToTif(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        if isfield(handles, 'img')
            mkdir(fullfile(handles.pathstr,[handles.DICOMPrefix 'TIF']));
            % Write each slice as a tif
            for i = 1:handles.abc(3)
                displayPercentLoaded(hObject, handles, i/handles.abc(3));
                pathTmp = fullfile(handles.pathstr,[handles.DICOMPrefix 'TIF']);
                fName = [handles.DICOMPrefix '-' sprintf('%05d', i) '.tif']; % Give each slice a unique 5 digit number with leading zeros
                imwrite(handles.img(:,:,i),fullfile(pathTmp,fName));
            end
        else
            noImgError();
        end
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end