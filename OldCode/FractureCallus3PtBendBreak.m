% NAME-FractureCallus3PtBendBreak
% DESC-Generates a report on callus and cortical bones
% IN-handles.img: The 3D image
% handles.bwContour: The 3D mask, represents the area to analyze
% handles.lowerThreshold: The lower threshold for callus
% handles.upperThreshold: The threshold for cortical
% OUT-FractureCallus3PtBendBreakResults.txt: A text file containing
% analysis results
function FractureCallus3PtBendBreak(handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'bwContour')
            [~, mask, img] = CropImg(handles.bwContour, handles.img);
            img=img.*int16(mask);

            % Calculate callus volumes
            [imgDensity, ~] = calculateDensityFromDICOM(handles.info,img);
            bwCallus = img>= handles.lowerThreshold;
            callusMeanVolumetricDensity = mean(imgDensity(bwCallus));
            callusBoneVolume = nnz(bwCallus);
            callusVolume = nnz(mask);
            callusBoneVolumeFraction = callusBoneVolume / callusVolume;
            
            % Get areas
            bwCallus = imclose(bwCallus,true(15,15,15));
            [~, ~, c] = size(bwCallus);
            bwArea = zeros(c, 1);
            for i = 1:c
                bwCallus(:,:,i) = imfill(bwCallus(:,:,i),'holes');
                bwArea(i) = nnz(bwCallus(:,:,i));
            end
            minArea = min(bwArea);
            maxArea = max(bwArea);
            meanArea = mean(bwArea);
            
            % Calculate cortical volumes
            imgDensity = calculateDensityFromDICOM(handles.info,img);
            bwCortical = img > handles.upperThreshold;
            corticalTissueMineralDensity = mean(imgDensity(bwCortical));
            corticalBoneVolume = nnz(bwCortical);
            corticalBoneVolumeFractionOfCallus = corticalBoneVolume / callusVolume;
            
            bwNonCrt = mask & ~bwCortical;
            
            bwTrab = img >= handles.lowerThreshold & ~bwCortical;
            [out,outHeader] = scancoParameterCalculatorCancellous(handles, bwTrab, bwNonCrt, img, handles.info, 0);

            header = ["Date Analyzed", "Measurement", "Number of Slices", "Voxel Size", "Callus Volume", "Callus Bone Volume",...
                "Callus Bone Volume Fraction", "Callus Volumetric Bone Mineral Density", "Cortical Bone Volume",...
                "Cortical Bone Volume Fraction of Callus", "Cortical Tissue Mineral Density", "Mean Callus Area","Max Callus Area", "Min Callus Area"];
            header = [header, outHeader(3:end)];

            results = [datestr(now), handles.pathstr,handles.abc(3), handles.info.SliceThickness,callusVolume * handles.info.SliceThickness^3,...
                callusBoneVolume * handles.info.SliceThickness^3, callusBoneVolumeFraction,callusMeanVolumetricDensity,...
                corticalBoneVolume * handles.info.SliceThickness^3, corticalBoneVolumeFractionOfCallus, corticalTissueMineralDensity,...
                meanArea * handles.info.SliceThickness^2, maxArea * handles.info.SliceThickness^2, minArea * handles.info.SliceThickness^2];
            results = [results, out(3:end)];

            PrintReport(fullfile(handles.pathstr, 'FractureCallus3PtBendBreakResults.txt'), header, results);
        else
            noMaskError;
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end