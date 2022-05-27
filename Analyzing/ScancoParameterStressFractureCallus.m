function [hObject,eventdata,handles] = ScancoParameterStressFractureCallus(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    [out, outHeader] = scancoParameterCalculatorStressFractureCallus(handles.bwContour,handles.lowerThreshold,handles.img,handles.info);
    if exist(fullfile(handles.pathstr,'StressFractureCallusResults.txt'),'file') ~= 2 % If this does not exist as a file
        fid = fopen(fullfile(handles.pathstr,'StressFractureCallusResults.txt'),'a'); % Create the file
         % Print each part of header
        for i = 1:length(outHeader)
            if i == length(outHeader)
                fprintf(fid,'%s\n',outHeader{i}); % For final part of header add an endline
            else
                fprintf(fid,'%s\t',outHeader{i});
            end
        end
    end
    fid = fopen(fullfile(handles.pathstr,'StressFractureCallusResults.txt'),'a');
    % Print path and date
    fprintf(fid,'%s\t',handles.pathstr);
    fprintf(fid,'%s\t',datestr(now));
    % Print output
    for i = 1:length(out)
        if i == length(out)
            fprintf(fid,'%s\n',num2str(out{i})); % For final output add endline
        else
            fprintf(fid,'%s\t',num2str(out{i}));
        end
    end
    % Try to close 5 times
    % TODO- find out why 5 times are needed
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