% NAME-GenerateHistogram
% DESC-Generates a histogram showing the relative frequency of all nonzero
% values in the image
% IN-handles.img: the 3D black and white image
% OUT-UI: a histogram representing how many voxels in the image fall within
% various ranges
function [hObject,eventdata,handles] = GenerateHistogram(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        if isfield(handles, 'img')
            % Reshape the image into a 1D arrray
            [a, b, c] = size(handles.img);
            img = reshape(handles.img, [1,a*b*c]);
            figure;
            % Generate the histogram of all nonzero value in img
            histogram(nonzeros(img), 320);
        else
            noImgError();
        end
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end