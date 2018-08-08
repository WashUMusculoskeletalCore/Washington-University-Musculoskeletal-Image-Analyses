function [hObject,eventdata,handles] = CorticalAnalysis(hObject,eventdata,handles)

try
	set(handles.textBusy,'String','Busy');
	guidata(hObject, handles);
    drawnow();
    
    [x y z] = ind2sub(size(handles.bwContour),find(handles.bwContour));
    xMin = min(x);
    xMax = max(x);
    yMin = min(y);
    yMax = max(y);
    zMin = min(z);
    zMax = max(z);

    handles.img2 = handles.img(xMin:xMax,yMin:yMax,zMin:zMax);
    handles.bwContour = handles.bwContour(xMin:xMax,yMin:yMax,zMin:zMax);

    handles.slice = 1;
    handles.abc = size(handles.img2);
    
	[handles.outCortical,handles.outHeaderCortical,handles.outCorticalContinuous] = scancoParameterCalculatorCortical(handles.img2,handles.bwContour,handles.info,handles.threshold,get(handles.togglebuttonRobustThickness,'Value'));
	[twoDHeader twoDData] = twoDAnalysisSub(handles.img2,handles.info,handles.lowerThreshold,handles.bwContour);
	%print main results
	if exist(fullfile(handles.pathstr,'CorticalResults.txt'),'file') ~= 2
		fid = fopen(fullfile(handles.pathstr,'CorticalResults.txt'),'a');
		for i = 1:length(handles.outHeaderCortical)
			if i == length(handles.outHeaderCortical)
				fprintf(fid,'%s\t',handles.outHeaderCortical{i});
				fprintf(fid,'%s\n','pMOI (mm)');
			else
				fprintf(fid,'%s\t',handles.outHeaderCortical{i});
			end
		end
		fclose(fid);
	end
	fid = fopen(fullfile(handles.pathstr,'CorticalResults.txt'),'a');
	for i = 1:length(handles.outCortical)
		if ~ischar(handles.outCortical{i})
			if i == length(handles.outCortical)
				fprintf(fid,'%s\t',num2str(handles.outCortical{i}));
				fprintf(fid,'%s\n',num2str(twoDData(2) + twoDData(3)));
			else
				fprintf(fid,'%s\t',num2str(handles.outCortical{i}));
			end
		else
			if i == length(handles.outCortical)
				fprintf(fid,'%s\t',handles.outCortical{i});
				fprintf(fid,'%s\n',num2str(twoDData(2) + twoDData(3)));
			else
				fprintf(fid,'%s\t',handles.outCortical{i});
			end
		end
	end
	fclose(fid);
	%Print continuous bone results
	fields = fieldnames(handles.outCorticalContinuous);
	if exist(fullfile(handles.pathstr,'CorticalResultsFullLength.txt'),'file') ~= 2
		fid = fopen(fullfile(handles.pathstr,'CorticalResultsFullLength.txt'),'a');
		fprintf(fid,'%s\t','Path');
		fprintf(fid,'%s\t','Analysis Date');
		for i = 1:numel(fieldnames(handles.outCorticalContinuous))
			if i == numel(fieldnames(handles.outCorticalContinuous))
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
	for i = 1:length(fields)
		var = [];
		eval(['var = handles.outCorticalContinuous.' fields{i} ';']);
		for j = 1:length(var)
			outVarContinuous(j,i) = var(j);
		end
	end
	[a b] = size(outVarContinuous);
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
    clear handles.img2;
	guidata(hObject, handles);
	set(handles.textBusy,'String','Not Busy');
catch
	set(handles.textBusy,'String','Failed');
end