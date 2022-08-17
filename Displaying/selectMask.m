% NAME-selectMask
% DESC-Prompts the user to select a mask from the saved masks by entering a
% name. Asks again if the user does not enter a valid name, throws an error
% if the user exits the dialog box
% IN-handles.savedMasks: The map container containing all saved masks
% prompt: A string prompt to ask to the user
% answer: The user's answer
% OUT: mask: the 3D mask selected
function [mask] = selectMask(handles, prompt)
    answer = inputdlg(prompt);
    while ~isKey(handles.savedMasks, answer{1})
        answer = inputdlg(char('Not a valid saved mask name.', prompt, 'Press X to stop.'));
    end
    mask=handles.savedMasks(answer{1});
end

