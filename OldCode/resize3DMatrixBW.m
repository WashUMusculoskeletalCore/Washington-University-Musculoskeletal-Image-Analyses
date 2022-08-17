% NAME-resize3DMatrixBW
% DESC-resizes a 3D binary matrix
% IN-bw: The 3D binary matrix
% rescaleFactor: The factor to multiply the size by
% OUT-resized: The resized binary matrix
function [resized] = resize3DMatrixBW(bw, rescaleFactor)

    x = rescaleFactor;

    T = maketform('affine',[x 0 0; 0 x 0; 0 0 x; 0 0 0;]); %#ok<MTFA1>
    % Sampler used to fill in gaps when expanding image
    R = makeresampler({'nearest','nearest','nearest'},'fill');
    resized = tformarray(bw,T,R,[1 2 3],[1 2 3], round(size(bw,1,2,3)*x),[],0);