function [handles,events,hObject] = CTHistomorphometry(hObject,events,handles)

movingPathstr = uigetdir(handles.pathstr,'Please select the folder containing your registered DICOM files');
[tformPathstr,tformPathDir] = uigetfile(handles.pathstr,'Please select the transformation object to use');

set(handles.textBusy,'String','Loading DICOM Files');
drawnow();
[registeredIMG,registeredInfo] = readDICOMStack(movingPathstr);
load(fullfile(tformPathDir,tformPathstr));

registeredIMG = imwarp(registeredIMG,tform,'OutputView',imref3d(size(handles.img)));

[a b c] = size(registeredIMG);
h = figure;
hold on;
for i = 1:c
    fused(:,:,i,1:3) = imfuse(handles.img(:,:,i),registeredIMG(:,:,i));
    imshow(squeeze(fused(:,:,i,1:3)));
    drawnow()
end
hold off;
% StackSlider(fused);
% uiwait();
StackSlider(handles.img);
StackSlider(registeredIMG);

answer = inputdlg('Is this registration acceptable? y/n');
if strcmpi(answer{1},y) == 1

    set(handles.textBusy,'String','Cropping Images');
    drawnow();
    [x y z] = ind2sub(size(handles.bwContour),find(handles.bwContour));
    xMin = min(x);
    xMax = max(x);
    yMin = min(y);
    yMax = max(y);
    zMin = min(z);
    zMax = max(z);
    handles.img = handles.img(xMin:xMax,yMin:yMax,zMin:zMax);
    registeredIMG = registeredIMG(xMin:xMax,yMin:yMax,zMin:zMax);

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
    bwRegisteredVolume = length(find(bwFixed)) * handles.info.SliceThickness^3;
    bwDifferenceVolume = bwFixedVolume - bwRegisteredVolume;
    newVolume = length(find(bwRegistered(~bwFixed))) * handles.info.SliceThickness^3;
    oldVolume = length(find(bwFixed(~bwRegistered))) * handles.info.SliceThickness^3;

    shpFixed = shpFromBW(bwFixed,2);
    shpRegistered = shpFromBW(bwRegistered,2);
    shpNew = shpFromBW(bwRegistered(~bwFixed),2);
    shpOld = shpFromBW(bwFixed(~bwRegistered),2);

    figure;
    plot(shpFixed,'FaceColor','r','LineStyle','none');
    camlight();
    figure
    plot(shpRegistered,'FaceColor','b','LineStyle','none');
    camlight();
    figure
    plot(shpNew,'FaceColor','g','LineStyle','none');
    camlight();
    figure
    plot(shpOld,'FaceColor','y','LineStyle','none');
    camlight();
end