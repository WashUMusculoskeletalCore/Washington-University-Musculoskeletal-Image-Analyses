% NAME-displayPecentLoaded
% DESC-Sets the percent loaded to the chosen value, formated as a
% percentage
% IN-percentage: the percentage formatted as a number between 1 and 0
% OUT-textPercentLoaded-the percentage value displayed as text
function displayPercentLoaded(handles, percentage)
    % Formats as an integer percentage
    set(handles.textPercentLoaded,'String', [sprintf('%u', percentage.*100), ' %']);
    drawnow;
end

