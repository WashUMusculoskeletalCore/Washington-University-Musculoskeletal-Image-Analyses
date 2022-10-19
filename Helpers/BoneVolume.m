% NAME-BoneVolume
% DESC-Calculates volumes of two masks and the ratio between them
% IN-boneMask: The binary mask representing the bone
% totalMask: The binary mask representing the total area
% pixelSize: The size of each pixel in physical units
% OUT-BV: The bone volume
% TV: The total volume
% BVTV: The fraction of the total volume that is bone
function [BV,TV,BVTV] = BoneVolume(boneMask,totalMask,pixelSize)
    % Find bone volume
    BV = nnz(boneMask) * pixelSize^3;
    % Find total volume
    TV = nnz(totalMask) * pixelSize^3;
    % Find bone volume ratio
    BVTV = BV/TV;
end

