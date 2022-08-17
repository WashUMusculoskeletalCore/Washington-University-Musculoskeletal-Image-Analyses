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
function [hObject,eventdata,handles] = CorticalAnalysis(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        if isfield(handles, 'bwContour')
            % Crop the image and the mask to the prism bounding the mask
            [x, y, z] = ind2sub(size(handles.bwContour),find(handles.bwContour));
            xMin = min(x);
            xMax = max(x);
            yMin = min(y);
            yMax = max(y);
            zMin = min(z);
            zMax = max(z);

            img = handles.img(xMin:xMax,yMin:yMax,zMin:zMax);
            contour = handles.bwContour(xMin:xMax,yMin:yMax,zMin:zMax);

            [outCortical, outHeaderCortical, outCorticalContinuous] = scancoParameterCalculatorCortical(img,contour,handles.info,handles.threshold,get(handles.togglebuttonRobustThickness,'Value'));
            [~, twoDData] = twoDAnalysisSub(img,handles.info,handles.lowerThreshold,contour);
            % Print main results
            % If the file does not exist, create it and fill in the headers
            if exist(fullfile(handles.pathstr,'CorticalResults.txt'),'file') ~= 2
                fid = fopen(fullfile(handles.pathstr,'CorticalResults.txt'),'a');
                for i = 1:length(handles.outHeaderCortical)
                    if i == length(handles.outHeaderCortical)
                        fprintf(fid,'%s\n',outHeaderCortical{i});
                    else
                        fprintf(fid,'%s\t',outHeaderCortical{i});
                    end
                end
            else
                fid = fopen(fullfile(handles.pathstr,'CorticalResults.txt'),'a');
            end
            for i = 1:length(outCortical)
                if ~ischar(outCortical{i})
                    fprintf(fid,'%s\t',num2str(outCortical{i}));
                else
                    fprintf(fid,'%s\t',outCortical{i});
                end
            end
            fprintf(fid,'%s\n',num2str(twoDData(2) + twoDData(3)));
            fclose(fid);
            %Print continuous bone results
            fields = fieldnames(outCorticalContinuous);
            % If the file does not exist, create it and fill in the headers
            if exist(fullfile(handles.pathstr,'CorticalResultsFullLength.txt'),'file') ~= 2
                fid = fopen(fullfile(handles.pathstr,'CorticalResultsFullLength.txt'),'a');
                fprintf(fid,'%s\t','Path');
                fprintf(fid,'%s\t','Analysis Date');
                for i = 1:numel(fieldnames(outCorticalContinuous))
                    if i == numel(fieldnames(outCorticalContinuous))
                        field = fields{i};
                        fprintf(fid,'%s\n',field(1:end-1));
                    else
                        field = fields{i};
                        fprintf(fid,'%s\t',field(1:end-1));
                    end
                end
                fclose(fid);
            end
            fid = fopen(fullfile(handles.pathstr,'CorticalResultsFullLength.txt'),'a');
            outVarContinuous = strings(length(outCorticalContinuous.(fields{1})), length(fields));
            for i = 1:length(fields)
                var = outCorticalContinuous.(fields{i});
                for j = 1:length(var)
                    outVarContinuous(j,i) = var(j);
                end
            end
            [a, b] = size(outVarContinuous);
            for i = 1:a
                fprintf(fid,'%s\t',handles.pathstr);
                fprintf(fid,'%s\t',datestr(now));
                for j = 1:b
                    if j ~= b
                        fprintf(fid,'%s\t',num2str(outVarContinuous(i,j)));
                    else
                        fprintf(fid,'%s\n',num2str(outVarContinuous(i,j)));
                    end
                end
            end
            fclose(fid);
            guidata(hObject, handles);
        else
            noMaskError()
        end
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end