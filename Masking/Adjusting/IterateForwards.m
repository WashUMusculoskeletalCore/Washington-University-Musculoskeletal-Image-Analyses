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