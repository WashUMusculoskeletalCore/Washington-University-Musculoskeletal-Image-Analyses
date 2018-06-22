function [hObject, eventdata, handles] = LoadDICOMStack(hObject, eventdata, handles)

try
    set(handles.textBusy,'String','Busy');
    if isfield(handles,'img') == 1
        handles.img = [];
        guidata(hObject, handles);
        drawnow();
    end
    if isfield(handles,'bwContour') == 1
        clear handles.bwContour;handles=rmfield(handles,'bwContour');
    end
    
    handles.pathstr = uigetdir(pwd,'Please select the folder containing your DICOM files');
    
    handles.files = dir(fullfile(handles.pathstr, '*.dcm*'));
    %     mrFlag = 0;
    if isempty(handles.files)
        handles.files = dir(fullfile(handles.pathstr, 'IM*'));
        %         mrFlag = 1;
    end
    handles.info = dicominfo(fullfile(handles.pathstr,handles.files(1).name));
    
    if ~isfield(handles.info,'Manufacturer')
        handles.info.Manufacturer = 'ZEISS';
    end
    
    if ~isfield(handles.info,'Private_0029_1004') && ~isempty(strfind(handles.info.Manufacturer,'SCANCO'))
        handles.info.Private_0029_1004 = str2num(handles.info.ReferringPhysicianName.FamilyName);
        handles.info.Private_0029_1005 = str2num(handles.info.ReferringPhysicianName.GivenName);
        handles.info.Private_0029_1000 = str2num(handles.info.ReferringPhysicianName.MiddleName);
        handles.info.Private_0029_1006 = str2num(handles.info.ReferringPhysicianName.NamePrefix);
    end
    
    if ~isfield(handles.info,'SliceThickness')
        handles.info.SliceThickness = handles.info.PixelSpacing(1);
    end
    
    handles.img = zeros(handles.info.Height,handles.info.Width,length(handles.files),'uint16');
    
    for i = 1:length(handles.files)
        set(handles.textPercentLoaded,'String',num2str(i/length(handles.files)));
        drawnow();
        %         if mrFlag == 1
        infotmp(i) = dicominfo(fullfile(handles.pathstr,handles.files(i).name));
        locTmp1(i) = infotmp(i).ImagePositionPatient(1);
        locTmp2(i) = infotmp(i).ImagePositionPatient(2);
        locTmp3(i) = infotmp(i).ImagePositionPatient(3);
        %         end
        handles.img(:,:,i) = dicomread(fullfile(handles.pathstr,handles.files(i).name));
    end
    dif1 = diff(locTmp1);
    dif2 = diff(locTmp2);
    dif3 = diff(locTmp3);
    test1 = length(find(dif1));
    test2 = length(find(dif2));
    test3 = length(find(dif3));
    %     if mrFlag == 1
    if test1 > test2 && test1 > test3
        [order I] = sort(locTmp1);
        handles.img = handles.img(:,:,I);
    elseif test2 > test1 && test2 > test3
        [order I] = sort(locTmp2);
        handles.img = handles.img(:,:,I);
    elseif test3 > test1 && test3 > test2
        [order I] = sort(locTmp3);
        handles.img = handles.img(:,:,I);
    end
    
    if isfield(handles.info,'LargestImagePixelValue') == 1
        if handles.info.LargestImagePixelValue == 255
            handles.img = uint16((double(handles.img) ./ 255) .* 2^16);
            handles.info.LargestImagePixelValue = 2^16;
            handles.info.BitDepth = 15;
        end
    end
    
    cameratoolbar('Show');
    handles.dataMax = max(max(max(handles.img)));
    
    handles.windowWidth = max(max(max(handles.img))) - min(min(min(handles.img)));
    set(handles.editWindowWidth,'String',num2str(handles.windowWidth));
    
    
    
    handles.abc = size(handles.img);
    
    handles.windowLocation = round(handles.windowWidth / 2);
    set(handles.editWindowLocation,'String',num2str(handles.windowLocation));
    
    set(handles.editScaleImageSize,'String',num2str(handles.imgScale));
    
    handles.primitiveCenter(1) = round(handles.abc(2)/2);
    handles.primitiveCenter(2) = round(handles.abc(1)/2);
    % handles.bwContour = false(size(handles.img));
    % handles.bwContourOrig = handles.bwContour;
    
    set(handles.textCurrentDirectory,'String',handles.pathstr);
    
    handles.upperThreshold = max(max(max(handles.img)));
    set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
    
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    handles.theMax = double(max(max(max(handles.img))));
    handles.hOut = 1;%handles.theMax / 2^15;
    handles.lOut = 0;
    set(handles.sliderThreshold,'Value',1);
    set(handles.sliderThreshold,'min',1);
    set(handles.sliderThreshold,'max',handles.theMax);
    set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowWidth,'Value',1);
    set(handles.sliderWindowWidth,'min',1);
    set(handles.sliderWindowWidth,'max',handles.theMax);
    set(handles.sliderWindowWidth,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowLocation,'Value',1);
    set(handles.sliderWindowLocation,'min',1);
    set(handles.sliderWindowLocation,'max',handles.theMax);
    set(handles.sliderWindowLocation,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    % imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
    set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
    UpdateImage(hObject,eventdata,handles);
    
    set(gcf,'menubar','figure');
    set(gcf,'toolbar','figure');
    set(handles.textBusy,'String','Not Busy');
    
    guidata(hObject, handles);
catch
    set(handles.textBusy,'String','Failed');
end