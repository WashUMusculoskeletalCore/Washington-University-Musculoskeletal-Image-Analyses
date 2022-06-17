% NAME-displayPecentLoaded
% DESC-Sets the percent loaded to the chosen value, formated as a
% percentage
% IN-percentage: the percentage formatted as a number between 1 and 0
% OUT-textPercentLoaded-the percentage value displayed as text
function displayPercentLoaded(hObject, handles, percentage)
    % Formats as a percentage with three decimal places to the right of the decimal point
    set(handles.textPercentLoaded,'String', [sprintf('%0.3f', percentage.*100), ' %']);
    guidata(hObject, handles);
    drawnow;
end

