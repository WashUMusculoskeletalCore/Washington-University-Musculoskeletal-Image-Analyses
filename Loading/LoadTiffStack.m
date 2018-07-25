function [hObject,eventdata,handles] = LoadTifStack(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    drawnow();
    pathstr = uigetdir(pwd,'Please select the folder containing your stack of TIF (or TIFF) images');
    files = dir(fullfile(pathstr,'*.tif*'));
    [file pth] = uigetfile('*.*', 'Select a DICOM file to use as a template or cancel to continue with dummy metadata');
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
            set(handles.textPercentLoaded,'String',num2str(i/length(files)));
            drawnow();
        end
    elseif length(files) == 1
        iminfo = imfinfo(fullfile(pathstr,files(1).name));
        numImages = numel(iminfo);
        for i = 1:numImages
            handles.img(:,:,i) = imread(fullfile(pathstr,files(1).name),i);
            set(handles.textPercentLoaded,'String',num2str(i/numImages));
            drawnow();
        end
    end
    handles.img = uint16(handles.img);
    handles.img = handles.img .* (((2^16) - 1)/((2^iminfo(1).BitDepth) - 1 ));
    
    handles.pathstr = pathstr;
    
    
    
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
    
    set(gcf,'menubar','figure');
    set(gcf,'toolbar','figure');
    
    set(handles.textBusy,'String','Not Busy');
    
    guidata(hObject, handles);
    
catch
    set(handles.textBusy,'String','Failed');
end
