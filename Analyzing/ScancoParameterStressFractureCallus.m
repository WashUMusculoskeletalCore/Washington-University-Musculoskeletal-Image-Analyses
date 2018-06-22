function [hObject,eventdata,handles] = ScancoParameterStressFractureCallus(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    [out, outHeader] = scancoParameterCalculatorStressFractureCallus(handles.bwContour,handles.lowerThreshold,handles.img,handles.info);
    if exist(fullfile(handles.pathstr,'StressFractureCallusResults.txt'),'file') ~= 2
        fid = fopen(fullfile(handles.pathstr,'StressFractureCallusResults.txt'),'a');
        for i = 1:length(outHeader)
            if i == length(outHeader)
                fprintf(fid,'%s\n',outHeader{i});
            else
                fprintf(fid,'%s\t',outHeader{i});
            end
        end
    end
    fid = fopen(fullfile(handles.pathstr,'StressFractureCallusResults.txt'),'a');
    fprintf(fid,'%s\t',handles.pathstr);
    fprintf(fid,'%s\t',datestr(now));
    for i = 1:length(out)
        if i == length(out)
            fprintf(fid,'%s\n',num2str(out{i}));
        else
            fprintf(fid,'%s\t',num2str(out{i}));
        end
    end
    for i = 1:5
        try
            fclose(fid);
        catch
        end
    end
    guidata(hObject, handles);
    set(handles.textBusy,'String','Not Busy')
catch
    set(handles.textBusy,'String','Failed');
end