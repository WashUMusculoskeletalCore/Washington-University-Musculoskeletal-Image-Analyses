% NAME-CancellousAnalysis
% DESC-Performs analysis on cancellous bone and outputs the results to a file
% IN-handles.img: the 3D image of a bone
% handles.lowerThreshold: the lower brightness threshold for the trabecular
% structure
% handles.upperThreshold: the upper brightness threshold for the trabecular
% structure
% handles.bwContour: the 3D mask for the area to analyze.
% OUT-CancellousResults.txt: the tab delimited text file containing the
% results
function CancellousAnalysis(handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'bwContour')
            % Get the area between the thresholds
            bw = handles.bwContour & handles.img >= handles.lowerThreshold & handles.img <= handles.upperThreshold;
            [~, bwContour, bw, img] = CropImg(handles.bwContour, bw, handles.img);
            % Perform the analysis
            setStatus(handles, 'Analyzing');
            [outCancellous, outHeaderCancellous] = scancoParameterCalculatorCancellous(handles,bw,bwContour,img,handles.info,get(handles.togglebuttonRobustThickness,'Value'));
            setStatus(handles, 'Writing report');
            PrintReport(fullfile(handles.pathstr,'CancellousResults.txt'), outHeaderCancellous, outCancellous);
        else
            noMaskErr();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end
