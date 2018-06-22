function [hObject,eventdata,handles] = TangIVDPMANotocordMorphology(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Not Busy');
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
    handles.bwAF = false(size(handles.img));
    handles.bwAF = handles.bwTotal;
    handles.bwAF(handles.bwNP) = 0;
    %     handles.bwAF = bwBiggest(handles.bwAF);
    img = handles.img;
    img(~handles.bwNP) = 0;
    [a b c] = size(img);
    handles.bwNC = img > handles.lowerThreshold;
    
    %clear img;
    
    meanTotal = mean(handles.img(handles.bwTotal));
    meanAF = mean(handles.img(handles.bwAF));
    meanNP = mean(handles.img(handles.bwNP));
    meanNC = mean(handles.img(handles.bwNC));
    
    afVolume = length(find(handles.bwAF)) * handles.info.SliceThickness^3;
    totalVolume = length(find(handles.bwTotal)) * handles.info.SliceThickness^3;
    npVolume = totalVolume - afVolume;
    ncVolume = length(find(handles.bwNC)) * handles.info.SliceThickness^3;
    
    %     afArea = shpFromBW(handles.bwAF,3);
    %     afArea = afArea.surfaceArea * handles.info.SliceThickness^2;
    %     totalArea = shpFromBW(handles.bwTotal,3);
    %     totalArea = totalArea.surfaceArea * handles.info.SliceThickness^2;
    %     npArea = shpFromBW(handles.bwNP,3);
    %     npArea = npArea.surfaceArea * handles.info.SliceThickness^2;
    ncArea = shpFromBW(handles.bwNC,3);
    ncArea = ncArea.surfaceArea * handles.info.SliceThickness^2;
    
    
    answer = inputdlg('Do you want to generate a picture? y or n');
    if strcmpi(answer{1},'y')
        shp = shpFromBW(resize3DMatrixBW(handles.bwTotal,0.5),3);
        figure;
        plot(shp,'FaceColor','b','LineStyle','none','FaceAlpha',0.2);
        hold on;
        shp = shpFromBW(resize3DMatrixBW(handles.bwNP,0.5),3);
        plot(shp,'FaceColor','r','LineStyle','none','FaceAlpha',0.4);
        shp = shpFromBW(resize3DMatrixBW(handles.bwNC,0.5),3);
        plot(shp,'FaceColor','c','LineStyle','none');
        camlight();
        saveas(gcf,fullfile(handles.pathstr,'Disc.fig'));
        %         close all;
    end
    
    fid = fopen(fullfile(handles.pathstr,'TangIVDPMANotochordResults.txt'),'a');
    fprintf(fid,'%s\t','Date Analysis Performed');
    fprintf(fid,'%s\t','DICOM Path');
    fprintf(fid,'%s\t','Total Volume (mm^3)');
    fprintf(fid,'%s\t','AF Volume (mm^3)');
    fprintf(fid,'%s\t','NP Volume (mm^3)');
    fprintf(fid,'%s\t','NC Volume (mm^3)');
    %     fprintf(fid,'%s\t','Total Area (mm^2)');
    %     fprintf(fid,'%s\t','AF Area (mm^2)');
    %     fprintf(fid,'%s\t','NP Area (mm^2)');
    fprintf(fid,'%s\t','NC Area (mm^2)');
    fprintf(fid,'%s\t','Lower Threshold');
    %     fprintf(fid,'%s\t','Upper Threshold');
    fprintf(fid,'%s\t','Mean Total');
    fprintf(fid,'%s\t','Mean AF');
    fprintf(fid,'%s\t','Mean NP');
    fprintf(fid,'%s\n','Mean NC');
    
    fprintf(fid,'%s\t',datestr(now));
    fprintf(fid,'%s\t',handles.pathstr);
    fprintf(fid,'%s\t',num2str(totalVolume));
    fprintf(fid,'%s\t',num2str(afVolume));
    fprintf(fid,'%s\t',num2str(npVolume));
    fprintf(fid,'%s\t',num2str(ncVolume));
    %     fprintf(fid,'%s\t',num2str(totalArea));
    %     fprintf(fid,'%s\t',num2str(afArea));
    %     fprintf(fid,'%s\t',num2str(npArea));
    fprintf(fid,'%s\t',num2str(ncArea));
    fprintf(fid,'%s\t',num2str(handles.lowerThreshold));
    %     fprintf(fid,'%s\t',num2str(handles.upperThreshold));
    fprintf(fid,'%s\t',num2str(meanTotal));
    fprintf(fid,'%s\t',num2str(meanAF));
    fprintf(fid,'%s\t',num2str(meanNP));
    fprintf(fid,'%s\n',num2str(meanNC));
    fclose(fid);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end