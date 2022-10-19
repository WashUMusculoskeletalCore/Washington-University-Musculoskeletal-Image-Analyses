% NAME-NeedlePunctureImage
% DESC-Displays two masks as a 3D image
% IN-handles.savedMasks: The saved masks of the bone and puncture
% OUT-Displays a 3D image
function NeedlePunctureImage(handles)   
    try
        setStatus(handles, 'Busy');
        displayPercentLoaded(handles, 0);
        % Gets masks from user
        bwBone = selectMask(handles, 'Please indicate the name of the mask representing the full bone');
        bwNeedleHole = selectMask(handles, 'Please indicate the name of the mask representing the needle hole');
        displayPercentLoaded(handles, 1/6);
        setStatus(handles, 'Analyzing');
        % Smooth the masks
        bwBone = smooth3(bwBone);
        displayPercentLoaded(handles, 2/6);
        bwNeedleHole = smooth3(bwNeedleHole);
        displayPercentLoaded(handles, 3/6);
        % Create 3D shapes from the masks
        shp1 = shpFromBW(bwBone,3);
        displayPercentLoaded(handles, 4/6);
        shp2 = shpFromBW(bwNeedleHole,3);
        displayPercentLoaded(handles, 5/6);
        % Plot the figure
        setStatus(handles, 'Plotting figure');
        figure;
        plot(shp1,'FaceColor','w','LineStyle','none','FaceAlpha',0.4);
        hold on;
        plot(shp2,'FaceColor','r','LineStyle','none','FaceAlpha',0.8);
        camlight();
        title(['Bone and puncture for ' handles.pathstr]);
        displayPercentLoaded(handles, 1);
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end