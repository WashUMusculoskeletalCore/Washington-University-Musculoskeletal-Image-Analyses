function [hObject,eventdata,handles] = SaveWorkspace(hObject,eventdata,handles)

try
    setStatus(hObject, handles, 'Busy');
    fieldNames = fieldnames(handles);
    fieldNum = numel(fieldnames(handles));
    matPath = fullfile(handles.pathstr,'Workspace.mat');
    delete(matPath);
    ct=0;
    % TODO-Make 134 a constant
    for i = 134:fieldNum
        % Skip these 3 fields
        if strcmpi(fieldNames{i},'sliderIMG') == 1
        elseif strcmpi(fieldNames{i},'axesIMG') == 1
        elseif strcmpi(fieldNames{i},'output') == 1
        else
            displayPercentLoaded(hObject, handles, ct/(fieldNum-135));
            % Get value from handles
            eval([fieldNames{i} ' = handles.' fieldNames{i} ';']);
            % Save first field as a new file, append all other fields to
            % the file
            if ct == 0
                save(fullfile(handles.pathstr,'Workspace.mat'),fieldNames{i},'-v7.3','-nocompression');
                ct=ct+1;
            else
                save(fullfile(handles.pathstr,'Workspace.mat'),fieldNames{i},'-append','-nocompression');
                ct=ct+1;
            end
        end
    end
    displayPercentLoaded(hObject, handles, 1);
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end