% NAME-DistanceMap
% DESC-Creates a distance map show the distance from the mask for every
% point outside the mask. Also replaces the image with the mask, and saves
% the original image
% IN-handles.bwContour: the 3D mask
% handles.img: the 3D image
% OUT-handles.img: the 3D image, set to the map
% handles.imgOrig: saved copy of the original image 
function DistanceMap(hObject, handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'bwContour')
            % Confirm that it is ok to overwrite the saved
            if isfield(handles, 'imgOrig')
                answer = questdlg('There is a saved image. Do you want to overwrite it?', 'Save Image?', 'Overwrite', 'Proceed without saving', 'Cancel', 'Cancel');
                switch answer
                    case 'Overwrite'
                        % Save the current image
                        handles = SaveImage(handles);
                    case 'Proceed without saving'
                        % Do nothing
                    otherwise
                        setStatus(handles, 'Canceled');
                        return;
                end
            else
                % Save the current image
                handles = SaveImage(handles);
            end
            setStatus(handles, 'Creating map');
            % Get the distance map
            bwDist = bwdist(handles.bwContour);
            % Rescale the distance map and replace the original image
            maxDist = max(uint16(bwDist(:)));
            handles.img = uint16(bwDist).*((2^16-1)/maxDist);
            updateImage(hObject, handles);
        else
            noMaskError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end
