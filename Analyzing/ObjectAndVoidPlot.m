function [hObject,eventdata,handles] = ObjectAndVoidPlot(hObject,eventdata,handles)

try
    setStatus(hObject, handles, 'Busy');
    bw = handles.img > handles.lowerThreshold;
    bw(handles.img > handles.upperThreshold) = 0;
    %     tmp = imerode(handles.bwContour,true(7,7,7));
    tmp = handles.bwContour;
    tmp(bw) = 0;
    bw = tmp;
    clear tmp;
    %     bw = bwareaopen(bw,350);
    shp = shpFromBW(handles.bwContour,4);
    %     shp.Points = shp.Points ./ 0.3;
    figure;
    plot(shp,'LineStyle','none','FaceColor','b','FaceAlpha',0.3);
    hold on;
    shp2 = shpFromBW(bw,3);
    plot(shp2,'LineStyle','none','FaceColor','r');
    camlight();
%     axes tight;
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end