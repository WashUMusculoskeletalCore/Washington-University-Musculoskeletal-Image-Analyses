% NAME-IterateBackwards
% DESC- Generates 3d mask matching image object boundary by iteratively using
% existing mask as guide for mask in previous slice
% IN-handles.bwContour: The 3d mask, must have a value for the current slice
% handles.slice: the current slice to start at
% handles.img: the 3d image to be matched, should be continuous
% handles.startStop: a toggle button to start and stop the process
% handles.contourMethod: the contouring method to be used by the algorithm
% handles.smoothFactor: the smooth factor to be used by the algorithm
% handles.contractionBias: the contraction bias to be used by the algorithm
% handles.iterations: The number of iterations to be used by the algorithm
% OUT-handles.bwContour: will be matched
% handles.slice: will move down
% UI: display the new masks
function [hObject, eventdata, handles] = IterateBackwards(hObject, eventdata, handles)

if length(find(handles.bwContour(:,:,handles.slice))) ~= 0
    handles.startStop = get(handles.togglebuttonIterateBackwards,'Value');
    while handles.startStop == 1 && handles.slice > 1
        drawnow();
        % TODO-Move to end of loop? Check what feels more responsive 
        handles.startStop = get(handles.togglebuttonIterateBackwards,'Value');
        if handles.startStop == 0
            break
        end
        guidata(hObject, handles);
        drawnow();
        % Get mask from current slice and image from previous slice
        img = handles.img(:,:,handles.slice-1);
        bw = handles.bwContour(:,:,handles.slice);
        % Apply active contour algorithm to match mask to nearby object
        % boundaries in image
        bw = activecontour(img,bw,...
            handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
        % Apply new mask to previous slice
        handles.bwContour(:,:,handles.slice-1) = bw;
        % Show previous slice and new mask blended
        imshowpair(imadjust(handles.img(:,:,handles.slice-1),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice-1),'blend','Parent',handles.axesIMG);
        colormap(handles.axesIMG,handles.colormap);
        % Move to previous slice and repeat
        impixelinfo(handles.axesIMG);
        handles.slice = handles.slice - 1;
        set(handles.sliderIMG,'Value',handles.slice);
        set(handles.editSliceNumber,'String',num2str(handles.slice));
        drawnow();
        guidata(hObject, handles);
    end
    if handles.slice == 1
        img = handles.img(:,:,1);
        bw = handles.bwContour(:,:,2);
        bw = activecontour(img,bw,...
            handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
        handles.bwContour(:,:,1) = bw;
        imshowpair(imadjust(handles.img(:,:,1),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,1),'blend','Parent',handles.axesIMG);
        colormap(handles.axesIMG,handles.colormap);
        impixelinfo(handles.axesIMG);
        set(handles.sliderIMG,'Value',handles.slice);
        set(handles.editSliceNumber,'String',num2str(handles.slice));
        drawnow();
        
        guidata(hObject, handles);
    end
end