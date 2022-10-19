% NAME-readDICOMStack
% DESC-Loads a DICOM file
% IN-pathstr: The filepath to load fro,
% OUT-img: The loaded image
% info: The DICOM info struct
function [img, info] = readDICOMStack(pathstr)
    if pathstr == 0
        error('ContouringGUI:InputCanceled', 'Folder selection canceled');
    end
    files = dir([pathstr '\*.dcm*']);
    if isempty(files)
        error('ContouringGUI:InputError', 'No DICOMs in selected folder');
    end
    info = dicominfo([pathstr '\' files(1).name]);
    
    try
        % Read the full stack
        tmp = dicomreadVolume(pathstr);
        img=squeeze(tmp(:,:,1,:));
        clear tmp;
    catch
        % Convert each file to an image slice
        img = zeros(info.Height, info.Width, length(files), 'uint16');
        l = length(files);
        for i = 1:l
            img(:,:,i) = dicomread(fullfile(pathstr,files(i).name));
        end
    end