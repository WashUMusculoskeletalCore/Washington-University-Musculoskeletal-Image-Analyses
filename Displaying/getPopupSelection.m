% NAME-getPopupSelection
% DESC-gets the value seleceted from a popup menu
% IN-menu: the popup menu
% OUT-selection: the string option selected from the menu
function selection = getPopupSelection(menu)
    str=get(menu, 'String');
    val=get(menu, 'Value');
    if isempty(str)
        selection = '';
    else
        selection = str{val};
    end
end

