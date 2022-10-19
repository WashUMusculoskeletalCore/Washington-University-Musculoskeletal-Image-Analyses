% NAME-LoadDICOMStack
% DESC-loads the image from a stack of DICOM files
% IN-UI: loads files selected by user
% OUT-handles.img: the image loaded from the files
% handles.abc: The size of the image
% handles.dataMax: The maximum brigtness value of the image
% handles.dataMin: The minimum brightness value of the image
% handles.pathstr: The filepath used by the application
% handles.info: The information data structure
function LoadDICOMStack(hObject, handles)
    try
        setStatus(handles, 'Busy');
        displayPercentLoaded(handles, 0);
        % Clear the image
        if isfield(handles,'img')
            handles.img = [];
        end
        % Open UI prompt to get directory
        pathstr = uigetdir(pwd,'Please select the folder containing your DICOM files');
        if isequal(pathstr, 0)
            error('ContouringGUI:InputCanceled', 'File selection canceled')
        end
        handles.pathstr = pathstr;
        % Get all files in directory containing .dcm
        files = dir(fullfile(handles.pathstr, '*.dcm*'));
        % If there are no dcm files found, throw an error
        if isempty(files)
            error('ContouringGUI:InputError', 'No DICOMS found');
        end
        handles.info = dicominfo(fullfile(handles.pathstr, files(1).name));
        % Autofill missing info
        % TODO- Use configuration files
        if ~isfield(handles.info,'Manufacturer')
            handles.info.Manufacturer = 'ZEISS';
        end
        % This should not be needed for new files, but removing it might 
        % cause trouble with older files
        if ~isfield(handles.info,'Private_0029_1004') && ~isempty(strfind(handles.info.Manufacturer,'SCANCO'))
            handles.info.Private_0029_1004 = str2double(handles.info.ReferringPhysicianName.FamilyName);
            handles.info.Private_0029_1005 = str2double(handles.info.ReferringPhysicianName.GivenName);
            handles.info.Private_0029_1000 = str2double(handles.info.ReferringPhysicianName.MiddleName);
            handles.info.Private_0029_1006 = str2double(handles.info.ReferringPhysicianName.NamePrefix);
        end

        if ~isfield(handles.info,'SliceThickness')
            handles.info.SliceThickness = handles.info.PixelSpacing(1);
        end
        setStatus(handles, 'Loading Image');
        try
            % Read the full stack
            tmp = dicomreadVolume(handles.pathstr);
            handles.img=squeeze(tmp(:,:,1,:));
            clear tmp;
            displayPercentLoaded(handles, 1);
        catch
            % Convert each file to an image slice
            handles.img = zeros(handles.info.Height, handles.info.Width, length(files), 'uint16');
            l = length(files);
            for i = 1:l
                handles.img(:,:,i) = dicomread(fullfile(handles.pathstr,files(i).name));
                displayPercentLoaded(handles, i/l);
            end
        end      
        setStatus(handles, 'Initializing Data');
        handles.img = uint16(handles.img);
        
        % Convert pixels from bit depth of 8 to 16
        if isfield(handles.info,'LargestImagePixelValue')
            if handles.info.LargestImagePixelValue == 255
                handles.img = uint16((double(handles.img) ./ 255) .* (2^16-1));
                handles.info.LargestImagePixelValue = 2^16-1;
                handles.info.BitDepth = 16;
            end
        end
        
        handles.startMorph = 1;
        set(handles.editStartMorph, 'String', num2str(handles.startMorph));
        
        handles = abcResize(handles);
        handles = windowResize(handles);

        if handles.dataMax > 0 && handles.dataMin < 0
            handles.threshold = 0;
            set(handles.editThreshold,'String',num2str(handles.threshold))
            set(handles.sliderThreshold,'Value',handles.threshold);
        end

        set(handles.textCurrentDirectory,'String',handles.pathstr);


        % imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
        set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
        updateWindow(hObject,handles);
        % Clear the mask if it exists
        if isfield(handles,'bwContour')
            clear handles.bwContour;
            handles=rmfield(handles,'bwContour');
            updateContour(hObject, handles);
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end