% NAME-IterateContour
% DESC- Generates 3d mask matching image object boundary by iteratively using
% existing mask as guide for mask in next slice
% IN-direction: positive for forwards, negative for backwards
% handles.bwContour: The 3d mask, must have a value for the current slice
% handles.slice: the current slice to start at
% handles.img: the 3d image to be matched, should be continuous
% handles.contourMethod: the contouring method to be used by the algorithm
% handles.smoothFactor: the smooth factor to be used by the algorithm
% handles.contractionBias: the contraction bias to be used by the algorithm
% handles.iterations: The number of iterations to be used by the algorithm
% OUT-handles.bwContour: will be matched
% handles.slice: will move in dirrection of iteration
% UI: display the new masks
function handles = IterateContour(hObject, handles)
    % If this was started as an interupt, allow interupted process to finish
    drawnow;
    if isfield(handles, 'bwContour')
        % set direction based on calling object
        if strcmp(hObject.String, 'Iterate Forwards')
            setStatus(handles, 'Iterating Forwards');
            direction = 1;
        elseif strcmp(hObject.String, 'Iterate Backwards')
            setStatus(handles, 'Iterating Backwards');
            direction = -1;
        else
            return;
        end
        if ~isempty(find(handles.bwContour(:,:,handles.slice), 1))
            startStop = hObject.Value;
            while startStop == 1 &&  (handles.slice + direction >= 1) && (handles.slice+direction <= handles.abc(3))
                % Get mask from current slice and image from previous slice
                img = handles.img(:,:,handles.slice+direction);
                bw = handles.bwContour(:,:,handles.slice);
                % Apply active contour algorithm to match mask to nearby object
                % boundaries in image
                bw = activecontour(img,bw,...
                    handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);

                % Apply new mask to next slice
                handles.bwContour(:,:,handles.slice+direction) = bw;
                % Move to next slice and repeat
                handles.slice = handles.slice + direction;
                set(handles.sliderIMG,'Value',handles.slice);
                set(handles.editSliceNumber,'String',num2str(handles.slice));
                % Show next slice and new mask blended
                updateContour(hObject, handles);
                % Allow another callback to interupt 
                drawnow;
                % Check if stop is needed
                startStop = hObject.Value;
                if ~any(bw)
                    startStop = 0;
                end
            end                      
        end
        hObject.Value = 0;  
        setStatus(handles,'Not Busy');
    else
        hObject.Value = 0;
        noMaskError();
    end