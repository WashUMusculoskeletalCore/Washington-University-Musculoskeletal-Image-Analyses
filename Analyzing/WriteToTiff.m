% NAME-WriteToTiff
% DESC-Save the image as a series of .tif files
% IN-handles.img: the current image
% handles.DICOMPrefix: the prefix to add to the beginning of every output filename
% OUT-IO:Writes a set of .tif files
function WriteToTiff(handles)
    try
        setStatus(handles, 'Busy');
        displayPercentLoaded(handles, 0);
        if isfield(handles, 'img')
            mkdir(fullfile(handles.pathstr,[handles.DICOMPrefix 'TIF']));
            % Write each slice as a tiff
            for i = 1:handles.abc(3)
                displayPercentLoaded(handles, i/handles.abc(3));
                pathTmp = fullfile(handles.pathstr,[handles.DICOMPrefix 'TIF']);
                fName = [handles.DICOMPrefix '-' sprintf('%05d', i) '.tif']; % Give each slice a unique 5 digit number with leading zeros
                imwrite(handles.img(:,:,i),fullfile(pathTmp,fName));
            end
        else
            noImgError();
        end
        displayPercentLoaded(handles, 1);
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end