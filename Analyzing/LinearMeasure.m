function [hObject,eventdata,handles] = LinearMeasure(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    imDist = imdistline(handles.axesIMG);
    setLabelVisible(imDist,0);
    h1 = msgbox('Close this box to complete linear measurement');
    while ishandle(h1)
        pos = getPosition(imDist);
        pause(0.1);
    end
    
    pix = pdist(pos,'euclidean');
    pixPhys = pix * handles.info.SliceThickness;
    h1 = msgbox(['Number of pixels = ' num2str(pix) ', physical distance is ' num2str(pixPhys)]);
    while ishandle(h1)
        pause(0.01);
    end
    delete(imDist);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end