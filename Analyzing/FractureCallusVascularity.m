function [hObject,eventdata,handles] = FractureCallusVascularity(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    [handles.outCallus,handles.outHeaderCallus] = scancoParameterCalculatorCancellousCallus(handles.img > handles.threshold,handles.bwContour,handles.img,handles.info);
    
    handles.outHeaderCallus{14} = 'Slices';
    handles.outHeaderCallus{15} = 'Threshold';
    handles.outHeaderCallus{16} = 'Median Filter Radius';
    
    nums1 = 1;%handles.emptyRanges{1};
    [a b c] = size(handles.img);
    nums2 = c;%handles.emptyRanges{end};
    handles.outCallus{14} = [nums1,nums2];
    handles.outCallus{15} = handles.threshold;
    handles.outCallus{16} = handles.radius;
    
    fid = fopen(fullfile(handles.pathstr,'CallusResults.txt'),'a');
    %     if exist([handles.pathstr '\CallusResults.txt']) ~= 2
    for i = 1:length(handles.outCallus)
        if i == length(handles.outCallus)
            fprintf(fid,'%s\n',handles.outHeaderCallus{i});
        else
            fprintf(fid,'%s\t',handles.outHeaderCallus{i});
        end
    end
    %     end
    for i = 1:length(handles.outCallus)
        if i == length(handles.outCallus)
            fprintf(fid,'%s\n',num2str(handles.outCallus{i}));
        else
            fprintf(fid,'%s\t',num2str(handles.outCallus{i}));
        end
    end
    fclose(fid);
    guidata(hObject, handles);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end