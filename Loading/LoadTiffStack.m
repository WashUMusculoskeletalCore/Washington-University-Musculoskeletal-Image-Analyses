function LoadTiffStack(hObject, handles)
    try
        setStatus(handles, 'Busy');
        pathstr = uigetdir(pwd,'Please select the folder containing your stack of TIF (or TIFF) images');
        if isequal(pathstr, 0)
            error('ContouringGUI:InputCanceled', 'File selection canceled')
        end
        files = dir(fullfile(pathstr,'*.tif*'));
        [file, pth] = uigetfile('*.*', 'Select a DICOM file to use as a template or cancel to continue with dummy metadata');
        if file ~= 0
            info = dicominfo(fullfile(pth,file));
        else
            info.SliceThickness = 1;
        end
        handles.info = info;
        
        
        if length(files) > 1
            iminfo = imfinfo(fullfile(pathstr,files(1).name));
            for i = 1:length(files)
                handles.img(:,:,i) = imread(fullfile(pathstr,files(i).name));
                displayPercentLoaded(handles, i/length(files));
            end
        elseif length(files) == 1
            iminfo = imfinfo(fullfile(pathstr,files(1).name));
            numImages = numel(iminfo);
            for i = 1:numImages
                handles.img(:,:,i) = imread(fullfile(pathstr,files(1).name),i);
                displayPercentLoaded(handles, i/numImages);
            end
        end
        handles.img = uint16(handles.img);
        handles.img = handles.img .* (((2^16) - 1)/((2^iminfo(1).BitDepth) - 1 ));
        
        handles.pathstr = pathstr;
        
        cameratoolbar('Show');
        
        handles.startMorph = 1;
        set(handles.editStartMorph, 'String', num2str(handles.startMorph));
    
        handles = abcResize(handles);
        
        set(handles.editScaleImageSize,'String',num2str(handles.imgScale));
         
        set(handles.textCurrentDirectory,'String',handles.pathstr);  
        
        handles = windowResize(handles);
        handles.hOut = 1;
        handles.lOut = 0;
    
        
        set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));        
        updateWindow(hObject, handles);

        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end
