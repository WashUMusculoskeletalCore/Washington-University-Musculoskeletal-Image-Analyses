% NAME-interp_shape
% DESC-Uses linear interpolation to calculate a 3D shape connecting two
% slices
% IN-top: A 2D mask of the top slice
% bottom: A 2D mask of the bottom slice
% num: the number of slices between the slices
% OUT-out: the 3D shape between the top and bottom slices s
function out = interp_shape(top,bottom,num)
    if nargin<2
        error('not enough args');
    end
    if nargin<3
        num = 1;
    end
    if ~(num>0 && round(num)== num)
        error('number of slices to be interpolated must be integer >0');
    end

    top = signed_bwdist(top); % see local function below
    bottom = signed_bwdist(bottom);

    r = size(top,1);
    c = size(top,2);
    t = num+2;

    [x, y, z] = ndgrid(1:r,1:c,[1 t]); % existing data
    [xi, yi, zi] = ndgrid(1:r,1:c,1:t); % including new slices

    out = interpn(x,y,z,cat(3,bottom,top),xi,yi,zi); % Get values of middle based off of top and bottom
    out = out(:,:,2:end-1)>=0; % Cut off top and bottom

% NAME-signed_bwdist
% DESC-Gets the distance from the edge for every point, outside points are
% negative
% IN-im: The 3D image
% OUT-im: the distance map
function im = signed_bwdist(im)
    im = -bwdist(bwmorph(im,'remove')).*~im + bwdist(bwmorph(im,'remove')).*im;