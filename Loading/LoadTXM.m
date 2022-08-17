function [hObject,eventdata,handles] = LoadTXM(hObject,eventdata,handles)

try
    setStatus(hObject, handles, 'Busy');

    if isfield(handles,'img') == 1
        clear handles.img;
    end
    if isfield(handles,'bwContour') == 1
        handles = rmfield(handles,'bwContour');
    end
    
    set(handles.editScaleImageSize,'String',num2str(handles.imgScale));
    
    [fName, pName] = uigetfile(fullfile(pwd,'*.txm'),'Please select your TXM file');
    handles.pathstr = [pName fName];
    
    set(handles.textCurrentDirectory,'String',[pName fName]);
    % handles.files = dir([handles.pathstr '\*.txm*']);
    % handles.info = dicominfo([handles.pathstr '\' handles.files(1).name]);
    
    [handles.header, handles.headerShort] = txmheader_read8([handles.pathstr]);
    handles.pathstr = pName;
    handles.info = handles.headerShort;
    handles.info.SliceThickness = handles.info.PixelSize;
    handles.info.SliceThickness = handles.info.SliceThickness / 1000;
    handles.info.Height = handles.info.ImageHeight;%may need to be switched with below
    handles.info.Width = handles.info.ImageWidth;
    handles.info.BitDepth = 16;
    handles.info.Format = 'DICOM';
    handles.info.FileName = handles.info.File;
    handles.info.FileSize = handles.info.Height * handles.info.Width * 2^16;
    handles.info.FormatVersion = 3;
    handles.info.ColorType = 'grayscale';
    handles.info.Modality = 'CT';
    handles.info.Manufacturer = 'Zeiss';
    handles.info.InstitutionName = 'Washington University in St. Louis';
    handles.info.PatientName = fName(1:end-4);
    handles.info.KVP = txmdata_read8(handles.header,'Voltage');
    handles.info.DeviceSerialNumber = '8802030299';
    handles.info.BitsAllocated = 16;
    handles.info.BitsStored = 15;
    handles.info.SliceLocation = 20;
    handles.info.ImagePositionPatient = [0;0;handles.info.SliceLocation];
    handles.info.PixelSpacing = [handles.info.SliceThickness;handles.info.SliceThickness];
    
    
    
    handles.img = zeros([handles.headerShort.ImageWidth handles.headerShort.ImageHeight handles.headerShort.NoOfImages],'uint16');
    
    ct=0;
    for i = 1:handles.headerShort.NoOfImages
        ct=ct+1;
        displayPercentLoaded(hObject, handles, ct/double(handles.headerShort.NoOfImages));
        handles.img(:,:,i) = txmimage_read8(handles.header,ct,0,0);
    end
    
    handles.dataMax = max(max(max(handles.img)));
    cameratoolbar('Show');
    
    handles.info.LargestImagePixelValue = max(max(max(handles.img)));
    handles.info.SmallestImagePixelValue = min(min(min(handles.img)));
    
    handles.startMorph = 1;
    set(handles.editStartMorph, 'String', num2str(handles.startMorph));
    [hObject, handles] = abcResize(hObject, handles);
    handles = windowResize(handles);
    
    handles.colormap = 'gray';
    
    set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
    
    guidata(hObject, handles);
    
    set(gcf,'menubar','none');
    set(gcf,'toolbar','none');
    
    updateImage(hObject, eventdata, handles);
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end