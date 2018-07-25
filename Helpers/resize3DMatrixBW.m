function [resized] = resize3DMatrixBW(bw,rescaleFactor)

x = rescaleFactor;

T = maketform('affine',[x 0 0; 0 x 0; 0 0 x; 0 0 0;]);
R = makeresampler({'nearest','nearest','nearest'},'fill');
resized = tformarray(bw,T,R,[1 2 3],[1 2 3], round(size(bw)*x),[],0);