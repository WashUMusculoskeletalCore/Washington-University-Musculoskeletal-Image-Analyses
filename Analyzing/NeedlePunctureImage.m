function [hObject,eventdata,handles] = NeedlePunctureImage(hObject,eventdata,handles)

try
    setStatus(hObject, handles, 'Busy');
    answer(1) = inputdlg('Please indicate the name of the mask representing the full bone');
    answer(2) = inputdlg('Please indicate the name of the mask representing the needle hole');
    
    handles.bwBone = selectMask(handles, 'Please indicate the name of the mask representing the full bone');
    handles.bwNeedleHole = selectMask(handles, 'Please indicate the name of the mask representing the needle hole');
    
    handles.bwBone = smooth3(handles.bwBone);
    handles.bwNeedleHole = smooth3(handles.bwNeedleHole);
    
    shp1 = shpFromBW(handles.bwBone,3);
    shp2 = shpFromBW(handles.bwNeedleHole,3);
    
    figure;
    plot(shp1,'FaceColor','w','LineStyle','none','FaceAlpha',0.4);
    hold on;
    plot(shp2,'FaceColor','r','LineStyle','none','FaceAlpha',0.8);
    camlight();
    title(['Bone and puncture for ' handles.pathstr]);
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end