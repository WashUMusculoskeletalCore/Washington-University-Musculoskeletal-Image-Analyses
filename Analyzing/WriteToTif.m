% DESC-Save the image as a series of .tif files
function [hObject,eventdata,handles] = WriteToTif(hObject,eventdata,handles)

try
    setStatus(hObject, handles, 'Busy');
    mkdir(fullfile(handles.pathstr,[handles.DICOMPrefix 'TIF']));
    zers = '000000';
    [a b c] = size(handles.img);
    % Write each slice as a tiff
    for i = 1:c
        slice = num2str(i);
        len = length(slice);
        displayPercentLoaded(hObject, handles, i/c);
        pathTmp = fullfile(handles.pathstr,[handles.DICOMPrefix 'TIF']);
        fName = [handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.tif']; % Give each slice a unique 6 digit number with leading zeros
        imwrite(handles.img(:,:,i),fullfile(pathTmp,fName));
    end
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end