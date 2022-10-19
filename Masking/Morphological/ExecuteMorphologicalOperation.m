% NAME-ExecuteMorphologicalOperation
% DESC-Executes a morphological operation with the chosen options
% IN-handles.morphologicalImageMask: determines whether to perform the
% operation on the image or mask
% handles.morphological2D3D: determines whether to perform the operation on
% the entire 3d shape or slice by slice
% handles.morphologicalOperation: which operation to perform, options are
% close, open, erode, dilate, and fill
% handles.morphologicalRadius: the radius of the structuring element usesd
% by the operation
% OUT-handles.img: the 3D image
% handles.bwContour: the 3D mask
function ExecuteMorphologicalOperation(hObject, handles)
    try
        setStatus(handles, 'Busy');
        switch handles.morphologicalImageMask
            case 'Mask'
                field = 'bwContour';
            case 'Image'
                field = 'img';
        end
        if isfield(handles, field)
            % Determine which structuring element to use
            switch handles.morphological2D3D
                case '2D'
                    se = strel('disk',handles.morphologicalRadius,0);
                case '3D'
                    se = true(handles.morphologicalRadius);
            end

            % Determine which operation to use
            switch handles.morphologicalOperation
                case 'Close'
                    fh = @imclose;
                case 'Open'
                    fh = @imopen;
                case 'Erode'
                    fh = @imerode;
                case 'Dilate'
                    fh = @imdilate;
                case 'Fill'
                    fh = @imfill;
                    se = 'holes';
            end

            % Perform the operation in either 3D or 2D slice by slice
            switch handles.morphological2D3D
                case '2D'
                    [~, ~, c] = size(handles.(field));
                    for i = 1:c
                        handles.(field)(:,:,i) = fh(handles.(field)(:,:,i), se);
                    end
                case '3D'
                    handles.(field) = fh(handles.(field), se);
            end
            if strcmp(field, 'bwContour')
                updateContour(hObject, handles);
            else        
                updateImage(hObject, handles);
            end
        else
            % If the field does not exist, give an error message
            switch handles.morphologicalImageMask
            case 'Mask'
                noMaskError();
            case 'Image'
                noImgError();
            end
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end