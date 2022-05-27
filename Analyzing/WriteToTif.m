% DESC-Save the image as a series of .tif files
function [hObject,eventdata,handles] = WriteToTif(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    drawnow();
    mkdir(fullfile(handles.pathstr,[handles.DICOMPrefix 'TIF']));
    zers = '000000';
    [a b c] = size(handles.img);
    % Write each slice as a tiff
    for i = 1:c
        slice = num2str(i);
        len = length(slice);
        set(handles.textPercentLoaded,'String',num2str(i/c)); % Display percentage
        drawnow();
        pathTmp = fullfile(handles.pathstr,[handles.DICOMPrefix 'TIF']);
        fName = [handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.tif']; % Give each slice a unique 6 digit number with leading zeros
        imwrite(handles.img(:,:,i),fullfile(pathTmp,fName));
    end
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end