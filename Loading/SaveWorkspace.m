% NAME-SaveWorkspace
% DESC-Saves all nongraphics handles fields to a file
% IN-handles.pathstr: the filepath to save to
% handles: all nongraphics fields will be saved
% OUT-Workspace.mat: a file containing all saved fields 
function SaveWorkspace(handles)
    try
        setStatus(handles, 'Busy');
        displayPercentLoaded(handles, 0);
        fieldNames = fieldnames(handles);
        fieldNum = numel(fieldnames(handles));
        % Add all non-graphic fields to savedHandles
        setStatus(handles, 'Reading Workspace Data')
        for i = 1:fieldNum
            if ~any(isgraphics(handles.(fieldNames{i}))) | any(handles.(fieldNames{i}) == 0) %#ok<OR2> % 0 is considered a graphics object by isgraphics
                savedHandles.(fieldNames{i}) = handles.(fieldNames{i});
            end
            displayPercentLoaded(handles, i/(2*fieldNum));
        end
        % Save all fields in savedHandles to Workspace.mat
        setStatus(handles, 'Writing file');
        save(fullfile(handles.pathstr,'Workspace.mat'), '-struct', 'savedHandles', '-v7.3','-nocompression');
        displayPercentLoaded(handles, 1);
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end