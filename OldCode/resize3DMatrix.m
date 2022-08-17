% TODO-unused
function [resized] = resize3DMatrix(matrix,rescaleFactor)

x = rescaleFactor;

T = maketform('affine',[x 0 0; 0 x 0; 0 0 x; 0 0 0;]);
R = makeresampler({'cubic','cubic','cubic'},'fill');
resized = tformarray(matrix,T,R,[1 2 3],[1 2 3], round(size(matrix)*x),[],0);