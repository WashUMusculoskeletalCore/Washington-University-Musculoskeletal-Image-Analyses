function [hObject,eventdata,handles] = HumanCoreTrabecularThickness(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    % Identify area inside thresholds
    bw = false(size(handles.img));
    bw(find(handles.img > handles.lowerThreshold)) = 1;
    bw(find(handles.img > handles.upperThreshold)) = 0;
    bw = bwareaopen(bw,150); % Remove small objects from image

    [handles.outCancellous,handles.outHeaderCancellous] = scancoParameterCalculatorCancellous(bw,handles.bwContour,handles.img,handles.info,get(handles.togglebuttonRobustThickness,'Value'));
    if exist(fullfile(handles.pathstr,'CancellousResults.txt'),'file') ~= 2
        fid = fopen(fullfile(handles.pathstr,'CancellousResults.txt'),'w');
        for i = 1:length(handles.outCancellous)
            if i == length(handles.outCancellous)
                fprintf(fid,'%s\t',handles.outHeaderCancellous{i});

            else
                fprintf(fid,'%s\t',handles.outHeaderCancellous{i});
            end
        end
        fprintf(fid,'%s\n','Threshold');
        fclose(fid);
    end
    for i = 1:length(handles.outCancellous)
        fid = fopen(fullfile(handles.pathstr,'CancellousResults.txt'),'a');
        if i == length(handles.outCancellous)
            fprintf(fid,'%s\t',num2str(handles.outCancellous{i}));
            fprintf(fid,'%s\n',num2str(handles.lowerThreshold));
        else
            fprintf(fid,'%s\t',num2str(handles.outCancellous{i}));
        end
    end
    fclose(fid);
    guidata(hObject, handles);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end