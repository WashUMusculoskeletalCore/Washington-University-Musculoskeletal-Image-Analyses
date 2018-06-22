function [hObject,eventdata,handles] = FractureCallus3PtBendBreak(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    drawnow()
    
    
    
    handles.img(~handles.bwContour) = 0;
    
    %convert pixels to physical units when writing out
    %do callus math
    handles.bwTmp = false(size(handles.img));
    handles.bwTmp(handles.img > handles.lowerThreshold) = 1;
    [handles.imgDensity ~] = calculateDensityFromDICOM(handles.info,handles.img);
    handles.imgDensity(~handles.bwTmp) = 0;
    handles.callusMeanVolumetricDensity = mean(handles.imgDensity(handles.bwTmp));
    handles.callusBoneVolume = length(find(handles.bwTmp));
    handles.callusVolume = length(find(handles.bwContour));
    handles.callusBoneVolumeFraction = length(find(handles.bwTmp)) / length(find(handles.bwContour));
    
    %get areas
    handles.bwTmp = imclose(handles.bwTmp,true(15,15,15));
    [a b c] = size(handles.bwTmp);
    for i = 1:c
        handles.bwTmp(:,:,i) = imfill(handles.bwTmp(:,:,i),'holes');
        bwArea(i) = length(find(handles.bwTmp(:,:,i)));
    end
    minArea = min(bwArea);
    maxArea = max(bwArea);
    meanArea = mean(bwArea);
    
    %do cortical math
    handles.imgDensity = calculateDensityFromDICOM(handles.info,handles.img);
    handles.bwTmp = false(size(handles.img));
    handles.bwTmp(handles.img > handles.upperThreshold) = 1;
    handles.corticalTissueMineralDensity = mean(handles.imgDensity(handles.bwTmp));
    handles.corticalBoneVolume = length(find(handles.bwTmp));
    handles.corticalBoneVolumeFractionOfCallus = length(find(handles.bwTmp)) / length(find(handles.bwContour));
    
    handles.bwTrab = handles.bwContour;
    handles.bwTrab(handles.bwTmp) = 0;
    
    imgTmp = handles.img;
    imgTmp(handles.bwTmp) = 0;
    [out,outHeader] = scancoParameterCalculatorCancellous(imgTmp > handles.lowerThreshold,handles.bwTrab,handles.img,handles.info,0);
    
    fid = fopen(fullfile(handles.pathstr,'FractureCallus3PtBendBreakResults.txt'),'a');
    fprintf(fid,'%s\t','Date Analyzed');
    fprintf(fid,'%s\t','Measurement');
    fprintf(fid,'%s\t','Number of Slices');
    fprintf(fid,'%s\t','Voxel Size');
    
    fprintf(fid,'%s\t','Callus Volume');
    fprintf(fid,'%s\t','Callus Bone Volume');
    fprintf(fid,'%s\t','Callus Bone Volume Fraction');
    fprintf(fid,'%s\t','Callus Volumetric Bone Mineral Density');
    fprintf(fid,'%s\t','Cortical Bone Volume');
    fprintf(fid,'%s\t','Cortical Bone Volume Fraction of Callus');
    fprintf(fid,'%s\t','Cortical Tissue Mineral Density');
    fprintf(fid,'%s\t','Mean Callus Area');
    fprintf(fid,'%s\t','Max Callus Area');
    fprintf(fid,'%s\t','Min Callus Area');
    for i = 2:length(outHeader)
        if i ~= length(outHeader)
            fprintf(fid,'%s\t',outHeader{i});
        else
            fprintf(fid,'%s\n',outHeader{i});
        end
    end
    
    
    fprintf(fid,'%s\t',datestr(now));
    fprintf(fid,'%s\t',handles.pathstr);
    [a b c] = size(handles.img);
    fprintf(fid,'%s\t',num2str((c)));
    
    fprintf(fid,'%s\t',num2str(handles.info.SliceThickness));
    fprintf(fid,'%s\t',num2str(handles.callusVolume * handles.info.SliceThickness^3));
    fprintf(fid,'%s\t',num2str(handles.callusBoneVolume * handles.info.SliceThickness^3));
    fprintf(fid,'%s\t',num2str(handles.callusBoneVolumeFraction));
    fprintf(fid,'%s\t',num2str(handles.callusMeanVolumetricDensity));
    fprintf(fid,'%s\t',num2str(handles.corticalBoneVolume * handles.info.SliceThickness^3));
    fprintf(fid,'%s\t',num2str(handles.corticalBoneVolumeFractionOfCallus));
    fprintf(fid,'%s\t',num2str(handles.corticalTissueMineralDensity));
    fprintf(fid,'%s\t',num2str(meanArea * handles.info.SliceThickness^2));
    fprintf(fid,'%s\t',num2str(maxArea * handles.info.SliceThickness^2));
    fprintf(fid,'%s\t',num2str(minArea * handles.info.SliceThickness^2));
    for i = 2:length(out)
        if i ~= length(out)
            fprintf(fid,'%s\t',num2str(out{i}));
        else
            fprintf(fid,'%s\n',num2str(out{i}));
        end
    end
    
    fclose(fid);
    
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end