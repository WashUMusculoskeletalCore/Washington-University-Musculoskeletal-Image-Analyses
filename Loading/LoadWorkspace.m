function [hObject,eventdata,handles] = LoadWorkspace(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    if isfield(handles,'pathstr')
        [file pathstr] = uigetfile(handles.pathstr,'Select the workspace file to load');
    else
        [file pathstr] = uigetfile(pwd,'Select the workspace file to load');
    end
    s = load(fullfile(pathstr,file));
    try
        s = rmfield(s,'axesIMG');
        s = rmfield(s,'output');
        s = rmfield(s,'sliderIMG');
    catch
    end
    fieldNames = fieldnames(s);
    fieldNum = numel(fieldnames(s));
    for i = 1:fieldNum
        eval(['handles.' fieldNames{i} '= s.' fieldNames{i} ';']);
    end
    %re-initialize sliders
    set(handles.textCurrentDirectory,'String',handles.pathstr);
    
    handles.upperThreshold = max(max(max(handles.img)));
    set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
    
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    handles.theMax = double(max(max(max(handles.img))));
    handles.hOut = 1;%handles.theMax / 2^15;
    handles.lOut = 0;
    set(handles.sliderThreshold,'Value',1);
    set(handles.sliderThreshold,'min',1);
    set(handles.sliderThreshold,'max',handles.theMax);
    set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowWidth,'Value',1);
    set(handles.sliderWindowWidth,'min',1);
    set(handles.sliderWindowWidth,'max',handles.theMax);
    set(handles.sliderWindowWidth,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowLocation,'Value',1);
    set(handles.sliderWindowLocation,'min',1);
    set(handles.sliderWindowLocation,'max',handles.theMax);
    set(handles.sliderWindowLocation,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    % imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
    set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
    updateImage(hObject,eventdata,handles);
    
    set(gcf,'menubar','figure');
    set(gcf,'toolbar','figure');
    
    handles.slice = 1;
    guidata(hObject, handles);
    set(handles.textBusy,'String','Not Busy');
    updateImage(hObject,eventdata,handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end