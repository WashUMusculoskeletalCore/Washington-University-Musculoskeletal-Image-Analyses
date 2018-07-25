function [hObject,eventdata,handles] = MarrowFat(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    handles.img(~handles.bwContour) = 0;
    handles.bwGlobules = handles.img > handles.lowerThreshold;
    handles.bwGlobules(handles.img > handles.upperThreshold) = 0;
    bw = handles.bwGlobules;
    bw = bwareaopen(bw,20);
    fatVol = length(find(bw)) * handles.info.SliceThickness^3;
    totVol = length(find(handles.bwContour)) * handles.info.SliceThickness^3;
    bw = imerode(bw,true(3,3,3));
    %     StackSlider(bw);
    bw = ~bw;
    D = bwdist(bw);
    D = 1-D;
    Ld = watershed(D);
    %     imshow(label2rgb(Ld))
    mask = imextendedmin(D,1);
    D2 = imimposemin(D,mask);
    Ld2 = watershed(D2);
    bw3 = ~bw;
    bw3(Ld2 == 0) = 0;
    %     bwTmp = imdilate(bw3,true(3,3,3));
    for i = 1:handles.abc(3)
        handles.blended(:,:,i) = imfuse(bw3(:,:,i),handles.img(:,:,i),'blend');
    end
    clear bwTmp;
    cc = bwconncomp(bw3);
    figure
    for i = 1:length(cc.PixelIdxList)
        clc
        i/length(cc.PixelIdxList)
        bwTmp = false(size(bw3));
        bwTmp(cc.PixelIdxList{i}) = 1;
        bwTmp = imdilate(bwTmp,true(3,3,3));
        %         figure
        shp = shpFromBW(bwTmp,2);
        plot(shp,'LineStyle','none','FaceColor','r');
        %         plot(shp)
        if i == 1
            hold on;
        end
        
        drawnow;
        if i == 1
            shp = shpFromBW(resize3DMatrixBW(handles.bwContour,0.3),5);
            shp.Points = shp.Points .* (1/0.3);
            plot(shp,'FaceColor','b','FaceAlpha',0.3,'LineStyle','none');
        end
        
        vols(i) = shp.volume;
        %         vols(i) = vols(i) * handles.info.SliceThickness^3;
        %         vols(i) = length(find(bwTmp)) * handles.info.SliceThickness^3;
        surfArea(i) = shp.surfaceArea;
        %         surfArea(i) = surfArea(i) * handles.info.SliceThickness^3;
        topTerm = pi * (6 * shp.volume / pi)^(2/3);
        sphericity(i) = topTerm / shp.surfaceArea;
    end
    camlight();
    vols = vols .* handles.info.SliceThickness^3;
    meanVols = mean(vols);
    stdVols = std(vols);
    totVol = sum(vols);
    fid = fopen(fullfile(handles.pathstr,'fatVolumeResults.txt'),'a');
    
    fprintf(fid,'%s\t','File Path');
    fprintf(fid,'%s\t','Threshold');
    fprintf(fid,'%s\t','Total Fat Volume');
    fprintf(fid,'%s\t','Number of Globules');
    fprintf(fid,'%s\t','Mean Globule Size');
    fprintf(fid,'%s\t','Standard Deviation of Globule Size');
    fprintf(fid,'%s\t','Mean Globule Sphericity');
    fprintf(fid,'%s\t','Standard Deviation of Globule Sphericity');
    fprintf(fid,'%s\t','Total Medullary Cavity Volume');
    fprintf(fid,'%s\n','Fat Volume Fraction');
    
    fprintf(fid,'%s\t',handles.pathstr);
    fprintf(fid,'%s\t',[num2str(handles.lowerThreshold),' , ',num2str(handles.upperThreshold)]);
    fprintf(fid,'%s\t',num2str(totVol));
    fprintf(fid,'%s\t',num2str(length(vols)));
    fprintf(fid,'%s\t',num2str(meanVols));
    fprintf(fid,'%s\t',num2str(stdVols));
    fprintf(fid,'%s\t',num2str(mean(sphericity)));
    fprintf(fid,'%s\t',num2str(std(sphericity)));
    fprintf(fid,'%s\t',num2str(length(find(handles.bwContour)) * handles.info.SliceThickness^3));
    fprintf(fid,'%s\n',num2str( totVol / (length(find(handles.bwContour)) * handles.info.SliceThickness^3)));
    fclose(fid);
    
    fid = fopen(fullfile(handles.pathstr,'fatVolumeIndividual.txt'),'w');
    for i = 1:length(vols)
        fprintf(fid,'%s\t',num2str(vols(i)));
    end
    fclose(fid);
    
    fid = fopen(fullfile(handles.pathstr,'sphericityIndividual.txt'),'w');
    for i = 1:length(sphericity)
        fprintf(fid,'%s\t',num2str(sphericity(i)));
    end
    fclose(fid);
    
    mkdir(fullfile(handles.pathstr,'overlay images'));
    
    [a b c] = size(handles.blended);
    for i = 1:c
        pathTemp = fullfile(handles.pathstr,'overlay images');
        fName = ['Image' num2str(i) '.tif'];
        imwrite(handles.blended(:,:,i),fullfile(pathTemp,fName));
    end
    
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end
