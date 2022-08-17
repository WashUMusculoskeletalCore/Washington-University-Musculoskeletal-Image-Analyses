% NAME-AdjustCurrentSlice
% DESC-Adjusts the mask on the current slice to match the image
% IN-handles.img: The 3d image to be matched
% handles.bwContour: The 3d mask, should have a value on the current slice
% close to a object in the image
% handles.slice: The number of the current slice to be adjusted
% handles.contourMethod: the contouring method to be used by the algorithm
% handles.smoothFactor: the smooth factor to be used by the algorithm
% handles.contractionBias: the contraction bias to be used by the algorithm
% handles.iterations: The number of iterations to be used by the algorithm
% OUT-Handles.bwCountor: The 3d mask, with the current slice adjusted
function [hObject, eventdata, handles] = AdjustCurrentSlice(hObject, eventdata, handles)

try
    setStatus(hObject, handles, 'Busy');
    if isfield(handles, 'img') && isfield(handles, 'bwContour')
        % Get image and mask for current slice
        img = handles.img(:,:,handles.slice);
        bw = handles.bwContour(:,:,handles.slice);
        % Apply active contour algorithm to match mask to nearby object
        % boundaries in image
        bw = activecontour(img,bw,...
            handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
        % Set mask to new mask
        handles.bwContour(:,:,handles.slice) = bw;
        guidata(hObject, handles);
        updateImage(hObject,eventdata,handles);
    end
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end