function [hObject,eventdata,handles] = SaveWorkspace(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    fieldNames = fieldnames(handles);
    fieldNum = numel(fieldnames(handles));
    matPath = fullfile(handles.pathstr,'Workspace.mat');
    delete(matPath);
    ct=0;
    for i = 134:fieldNum
        if strcmpi(fieldNames{i},'sliderIMG') == 1
        elseif strcmpi(fieldNames{i},'axesIMG') == 1
        elseif strcmpi(fieldNames{i},'output') == 1
        else
            set(handles.textPercentLoaded,'String',num2str(ct/(fieldNum-135)));
            drawnow;
            eval([fieldNames{i} ' = handles.' fieldNames{i} ';']);
            if ct == 0
                save(fullfile(handles.pathstr,'Workspace.mat'),fieldNames{i},'-v7.3','-nocompression');
                ct=ct+1;
            else
                save(fullfile(handles.pathstr,'Workspace.mat'),fieldNames{i},'-append','-nocompression');
                ct=ct+1;
            end
        end
    end
    
    set(handles.textBusy,'String','Not Busy');
    set(handles.textPercentLoaded,'String',num2str(1));
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end