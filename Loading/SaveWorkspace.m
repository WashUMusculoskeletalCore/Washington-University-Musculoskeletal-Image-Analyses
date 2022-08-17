% NAME-SaveWorkspace
% DESC-Saves all nongraphics handles fields to a file
% IN-handles.pathstr: the filepath to save to
% handles: all nongraphics fields will be saved
% OUT-Workspace.mat: a file containing all saved fields 
function [hObject,eventdata,handles] = SaveWorkspace(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        fieldNames = fieldnames(handles);
        fieldNum = numel(fieldnames(handles));
        % Add all non-graphic fields to savedHandles
        for i = 1:fieldNum
            if ~any(isgraphics(handles.(fieldNames{i}))) | any(handles.(fieldNames{i}) == 0) %#ok<OR2> % 0 is considered a graphics object by isgraphics
                savedHandles.(fieldNames{i}) = handles.(fieldNames{i});
            end
            displayPercentLoaded(hObject, handles, i/fieldNum);
        end
        % Save all fields in savedHandles to Workspace.mat
        save(fullfile(handles.pathstr,'Workspace.mat'), '-struct', 'savedHandles', '-v7.3','-nocompression');
        displayPercentLoaded(hObject, handles, 1);
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end