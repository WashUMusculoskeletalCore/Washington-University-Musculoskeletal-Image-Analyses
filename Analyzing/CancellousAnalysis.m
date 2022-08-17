% NAME-CancellousAnalysis
% DESC-Performs analysis on cancellous bone and outputs the results to a file
% IN-handles.img: the 3D image of a bone
% handles.lowerThreshold: the lower brightness threshold for the part of
% the image to analyze
% handles.upperThreshold: the upper brightness threshold for the part of
% the image to analyze
% handles.bwContour: the 3D mask
% OUT-CancellousResults.txt: the tab delimited text file containing the
% results
function [hObject,eventdata,handles] = CancellousAnalysis(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        if isfield(handles, 'img')
            % Get the area between the thresholds
            bw = false(size(handles.img));
            handles.img(~handles.bwContour) = 0;
            bw(handles.img > handles.lowerThreshold) = 1;
            bw(handles.img > handles.upperThreshold) = 0;
            % Perform the analysis
            [handles.outCancellous,handles.outHeaderCancellous] = scancoParameterCalculatorCancellous(bw,handles.bwContour,handles.img,handles.info,get(handles.togglebuttonRobustThickness,'Value'));
            if exist(fullfile(handles.pathstr,'CancellousResults.txt'),'file') ~= 2
                % Create the file if it doesn't exist
                fid = fopen(fullfile(handles.pathstr,'CancellousResults.txt'),'w');
                % Write the headers
                for i = 1:length(handles.outHeaderCancellous)
                    fprintf(fid,'%s\t',handles.outHeaderCancellous{i});
                end
                fprintf(fid,'%s\n','Threshold');
            else
                % Append to the file if it does exist
                fid = fopen(fullfile(handles.pathstr,'CancellousResults.txt'),'a');
            end          
            for i = 1:length(handles.outCancellous)                
                if i == length(handles.outCancellous)
                    fprintf(fid,'%s\t',num2str(handles.outCancellous{i}));
                    fprintf(fid,'%s\n',num2str(handles.lowerThreshold)); % After the final value print the lower threshold
                elseif i == 2
                    fprintf(fid,'%s\t',handles.pathstr); % Before the second value add the pathstring   
                    fprintf(fid,'%s\t',num2str(handles.outCancellous{i}));
                else
                    fprintf(fid,'%s\t',num2str(handles.outCancellous{i}));
                end
            end
            fclose(fid);
            guidata(hObject, handles);
        else
            noImgErr();
        end
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end
