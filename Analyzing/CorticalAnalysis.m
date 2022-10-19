% NAME-CorticalAnalysis
% DESC-Performs analysis of cortical bone and generates a report
% IN-handles.img: The 3D image of bone, should be taller than the thickest object
% needing to be analyzed
% handles.bwContour: The black and white mask representing only the bone (not the 
% medullary cavity) with pores covered
% handles.info: The struct containing DICOM info
% handles.lowerThreshold: the lower brightness threshold, used to delineate bone
% handles.pathstring: The filepath to save the files to
% OUT: CorticalResults.txt: A tab deliniated text file containing the
% analysis results
% CorticalResultsFullLength.txt: A tab deliniated text file containing the
% section by section analysis results
function CorticalAnalysis(handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'bwContour')
            % Crop the image and the mask to the prism bounding the mask
            [~, contour, img] = CropImg(handles.bwContour, handles.img);
            if isFullMask(contour)
                setStatus(handles, 'Analyzing');
                [outCortical, outHeaderCortical, outCorticalContinuous, outHeaderContinuous] = scancoParameterCalculatorCortical(handles, img, contour, handles.info, handles.lowerThreshold, get(handles.togglebuttonRobustThickness,'Value'));
                [~, twoDData] = twoDAnalysisSub(img,handles.info,handles.lowerThreshold,contour);
                % Print main results
                setStatus(handles, 'Writing report');
                PrintReport(fullfile(handles.pathstr,'CorticalResults.txt'), outHeaderCortical, [outCortical, num2str(twoDData(2) + twoDData(3))]);
    
                % Print continuous bone results
                PrintReport(fullfile(handles.pathstr,'CorticalResultsFullLength.txt'), outHeaderContinuous, [handles.pathstr, datestr(now), outCorticalContinuous]);
            else
                errorMsg('The mask must be continuous across all slices.')
            end
        else
            noMaskError()
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end