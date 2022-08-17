function [hObject,eventdata,handles] = MakeDatasetIsotropic(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        % Find the smallest pixel spacing in any dimension
        handles.minVoxelSpacing = min([handles.info.PixelSpacing(1,:),handles.info.SliceThickness]);
        R = makeresampler({'linear','linear','linear'},'fill');
        % Create a transformation to make all pixel spacings match the smallest
        a = handles.info.PixelSpacing(1) / handles.minVoxelSpacing;
        b = handles.info.PixelSpacing(2) / handles.minVoxelSpacing;
        c = handles.info.SliceThickness / handles.minVoxelSpacing;
        T = affine3d([a 0 0; 0 b 0; 0 0 c; 0 0 0]);
        % Set all pixel spacings to the minimum
        handles.info.PixelSpacing(1,1) = handles.minVoxelSpacing;
        handles.info.PixelSpacing(1,2) = handles.minVoxelSpacing;
        handles.info.SliceThickness = handles.minVoxelSpacing;
        [a1, b1, c1] = size(handles.img);
        % Apply the transformation
        handles.img = tformarray(handles.img,T,R,[1 2 3],[1 2 3], [round(a1*a) round(b1*b) round(c1*c)],[],0);

        handles.dataMax = max(max(max(handles.img)));
        [hObject, handles] = abcResize(hObject, handles)

        set(handles.editScaleImageSize,'String',num2str(handles.imgScale));

        % handles.bwContour = false(size(handles.img));
        % handles.bwContourOrig = handles.bwContour;

        set(handles.textCurrentDirectory,'String',handles.pathstr);
        

        handles.hOut = 1;%handles.theMax / 2^15;
        handles.lOut = 0;

        handles = windowResize(handles);
        
        % imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
        set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
        updateImage(hObject,eventdata,handles);

        set(gcf,'menubar','none');
        set(gcf,'toolbar','none');

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
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end