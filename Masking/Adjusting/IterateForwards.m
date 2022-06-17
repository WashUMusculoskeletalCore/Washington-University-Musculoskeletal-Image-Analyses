% NAME-IterateForwards
% DESC- Generates 3d mask matching image object boundary by iteratively using
% existing mask as guide for mask in next slice
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
% TODO- merge with IterateBackwards 
function [hObject, eventdata, handles] = IterateForwards(hObject, eventdata, handles)

if length(find(handles.bwContour(:,:,handles.slice))) ~= 0
    handles.startStop = get(handles.togglebuttonIterateForwards,'Value');
    while handles.startStop == 1 && handles.slice < handles.abc(3)
        drawnow();
        handles.startStop = get(handles.togglebuttonIterateForwards,'Value');
        if handles.startStop == 0
            break
        end
        guidata(hObject,handles);
        drawnow();
        handles.bwContour(:,:,handles.slice+1) = activecontour(handles.img(:,:,handles.slice+1),handles.bwContour(:,:,handles.slice),...
            handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
        handles.slice = handles.slice+1;
        guidata(hObject,handles);
        UpdateImage(hObject, eventdata, handles);
        set(handles.sliderIMG,'Value',handles.slice);
        set(handles.editSliceNumber,'String',num2str(handles.slice));
        drawnow();
        %         guidata(hObject,handles);
    end
    if handles.slice == handles.abc(3)
        handles.bwContour(:,:,end) = activecontour(handles.img(:,:,handles.slice),handles.bwContour(:,:,handles.slice-1),...
            handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
        guidata(hObject,handles);
        UpdateImage(hObject, eventdata, handles);
        set(handles.sliderIMG,'Value',handles.slice);
        set(handles.editSliceNumber,'String',num2str(handles.slice));
        drawnow();
        %         guidata(hObject, handles);
    end
end