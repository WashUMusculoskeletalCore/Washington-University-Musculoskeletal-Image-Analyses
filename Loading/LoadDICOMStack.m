% NAME-LoadDICOMStack
% DESC-loads the image from a stack of DICOM files
% IN-UI: loads files selected by user
% OUT-handles.img: the image loaded from the files
function [hObject, eventdata, handles] = LoadDICOMStack(hObject, eventdata, handles)
    try
        setStatus(hObject, handles, 'Busy');
        if isfield(handles,'img') == 1
            handles.img = [];
            guidata(hObject, handles);
            drawnow();
        end
        if isfield(handles,'bwContour') == 1
            clear handles.bwContour;handles=rmfield(handles,'bwContour');
        end
        % Open UI prompt to get directory
        handles.pathstr = uigetdir(pwd,'Please select the folder containing your DICOM files');
        % Get all files in directory containing .dcm
        handles.files = dir(fullfile(handles.pathstr, '*.dcm*'));
        %     mrFlag = 0;
        % If there are no dcm files found, get all files starting with IM
        if isempty(handles.files)
            handles.files = dir(fullfile(handles.pathstr, 'IM*'));
            %         mrFlag = 1;
        end
        handles.info = dicominfo(fullfile(handles.pathstr,handles.files(1).name));
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

        handles.img = zeros(handles.info.Height, handles.info.Width, length(handles.files), 'uint16');

        % Convert each file to an image slice
        for i = 1:length(handles.files)
            displayPercentLoaded(hObject, handles, i/length(handles.files));
            handles.img(:,:,i) = dicomread(fullfile(handles.pathstr,handles.files(i).name));
        end

        % Convert pixels from bit depth of 8 to 16
        if isfield(handles.info,'LargestImagePixelValue') == 1
            if handles.info.LargestImagePixelValue == 255
                handles.img = uint16((double(handles.img) ./ 255) .* (2^16-1));
                handles.info.LargestImagePixelValue = 2^16-1;
                handles.info.BitDepth = 16;
            end
        end

        cameratoolbar('Show');
        handles.dataMax = max(max(max(handles.img)));
        
        handles.startMorph = 1;
        set(handles.editStartMorph, 'String', num2str(handles.startMorph));
        
        [hObject, handles] = abcResize(hObject, handles);
        handles = windowResize(handles);

        set(handles.editScaleImageSize,'String',num2str(handles.imgScale));

        % handles.bwContour = false(size(handles.img));
        % handles.bwContourOrig =  handles.bwContour;

        set(handles.textCurrentDirectory,'String',handles.pathstr);

        handles.lowerThreshold = 1;
        set(handles.textLowerThreshold,'String',num2str(handles.lowerThreshold));
        
        handles.upperThreshold = max(max(max(handles.img)));
        set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));

        handles.hOut = 1;
        handles.lOut = 0;

        % imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
        set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
        updateImage(hObject,eventdata,handles);

        set(gcf,'menubar','none');
        set(gcf,'toolbar','none');
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        disp(err.message);
    end