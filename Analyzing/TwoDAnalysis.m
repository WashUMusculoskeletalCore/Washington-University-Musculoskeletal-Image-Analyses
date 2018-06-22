function    [hObject,eventdata,handles] = TwoDAnalysis(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    fid = fopen(fullfile(handles.pathstr,'2DResults.txt'),'a');
    fprintf(fid,'%s\t','Date Analyzed');
    fprintf(fid,'%s\t','Measurement');
    
    fprintf(fid,'%s\t','Area by slice');
    fprintf(fid,'%s\t','Mean Density by Slice');
    fprintf(fid,'%s\t','Standard Deviation of Density by Slice');
    fprintf(fid,'%s\t','Min Density by Slice');
    fprintf(fid,'%s\t','Max Density by Slice');
    
    fprintf(fid,'%s\t','Mean Area');
    fprintf(fid,'%s\t','Standard Deviation of Area');
    fprintf(fid,'%s\t','Min Area');
    fprintf(fid,'%s\t','Max Area');
    fprintf(fid,'%s\t','Mean Density');
    fprintf(fid,'%s\t','Standard Deviation of Density');
    fprintf(fid,'%s\t','Min Density');
    fprintf(fid,'%s\n','Max Density');
    
    fprintf(fid,'%s\t',datestr(now));
    fprintf(fid,'%s\t',handles.pathstr);
    
    handles.imgDensity = calculateDensityFromDICOM(handles.info,handles.img);
    
    [a b c] = size(handles.bwContour);
    for i = 1:c
        set(handles.textPercentLoaded,'String',num2str(i/c));
        drawnow();
        area(i) = bwarea(handles.bwContour(:,:,i)) * handles.info.SliceThickness^2;
        tmp = handles.imgDensity(:,:,i);
        meanIntens(i) = mean(reshape(tmp(handles.bwContour(:,:,i)),[length(find(handles.bwContour(:,:,i))) 1]));
        stdIntens(i) = std(double(reshape(tmp(handles.bwContour(:,:,i)),[length(find(handles.bwContour(:,:,i))) 1])));
        minIntens(i) = min(double(reshape(tmp(handles.bwContour(:,:,i)),[length(find(handles.bwContour(:,:,i))) 1])));
        maxIntens(i) = max(double(reshape(tmp(handles.bwContour(:,:,i)),[length(find(handles.bwContour(:,:,i))) 1])));
    end
    
    meanArea = mean(area);
    minArea = min(area);
    maxArea = max(area);
    stdArea = std(area);
    meanIntensity = mean(handles.imgDensity(handles.bwContour));
    stdIntensity = std(double(handles.imgDensity(handles.bwContour)));
    minIntensity = min(double(handles.imgDensity(handles.bwContour)));
    maxIntensity = max(double(handles.imgDensity(handles.bwContour)));
    
    for i = 1:c
        if i == 1
            fprintf(fid,'%s\t',num2str(area(i)));
            fprintf(fid,'%s\t',num2str(meanIntens(i)));
            fprintf(fid,'%s\t',num2str(stdIntens(i)));
            fprintf(fid,'%s\t',num2str(minIntens(i)));
            fprintf(fid,'%s\t',num2str(maxIntens(i)));
            fprintf(fid,'%s\t',num2str(meanArea));
            fprintf(fid,'%s\t',num2str(stdArea));
            fprintf(fid,'%s\t',num2str(minArea));
            fprintf(fid,'%s\t',num2str(maxArea(i)));
            fprintf(fid,'%s\t',num2str(meanIntensity));
            fprintf(fid,'%s\t',num2str(stdIntensity));
            fprintf(fid,'%s\t',num2str(minIntensity));
            fprintf(fid,'%s\n',num2str(maxIntensity));
        else
            fprintf(fid,'%s\t','');
            fprintf(fid,'%s\t','');
            fprintf(fid,'%s\t',num2str(area(i)));
            fprintf(fid,'%s\t',num2str(meanIntens(i)));
            fprintf(fid,'%s\t',num2str(stdIntens(i)));
            fprintf(fid,'%s\t',num2str(minIntens(i)));
            fprintf(fid,'%s\n',num2str(maxIntens(i)));
        end
    end
    
    fclose(fid);
    
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end
