function [hObject,eventdata,handles] = CancellousAnalysis(hObject,eventdata,handles)

try
	setStatus(hObject, handles, 'Busy');
	bw = false(size(handles.img));
	handles.img(~handles.bwContour) = 0;
	bw(handles.img > handles.lowerThreshold) = 1;
	bw(handles.img > handles.upperThreshold) = 0;
	[handles.outCancellous,handles.outHeaderCancellous] = scancoParameterCalculatorCancellous(bw,handles.bwContour,handles.img,handles.info,get(handles.togglebuttonRobustThickness,'Value'));
	if exist(fullfile(handles.pathstr,'CancellousResults.txt'),'file') ~= 2
		fid = fopen(fullfile(handles.pathstr,'CancellousResults.txt'),'w');
        for i = 1:length(handles.outCancellous)
            if i == length(handles.outCancellous) % Determine if this is the final value
				fprintf(fid,'%s\t',handles.outHeaderCancellous{i}); % Write to the file
			else
				fprintf(fid,'%s\t',handles.outHeaderCancellous{i}); % TODO-Can these be combined
            end
        end
        fprintf(fid,'%s\t','Voxel Size');
		fprintf(fid,'%s\n','Threshold');
		fclose(fid);
	end
	for i = 1:length(handles.outCancellous)
        % TODO-Use 1 open and close
		fid = fopen(fullfile(handles.pathstr,'CancellousResults.txt'),'a');
		if i == length(handles.outCancellous)
			fprintf(fid,'%s\t',num2str(handles.outCancellous{i}));
			fprintf(fid,'%s\n',num2str(handles.lowerThreshold)); % For the final value print the lower threshold
        elseif i == 2
            fprintf(fid,'%s\t',handles.pathstr); % For the second value add the pahstring   
            fprintf(fid,'%s\t',num2str(handles.outCancellous{i}));
		else
			fprintf(fid,'%s\t',num2str(handles.outCancellous{i}));
		end
	end
	fclose(fid);
	guidata(hObject, handles);
	setStatus(hObject, handles, 'Not Busy');
catch err
	setStatus(hObject, handles, 'Failed');
    reportError(err);
end
