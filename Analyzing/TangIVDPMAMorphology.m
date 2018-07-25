function [hObject,eventdata,handles] = TangIVDPMAMorphology(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    %     bw = handles.img > handles.lowerThreshold;
    %     bw(find(handles.img > handles.upperThreshold)) = 0;
    %     bw = imopen(bw,true(3,3,3));
    %     bw = imclose(bw,true(4,4,4));
    
    %now set up to input two masks, af and total
    
    answer = inputdlg('Please type in the name of the mask representing the NP');
    handles.bwNP = eval(['handles.' answer{1}]);
    answer = inputdlg('Please type in the name of the mask representing the complete disc');
    handles.bwTotal = eval(['handles.' answer{1}]);
    handles.bwAF = handles.bwTotal(~handles.bwNP);
    
    meanTotal = mean(handles.img(handles.bwTotal));
    meanAF = mean(handles.img(handles.bwAF));
    meanNP = mean(handles.img(handles.bwNP));
    
    afVolume = length(find(handles.bwAF)) * handles.info.SliceThickness^3;
    totalVolume = length(find(handles.bwTotal)) * handles.info.SliceThickness^3;
    npVolume = totalVolume - afVolume;
    
    answer = inputdlg('Do you want to generate a picture? y or n');
    if strcmpi(answer{1},'y')
        shp = shpFromBW(handles.bwTotal,3);
        figure;
        plot(shp,'FaceColor','b','LineStyle','none','FaceAlpha',0.3);
        hold on;
        shp = shpFromBW(handles.bwNP,3);
        plot(shp,'FaceColor','r','LineStyle','none');
        camlight();
        saveas(gcf,fullfile(handles.pathstr,'Disc.fig'));
    end
    
    fid = fopen(fullfile(handles.pathstr,'TangIVDPMAResults.txt'),'a');
    fprintf(fid,'%s\t','Date Analysis Performed');
    fprintf(fid,'%s\t','DICOM Path');
    fprintf(fid,'%s\t','Total Volume (mm^3)');
    fprintf(fid,'%s\t','AF Volume (mm^3)');
    fprintf(fid,'%s\t','NP Volume (mm^3)');
    fprintf(fid,'%s\t','Lower Threshold');
    fprintf(fid,'%s\t','Upper Threshold');
    fprintf(fid,'%s\t','Mean Total');
    fprintf(fid,'%s\t','Mean AF');
    fprintf(fid,'%s\n','Mean NP');
    
    fprintf(fid,'%s\t',datestr(now));
    fprintf(fid,'%s\t',handles.pathstr);
    fprintf(fid,'%s\t',num2str(totalVolume));
    fprintf(fid,'%s\t',num2str(afVolume));
    fprintf(fid,'%s\t',num2str(npVolume));
    fprintf(fid,'%s\t',num2str(handles.lowerThreshold));
    fprintf(fid,'%s\t',num2str(handles.upperThreshold));
    fprintf(fid,'%s\t',num2str(meanTotal));
    fprintf(fid,'%s\t',num2str(meanAF));
    fprintf(fid,'%s\n',num2str(meanNP));
    fclose(fid);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end
