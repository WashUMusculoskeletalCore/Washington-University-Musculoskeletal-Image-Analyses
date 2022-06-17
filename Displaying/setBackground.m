% NAME-setBackground
% DESC-if an object has the default background color, change it to the
% chosen value, ensures that the object does not blend in to background
% IN-color: the color to set the background to
% OUT- hObject, the object to change the background color of
function setBackground(hObject, color)
% If this running on is a pc and the current background color is the default
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) 
        set(hObject,'BackgroundColor', color); % Change the background color
end
