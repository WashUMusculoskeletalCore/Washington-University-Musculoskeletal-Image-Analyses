function [hObject, eventdata, handles] = IterateBackwards(hObject, eventdata, handles)

if length(find(handles.bwContour(:,:,handles.slice))) ~= 0
    handles.startStop = get(handles.togglebuttonIterateBackwards,'Value');
    while handles.startStop == 1 && handles.slice > 1
        drawnow();
        handles.startStop = get(handles.togglebuttonIterateBackwards,'Value');
        if handles.startStop == 0
            break
        end
        guidata(hObject, handles);
        drawnow();
        img = handles.img(:,:,handles.slice-1);
        bw = handles.bwContour(:,:,handles.slice);
        bw = activecontour(img,bw,...
            handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
        handles.bwContour(:,:,handles.slice-1) = bw;
        imshowpair(imadjust(handles.img(:,:,handles.slice-1),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice-1),'blend','Parent',handles.axesIMG);
        colormap(handles.axesIMG,handles.colormap);
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