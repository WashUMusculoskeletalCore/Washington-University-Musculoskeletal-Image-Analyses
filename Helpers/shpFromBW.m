% NAME-shpFromBW
% DESC-Creates a 3D bounding shape from a 3D black and white image
% IN-bw:The black and white image
% radius: the alpha radius of the shape
% OUT-sph: the 3D shape
function [shp] = shpFromBW(bw, radius)
    [X, Y ,Z] = ind2sub(size(bw),find(bw));
    shp = alphaShape([X, Y, Z], radius);