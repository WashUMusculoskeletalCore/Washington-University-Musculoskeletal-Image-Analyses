% NAME-MakeDatasetIsotropic
% DESC-Makes a non-isotropic image isotropic. (All pixels are the same size
% in all dimensions.)
% IN-handle.img: The 3D image
% handles.bwContour: The 3D mask
% handles.info.PixelSpacing: The size of a pixel in each dimension
% handles.info.SliceThickness: The size of a pixel in the z dimension
% OUT-handle.img: The 3D image
% handles.bwContour: The 3D mask
% handles.info.PixelSpacing: The size of a pixel in each dimension
% handles.info.SliceThickness: The size of a pixel in the z dimension
% handles.textVoxelSize: The displayed voxel size
function MakeDatasetIsotropic(hObject,handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'img')
            % Find the smallest pixel spacing in any dimension
            minVoxelSpacing = min([handles.info.PixelSpacing(1,:),handles.info.SliceThickness]);
            % Create a transformation to make all pixel spacings match the smallest
            a = handles.info.PixelSpacing(1) / minVoxelSpacing;
            b = handles.info.PixelSpacing(2) / minVoxelSpacing;
            c = handles.info.SliceThickness / minVoxelSpacing;
            T = affine3d([a 0 0 0; 0 b 0 0; 0 0 c 0; 0 0 0 1]);
            % Set all pixel spacings to the minimum
            handles.info.PixelSpacing(1) = minVoxelSpacing;
            handles.info.PixelSpacing(2) = minVoxelSpacing;
            handles.info.SliceThickness = minVoxelSpacing;
            % Apply the transformation
            handles.img = imwarp(handles.img, T, "linear");

            handles = abcResize(handles);
   
            set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));

            if isfield(handles, 'bwContour')
                handles.bwContour = imwarp(handles.bwContour, T, "linear");
                updateContour(hObject, handles);
            else
                updateImage(hObject, handles);
            end
        else
            noImgError;
        end
        setStatus(handles, 'Not Busy');
     
    catch err
        reportError(err, handles);
    end