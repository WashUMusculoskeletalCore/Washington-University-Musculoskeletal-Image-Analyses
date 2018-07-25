function [img info] = readDICOMStack(pathstr)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Reads in a DICOM stack along with the info struct for the first file. Use
%%it! It's faster!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

files = dir([pathstr '\*.dcm*']);

info = dicominfo([pathstr '\' files(1).name]);

% img = uint16(zeros(info.Height,info.Width,length(files)));

for i = 1:length(files)
    clc
    i/length(files)
    img(:,:,i) = dicomread([pathstr '\' files(i).name]);
end