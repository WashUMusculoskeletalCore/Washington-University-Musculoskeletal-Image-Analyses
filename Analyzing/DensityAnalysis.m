% NAME-DensityAnalysis
% DESC-Calculate density(mgHA/ccm) and area statistics for shape and output to file
% IN-handles.img: the 3D image to analyze
% handles.bwContour: the 3D mask, used to select which area of the image to analyze
% handles.info: the DICOM info struct
% OUT-
function [hObject,eventdata,handles] = DensityAnalysis(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        if isfield(handles, 'img')
            if exist(fullfile(handles.pathstr,'2DResults.txt'),'file') ~= 2
                fid = fopen(fullfile(handles.pathstr,'2DResults.txt'),'a');
                % Print the headers
                fprintf(fid,'%s\t','Date Analyzed');
                fprintf(fid,'%s\t','Measurement');

                fprintf(fid,'%s\t','Area by slice');
                fprintf(fid,'%s\t','Mean Density by Slice');
                fprintf(fid,'%s\t','Standard Deviation of Density by Slice');
                fprintf(fid,'%s\t','Min Density by Slice');
                fprintf(fid,'%s\t','Max Density by Slice');

                fprintf(fid,'%s\t','Mean Area');
                fprintf(fid,'%s\t','Standard Deviation of Area');
                fprintf(fid,'%s\t','Min Area');
                fprintf(fid,'%s\t','Max Area');
                fprintf(fid,'%s\t','Mean Density');
                fprintf(fid,'%s\t','Standard Deviation of Density');
                fprintf(fid,'%s\t','Min Density');
                fprintf(fid,'%s\n','Max Density');
            else
                fid = fopen(fullfile(handles.pathstr,'2DResults.txt'),'a');
            end
            %Date/time and filepath
            fprintf(fid,'%s\t',datestr(now));
            fprintf(fid,'%s\t',handles.pathstr);
            % Get Density in mgHA/ccm
            [imgDensity, ~] = calculateDensityFromDICOM(handles.info,handles.img);

            [~, ~, c] = size(handles.bwContour);
            area = zeros(1, c);
            meanIntens = zeros(1, c);
            stdIntens = zeros(1, c);
            minIntens = zeros(1, c);
            maxIntens = zeros(1, c);
            % Get the stats for each slice
            for i = 1:c
                displayPercentLoaded(hObject, handles, i/c);
                area(i) = bwarea(handles.bwContour(:,:,i)) * handles.info.SliceThickness^2;
                sliceDensity = imgDensity(:,:,i);
                meanIntens(i) = mean(reshape(sliceDensity(handles.bwContour(:,:,i)),[nnz(handles.bwContour(:,:,i)) 1]));
                stdIntens(i) = std(double(reshape(sliceDensity(handles.bwContour(:,:,i)),[nnz(handles.bwContour(:,:,i)) 1])));
                minIntens(i) = min(double(reshape(sliceDensity(handles.bwContour(:,:,i)),[nnz(handles.bwContour(:,:,i)) 1])));
                maxIntens(i) = max(double(reshape(sliceDensity(handles.bwContour(:,:,i)),[nnz(handles.bwContour(:,:,i)) 1])));
            end
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

            for i = 1:c
                if i == 1 % For the first slice, also output the density are area for the whole shape
                    fprintf(fid,'%s\t',num2str(area(i)));
                    fprintf(fid,'%s\t',num2str(meanIntens(i)));
                    fprintf(fid,'%s\t',num2str(stdIntens(i)));
                    fprintf(fid,'%s\t',num2str(minIntens(i)));
                    fprintf(fid,'%s\t',num2str(maxIntens(i)));
                    fprintf(fid,'%s\t',num2str(meanArea));
                    fprintf(fid,'%s\t',num2str(stdArea));
                    fprintf(fid,'%s\t',num2str(minArea));
                    fprintf(fid,'%s\t',num2str(maxArea(i)));
                    fprintf(fid,'%s\t',num2str(meanIntensity));
                    fprintf(fid,'%s\t',num2str(stdIntensity));
                    fprintf(fid,'%s\t',num2str(minIntensity));
                    fprintf(fid,'%s\n',num2str(maxIntensity));
                else
                    fprintf(fid,'%s\t','');
                    fprintf(fid,'%s\t','');
                    fprintf(fid,'%s\t',num2str(area(i)));
                    fprintf(fid,'%s\t',num2str(meanIntens(i)));
                    fprintf(fid,'%s\t',num2str(stdIntens(i)));
                    fprintf(fid,'%s\t',num2str(minIntens(i)));
                    fprintf(fid,'%s\n',num2str(maxIntens(i)));
                end
            end

            fclose(fid);
        else
            noImgError();
        end
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end
