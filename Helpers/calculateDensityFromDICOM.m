% NAME-calculateDensityFromDICOM
% DESC-Converts a greyscale matrix into a density matrix using both
% mgHA/ccm and Hounsfield units
% IN-info: The DICOM information struct
% matrix: the greyscale matrix
% OUT-densityMatrixmgHACCM: the density matrix in miligrams of Hydroxyapatite per cubic centimeter
% densityMatrixHU: the density matrix in hounsfield units

function [densityMatrixmgHACCM, densityMatrixHU] = calculateDensityFromDICOM(info, matrix)
    % Get the parameters from DICOM info
    slope = info.Private_0029_1004; % Conversion rate slope for mgha/ccm
    intercept = info.Private_0029_1005; % Slope intercept
    scale = info.Private_0029_1000; % u-scaling
    water = info.Private_0029_1006; % Density of water
    % Miligrams of Hydroxyapatite per cubic centimeter
    densityMatrixmgHACCM = int16(double(matrix) ./ scale .* slope + intercept);
    % Hounsfield Units
    densityMatrixHU = int16(-1000 + double(matrix) ./ scale .* 1000 ./ water);