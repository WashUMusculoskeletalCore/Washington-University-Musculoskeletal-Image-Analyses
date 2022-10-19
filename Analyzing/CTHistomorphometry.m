% NAME-CTHistomorphometry
% DESC-Determines the difference between the image and a loaded image
% IN-handles.img: The 3D image
% IO: Loads a DICOM and a tranformation file
% OUT-IO: Creates a file showing the difference
function CTHistomorphometry(handles)
try
    movingPathstr = uigetdir(handles.pathstr,'Please select the folder containing your registered DICOM files');
    if isequal(movingPathstr, 0)
        error('ContouringGUI:InputCanceled', 'No folder selected');
    end
    [tformPathstr,tformPathDir] = uigetfile(handles.pathstr,'Please select the transformation object to use');
    if isequal(tformPathstr, 0) && isequal(tformPathDir, 0)
        error('ContouringGUI:InputCanceled', 'No file slected');
    end
    setStatus(handles, 'Loading DICOM Files');
    [registeredIMG,~] = readDICOMStack(movingPathstr);
    
    tform=load(fullfile(tformPathDir,tformPathstr));
    registeredIMG = imwarp(registeredIMG,tform,'OutputView',imref3d(size(handles.img)));
    
    
    setStatus(handles, 'Masking Images');
    % Remove area outside thresholds from image
    bwFixed = handles.img > handles.lowerThreshold;
    bwFixedHigh = handles.img > handles.upperThreshold;
    bwFixed(bwFixedHigh) = 0;
    % Remove area outside thresholds from registered image
    bwRegistered = registeredIMG > handles.lowerThreshold;
    bwRegistered(bwFixedHigh) = 0;
    
    setStatus(handles, 'Finding Mask Differences');
    % Calculate difference in volume between image and registered image
    bwFixedVolume = nnz(bwFixed) * handles.info.SliceThickness^3;
    bwRegisteredVolume = nnz(bwRegistered) * handles.info.SliceThickness^3;
    bwDifferenceVolume = bwFixedVolume - bwRegisteredVolume;
    newVolume = nnz(bwRegistered(~bwFixed)) * handles.info.SliceThickness^3;
    oldVolume = nnz(bwFixed(~bwRegistered)) * handles.info.SliceThickness^3;
    % Output results to file
    header = {'Rat ID','Date Performed','Threshold','BV Fixed (pre-scan)','BV Registered (post-scan)','BV Difference','Fixed-Only Volume',...
        'Moving-Only Volume'};
    results = {movingPathstr, datestr(now), handles.lowerThreshold, bwFixedVolume, bwRegisteredVolume, bwDifferenceVolume, oldVolume, newVolume};
    fid = fopen(fullfile(movingPathstr,'RegistrationDifferenceResults.txt'),'a');
    PrintReport(fid, header, results);
    
    % Display data as a graphic
    shpFixed = shpFromBW(bwFixed,2);
    shpRegistered = shpFromBW(bwRegistered,2);
    bwOld = bwFixed;
    bwOld(bwRegistered) = 0;
    shpOld = shpFromBW(bwOld,2);
    bwNew = bwRegistered;
    bwNew(bwFixed) = 0;
    shpNew = shpFromBW(bwNew,2);
    
    
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
catch err
    reportError(err, handles);
end
