% NAME-GenerateHistogram
% DESC-Generates a histogram showing the relative frequency of all nonzero
% values in the image
% IN-handles.img: the 3D black and white image
% OUT-UI: a histogram representing how many voxels in the image fall within
% various ranges
%TODO-Change to per slice?
function GenerateHistogram(handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'img')
            % Reshape the image into a 1D arrray
            [a, b, c] = size(handles.img);
            img = reshape(handles.img, [1,a*b*c]);
            figure;
            % Generate the histogram of all nonzero value in the image with 320 bins
            histogram(nonzeros(img), 320);
        else
            noImgError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end