function [hObject,eventdata,handles] = HruskaAortaMineralization(hObject,eventdata,handles)

try
    setStatus(hObject, handles, 'Busy');
    %startSlice = handles.slice;
    %endSlice = startSlice + 1049;
    
    calcificationThresh =  800 * (2^15 / 1000);
    %     img = uint16(smooth3(handles.img(:,:,startSlice:endSlice)));
    level = 4200;%handles.lowerThreshold;
    tissueBW = handles.img > level;
    calcificationBW = handles.img > calcificationThresh;
    tissueBW(calcificationBW) = 0;
    tissueBW = imopen(tissueBW,strel('disk',3,0));
    tissueBW = bwareaopen(tissueBW,20);
    tissueBW = imclose(tissueBW,true(4,4,4));
    tissueBW = bwBiggest(tissueBW);
    calcificationBW(tissueBW) = 0;
    
    shpTissue = shpFromBW(tissueBW,5);
    shpCalcification = shpFromBW(calcificationBW,3);
    
    figure;
    plot(shpTissue,'FaceColor','r','LineStyle','none','FaceAlpha',0.2);
    hold on;
    plot(shpCalcification,'FaceColor','k','LineStyle','none');
    
    savefig(gcf,fullfile(handles.pathstr,'calcificationImage.fig'));
    
    fid = fopen(fullfile(handles.pathstr,'Results.txt'),'w');
    header = {'Path','Arterial Tissue Volume (mm^3)','Calcification Volume (mm^3)','% Calcified','Lower Threshold','Upper Threshold'};
    for j = 1:length(header)
        if j ~= length(header)
            fprintf(fid,'%s\t',header{j});
        else
            fprintf(fid,'%s\n',header{j});
        end
    end
    fprintf(fid,'%s\t',handles.pathstr);
    fprintf(fid,'%s\t',num2str(length(find(tissueBW)) * handles.info.SliceThickness^3));
    fprintf(fid,'%s\t',num2str(length(find(calcificationBW)) * handles.info.SliceThickness^3));
    fprintf(fid,'%s\t',num2str((length(find(calcificationBW)) * handles.info.SliceThickness^3) / (length(find(tissueBW)) * handles.info.SliceThickness^3)));
    fprintf(fid,'%s\t',num2str(level));
    fprintf(fid,'%s\n',num2str(calcificationThresh));
    fclose(fid);
    %     close all;
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end