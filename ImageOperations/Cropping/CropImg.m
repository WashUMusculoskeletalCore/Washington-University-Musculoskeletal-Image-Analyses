% NAME-CropImg
% DESC-Crops any number of 3D images to a rectangular prism bounding a mask
% IN-varargin: A list of images, the first should be the mask
% OUT-varargout: A list of cropped images the same length as the input list
% pad: An array containing the ammount of padding removed from each side
function [pad, varargout] = CropImg(varargin)
    % Get the range
    sz = size(varargin{1}, [1, 2, 3]);
    [x, y, z] = ind2sub(sz, find(varargin{1}));
    xMin = min(x);
    xMax = max(x);
    yMin = min(y);
    yMax = max(y);
    zMin = min(z);
    zMax = max(z);
    % Crop the images
    varargout = cell(size(varargin));
    for i = 1:length(varargin)
        varargout{i}=varargin{i}(xMin:xMax,yMin:yMax,zMin:zMax);
    end
    pad = [xMin-1, sz(1)-xMax, yMin-1, sz(2)-yMax, zMin-1, sz(3)-zMax];
end

