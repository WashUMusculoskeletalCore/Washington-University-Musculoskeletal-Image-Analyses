% NAME-DensityAnalysis
% DESC-Calculate density(mgHA/ccm) and area statistics for shape and output to file
% IN-handles.img: the 3D image to analyze
% handles.bwContour: the 3D mask, used to select which area of the image to analyze
% handles.info: the DICOM info struct
% OUT-2DResults.txt: A file containing information about the image desnity
function DensityAnalysis(handles)
    try        
        setStatus(handles, 'Busy');
        displayPercentLoaded(handles, 0);
        if isfield(handles, 'bwContour')
            headers = {'Date Analyzed', 'Measurement', 'Area by slice', 'Mean Density by Slice',...
                'Standard Deviation of Density by Slice', 'Min Density by Slice',...
                'Max Density by Slice', 'Mean Area', 'Standard Deviation of Area', 'Min Area',...
                'Max Area', 'Mean Density', 'Standard Deviation of Density', 'Min Density', 'Max Density'};

            % Get Density in mgHA/ccm
            setStatus(handles, 'Analyzing');
            [imgDensity, ~] = calculateDensityFromDICOM(handles.info,handles.img);

            [~, ~, c] = size(handles.bwContour);
            area = zeros(1, c);
            meanIntens = zeros(1, c);
            stdIntens = zeros(1, c);
            minIntens = zeros(1, c);
            maxIntens = zeros(1, c);
            % Get the stats for each slice
            for i = 1:c
                displayPercentLoaded(handles, i/(2*c));
                area(i) = bwarea(handles.bwContour(:,:,i)) * handles.info.SliceThickness^2;
                sliceDensity = imgDensity(:,:,i);
                if ~isempty(sliceDensity(handles.bwContour(:,:,i)))
                    meanIntens(i) = mean(reshape(sliceDensity(handles.bwContour(:,:,i)),[nnz(handles.bwContour(:,:,i)) 1]));
                    stdIntens(i) = std(double(reshape(sliceDensity(handles.bwContour(:,:,i)),[nnz(handles.bwContour(:,:,i)) 1])));
                    minIntens(i) = min(double(reshape(sliceDensity(handles.bwContour(:,:,i)),[nnz(handles.bwContour(:,:,i)) 1])));
                    maxIntens(i) = max(double(reshape(sliceDensity(handles.bwContour(:,:,i)),[nnz(handles.bwContour(:,:,i)) 1])));
                end
            end
            displayPercentLoaded(handles, 1/2);
            % Get the average area per slice of the mask
            meanArea = mean(area);
            minArea = min(area);
            maxArea = max(area);
            stdArea = std(area);
            % Get the average intensity of the masked area
            meanIntensity = mean(imgDensity(handles.bwContour));
            stdIntensity = std(double(imgDensity(handles.bwContour)));
            minIntensity = min(double(imgDensity(handles.bwContour)));
            maxIntensity = max(double(imgDensity(handles.bwContour)));
            setStatus(handles, 'Writing report');
            results = {datestr(now), handles.pathstr, area, meanIntens, stdIntens, minIntens, maxIntens, meanArea,...
                stdArea, minArea, maxArea, meanIntensity, stdIntensity, minIntensity, maxIntensity};
            PrintReport(fullfile(handles.pathstr,'2DResults.txt'), headers, results);
            displayPercentLoaded(handles, 1);
        else
            noMaskError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end
