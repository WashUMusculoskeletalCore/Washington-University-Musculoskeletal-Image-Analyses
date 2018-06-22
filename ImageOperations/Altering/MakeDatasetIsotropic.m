function [hObject,eventdata,handles] = MakeDatasetIsotropic(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    handles.minVoxelSpacing = min([handles.info.PixelSpacing(1,:),handles.info.SliceThickness]);
    R = makeresampler({'linear','linear','linear'},'fill');
    a = handles.info.PixelSpacing(1) / handles.minVoxelSpacing;
    b = handles.info.PixelSpacing(2) / handles.minVoxelSpacing;
    c = handles.info.SliceThickness / handles.minVoxelSpacing;
    T = maketform('affine',[a 0 0; 0 b 0; 0 0 c; 0 0 0]);
    
    handles.info.PixelSpacing(1,1) = handles.minVoxelSpacing;
    handles.info.PixelSpacing(1,2) = handles.minVoxelSpacing;
    handles.info.SliceThickness = handles.minVoxelSpacing;
    [a1 b1 c1] = size(handles.img);
    
    handles.img = tformarray(handles.img,T,R,[1 2 3],[1 2 3], [round(a1*a) round(b1*b) round(c1*c)],[],0);
    
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
    
    guidata(hObject, handles);
    %
    % R =
    % % %TO WORK ON
    % % %make a resampler object based on which dimensions are different
    % % if a == b && b == c && c == a
    % %     msgbox('Already isotropic voxel size');
    % % elseif a == b && b ~= c && c == a
    % %
    % % elseif a ~= b && b == c
    % %
    % % elseif a ~= b && b ~= c
    % %
    % % end
    % %
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end