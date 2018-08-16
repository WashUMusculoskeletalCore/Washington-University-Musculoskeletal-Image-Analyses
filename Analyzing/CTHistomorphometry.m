function [handles,events,hObject] = CTHistomorphometry(hObject,events,handles)

movingPathstr = uigetdir(handles.pathstr,'Please select the folder containing your registered DICOM files');
[tformPathstr,tformPathDir] = uigetfile(handles.pathstr,'Please select the transformation object to use');

set(handles.textBusy,'String','Loading DICOM Files');
drawnow();
[registeredIMG,registeredInfo] = readDICOMStack(movingPathstr);

if tformPathstr ~= 0
    load(fullfile(tformPathDir,tformPathstr));
    registeredIMG = imwarp(registeredIMG,tform,'OutputView',imref3d(size(handles.img)));
end

% [a b c] = size(registeredIMG);
% h = figure;
% hold on;
% for i = 1:c
%     fused(:,:,i,1:3) = imfuse(handles.img(:,:,i),registeredIMG(:,:,i));
%     imshow(squeeze(fused(:,:,i,1:3)));
%     drawnow()
% end
% hold off;
% StackSlider(fused);
% uiwait();
% StackSlider(handles.img);
% StackSlider(registeredIMG);

% answer = inputdlg('Is this registration acceptable? y/n');
answer{1} = 'y';
if strcmpi(answer{1},'y') == 1

    set(handles.textBusy,'String','Cropping Images');
    drawnow();
%     [x y z] = ind2sub(size(handles.bwContour),find(handles.bwContour));
%     xMin = min(x);
%     xMax = max(x);
%     yMin = min(y);
%     yMax = max(y);
%     zMin = min(z);
%     zMax = max(z);
%     handles.img = handles.img(xMin:xMax,yMin:yMax,zMin:zMax);
%     registeredIMG = registeredIMG(xMin:xMax,yMin:yMax,zMin:zMax);

    set(handles.textBusy,'String','Masking Images');
    drawnow();
    bwFixed = handles.img > handles.lowerThreshold;
    bwFixedHigh = handles.img > handles.upperThreshold;
    bwFixed(bwFixedHigh) = 0;
    bwRegistered = registeredIMG > handles.lowerThreshold;
    bwRegisteredHigh = registeredIMG > handles.upperThreshold;
    bwRegistered(bwFixedHigh) = 0;

    set(handles.textBusy,'String','Finding Mask Differences');
    drawnow();
    bwFixedVolume = length(find(bwFixed)) * handles.info.SliceThickness^3;
    bwRegisteredVolume = length(find(bwRegistered)) * handles.info.SliceThickness^3;
    bwDifferenceVolume = bwFixedVolume - bwRegisteredVolume;
    newVolume = length(find(bwRegistered(~bwFixed))) * handles.info.SliceThickness^3;
    oldVolume = length(find(bwFixed(~bwRegistered))) * handles.info.SliceThickness^3;
    
    header = {'Rat ID','Date Performed','Threshold','BV Fixed (pre-scan)','BV Registered (post-scan)','BV Difference','Fixed-Only Volume',...
        'Moving-Only Volume'};
    
    fid = fopen(fullfile(movingPathstr,'RegistrationDifferenceResults.txt'),'a');
    for i = 1:length(header)
        if i == length(header)
            fprintf(fid,'%s\n',header{i});
        else
            fprintf(fid,'%s\t',header{i});
        end
    end
    fprintf(fid,'%s\t',movingPathstr);
    fprintf(fid,'%s\t',datestr(now));
    fprintf(fid,'%s\t',num2str(handles.lowerThreshold));
    fprintf(fid,'%s\t',num2str(bwFixedVolume));
    fprintf(fid,'%s\t',num2str(bwRegisteredVolume));
    fprintf(fid,'%s\t',num2str(bwDifferenceVolume));
    fprintf(fid,'%s\t',num2str(oldVolume));
    fprintf(fid,'%s\n',num2str(newVolume));
    fclose(fid);
    
    [a b c] = size(bwFixed);
    
    shpFixed = shpFromBW(bwFixed,2);
    shpRegistered = shpFromBW(bwRegistered,2);
    tmp = bwFixed;
    tmp(bwRegistered) = 0;
    shpOld = shpFromBW(tmp,2);
    tmp = bwRegistered;
    tmp(bwFixed) = 0;
    shpNew = shpFromBW(tmp,2);
    
    
    figure;
    plot(shpFixed,'FaceColor','r','LineStyle','none');
    camlight();
    savefig(fullfile(movingPathstr,'shpFixed.fig'));
    figure
    plot(shpRegistered,'FaceColor','b','LineStyle','none');
    camlight();
    savefig(fullfile(movingPathstr,'shpRegistered.fig'));
    figure
    plot(shpNew,'FaceColor','g','LineStyle','none');
    camlight();
    savefig(fullfile(movingPathstr,'shpNew.fig'));
    figure
    plot(shpOld,'FaceColor','y','LineStyle','none');
    camlight();
    savefig(fullfile(movingPathstr,'shpOld.fig'));
    
    figure;
    plot(shpFixed,'FaceColor','r','LineStyle','none');
    hold on;
    plot(shpRegistered,'FaceColor','b','LineStyle','none','FaceAlpha',0.5);
    plot(shpNew,'FaceColor','g','LineStyle','none','FaceAlpha',0.5);
    plot(shpOld,'FaceColor','y','LineStyle','none','FaceAlpha',0.5);
    hold off;
    camlight();
    savefig(fullfile(movingPathstr,'shpCombined.fig'));
end
