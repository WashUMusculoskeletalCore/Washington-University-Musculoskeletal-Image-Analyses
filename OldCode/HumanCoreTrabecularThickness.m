function HumanCoreTrabecularThickness(handles)

try
    setStatus(handles, 'Busy');
    % Identify area inside thresholds
    [~, bwArea, img] = CropImg(handles.bwContour, handles.img);
    bwThresh = img >= handles.lowerThreshold & img <= handles.upperThreshold;
    bwThresh = bwareaopen(bwThresh,150); % Remove small objects from image
    [outCancellous, outHeaderCancellous] = scancoParameterCalculatorCancellous(handles,bwThresh,bwArea,img,handles.info,get(handles.togglebuttonRobustThickness,'Value'));
    PrintReport(fullfile(handles.pathstr,'CancellousResults.txt'), outHeaderCancellous, outCancellous);
    setStatus(handles, 'Not Busy');
catch err
    reportError(err, handles);
end