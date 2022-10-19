% NAME-calculateThickness
% DESC-Uses a distance map to find the average thickness and standard
% deviation of a shape
% IN-dm: The distance map
% OUT-meanRad: The average radius of the thickness spheres
% stdRad: The standard deviation of radius of the thickness spheres
function [meanRad,stdRad,dm] = calculateThickness(handles, dm)
    dm = double(dm);
    % Reduces the distance map to a set of nonintersecting spheres
    dm = findSpheres(handles, dm);
    % Find the average and standard deviation for the radius of the spheres
    rads = nonzeros(dm); 
    meanRad = mean(rads);
    stdRad = std(rads);
