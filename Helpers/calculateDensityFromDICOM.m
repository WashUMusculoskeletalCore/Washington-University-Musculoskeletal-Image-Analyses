function [densityMatrixmgHACCM densityMatrixHU] = calculateDensityFromDICOM(info,matrix)

%This function takes in a single info struct from dicominfo and an n x m x
%3 matrix of 16 bit grayscale values and returns either just the density in
%mgHA/ccm or also in HU

% Hi Dan
% 
% I just had this question a couple of times in the last week... so here how it goes:
% 
% You would have to use the DICOM grey scale value to convert into density. Our scale is a 16bit signed value, thus values from -32768 to 32767  (15bit high value). In the DICOM header you have all information to convert:
% 
% (unfortunately there is no title of the record you need)
% 0029,0010  ---: SCANCO calibration
% 0029,0011  ---: SCANCO statistics 
% 0029,1000  ---: 4096   -->  u-scaling
% 0029,1001  ---: 70 kVp, 200mg HA wedge, 4096 scaling
% 0029,1002  ---: 2 (Density) 
% 0029,1003  ---: mg HA/ccm 
% 0029,1004  ---:  4.11363007e+02  --> slope
% 0029,1005  ---: -2.28070007e+02  --> intercept
% 0029,1006  ---: 0.50560          -->  u of water
% 
% 
% Then: 
% 
% density [mg HA/ccm]= (greyscale/scaling) * slope + intercept
% BTW: greyscale/scaling  =  linear attenuation coefficient u
% 
% density  [HU] = -1000 + (greyscale/scaling) * 1000 / uWater.

% matrix2 = double(matrix);
% clear matrix
slope = info.Private_0029_1004;
intercept = info.Private_0029_1005;
scale = info.Private_0029_1000;
water = info.Private_0029_1006;

[a b c] = size(matrix);
densityMatrixmgHACCM = zeros(size(matrix),'uint16');
for i = 1:c
    clc
    i/c
    densityMatrixmgHACCM(:,:,i) = uint16(single(matrix(:,:,i)) ./ scale .* slope + intercept);
end
% densityMatrixmgHACCM(find(densityMatrixmgHACCM < 0)) = 0;

densityMatrixHU=zeros(size(matrix),'uint16');
for i = 1:c
    clc
    i/c
    densityMatrixHU(:,:,i) = uint16(-1000 + double(matrix(:,:,i)) ./ scale .* 1000 ./ water);
end