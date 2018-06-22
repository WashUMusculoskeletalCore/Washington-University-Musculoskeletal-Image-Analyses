function [hObject,eventdata,handles] = NeedlePinctureImage(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    answer(1) = inputdlg('Please indicate the name of the mask representing the full bone');
    answer(2) = inputdlg('Please indicate the name of the mask representing the needle hole');
    
    handles.bwBone = eval(['handles.' answer{1}]);
    handles.bwNeedleHole = eval(['handles.' answer{2}]);
    
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
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end