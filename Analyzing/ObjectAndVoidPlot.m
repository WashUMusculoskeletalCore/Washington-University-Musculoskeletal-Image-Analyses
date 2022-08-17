% NAME-ObjectAndVoidPlot
% DESC-Creates a 3D image of the mask and the area of the mask outside of
% the image threshold
% IN=handles.bwContour: The 3D mask representing the object and any voids
% handles.img: The 3D image
% handles.lowerThreshold, handles.upperThreshold: The thresholds used to
% identify objects in the image
% OUT: Displays a 3D plot showing the mask and any voids in the image
% inside of it
function [hObject,eventdata,handles] = ObjectAndVoidPlot(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        if isfield(handles, 'bwContour')    
            % Create a 3D shape from the mask and plot it
            shp = shpFromBW(handles.bwContour,4);
            figure;
            plot(shp,'LineStyle','none','FaceColor','b','FaceAlpha',0.3);
            hold on;
            % Identify the voids in the mask and plot them on the same
            % figure
            void = handles.bwContour & (handles.img < handles.lowerThreshold | handles.img > handles.upperThreshold);
            shp2 = shpFromBW(void,3);
            plot(shp2,'LineStyle','none','FaceColor','r');
            camlight();
            hold off;
        else
            noMaskError();
        end
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end