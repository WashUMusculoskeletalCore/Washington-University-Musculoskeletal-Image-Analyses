% NAME-IterateContour
% DESC- Generates 3d mask matching image object boundary by iteratively using
% existing mask as guide for mask in next slice
% IN-direction: positive for forwards, negative for backwards
% handles.bwContour: The 3d mask, must have a value for the current slice
% handles.slice: the current slice to start at
% handles.img: the 3d image to be matched, should be continuous
% handles.startStop: a toggle button to start and stop the process
% handles.contourMethod: the contouring method to be used by the algorithm
% handles.smoothFactor: the smooth factor to be used by the algorithm
% handles.contractionBias: the contraction bias to be used by the algorithm
% handles.iterations: The number of iterations to be used by the algorithm
% OUT-handles.bwContour: will be matched
% handles.slice: will move in dirrection of iteration
% UI: display the new masks
% TODO-test and replace
function handles = IterateContour(handles, hObject)
% set direction based on calling object
disp(hObject);
if strcmp(hObject.String, 'Iterate Forwards')
    direction = 1;
elseif strcmp(hObject.String, 'Iterate Backwards')
    direction = -1;
else
    return;
end
% TODO-potential concurrency issues when switching directions, add lock
if ~isempty(find(handles.bwContour(:,:,handles.slice), 1))
    handles.startStop = hObject.Value;
    while handles.startStop == 1 &&  (handles.slice + direction >= 1) && (handles.slice+direction <= handles.abc(3))
        drawnow();
        % TODO-Move to end of loop? Check what feels more responsive 
        handles.startStop = hObject.Value;
        if handles.startStop == 0
            break
        end
        guidata(hObject, handles);
        drawnow();
        % Get mask from current slice and image from previous slice
        img = handles.img(:,:,handles.slice+direction);
        bw = handles.bwContour(:,:,handles.slice);
        % Apply active contour algorithm to match mask to nearby object
        % boundaries in image
        bw = activecontour(img,bw,...
            handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
        % Apply new mask to next slice
        handles.bwContour(:,:,handles.slice+direction) = bw;
        % Show next slice and new mask blended
        imshowpair(imadjust(handles.img(:,:,handles.slice+direction),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice+direction),'blend','Parent',handles.axesIMG);
        colormap(handles.axesIMG,handles.colormap);
        % Move to next slice and repeat
        impixelinfo(handles.axesIMG);
        handles.slice = handles.slice + direction;
        set(handles.sliderIMG,'Value',handles.slice);
        set(handles.editSliceNumber,'String',num2str(handles.slice));
        drawnow();
        guidata(hObject, handles);
    end
    if handles.slice == 1 || handles.slice == handles.abc(3)
        img = handles.img(:,:,handles.slice);
        bw = handles.bwContour(:,:,handles.slice-direction);
        bw = activecontour(img,bw,...
            handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
        handles.bwContour(:,:,handles.slice) = bw;
        imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
        colormap(handles.axesIMG,handles.colormap);
        impixelinfo(handles.axesIMG);
        set(handles.sliderIMG,'Value',handles.slice);
        set(handles.editSliceNumber,'String',num2str(handles.slice));
        hObject.Value=0;
        drawnow();
        
        guidata(hObject, handles);
    end
end