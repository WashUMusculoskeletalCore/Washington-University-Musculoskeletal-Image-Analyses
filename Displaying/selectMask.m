%NAME-selectMask
% DESC-Prompts the user to select a mask from the saved masks by entering a
% name. Asks again if the user does not enter a valid name, throws an error
% if the user exits the dialog box
% IN-handles.savedMasks: The map container containing all saved masks
% prompt: A string prompt to ask to the user
% answer: The user's answer
% OUT: mask: the 3D mask selected
function [mask] = selectMask(handles, prompt)
    validAnswer = false;
    answer = inputdlg(prompt);
    while ~validAnswer
        if isempty(answer)
            % If the dialog is canceled or no answer is given throw an error.
            error('ContouringGUI:InputCanceled', 'Input dialog canceled')
        end
        if ~isKey(handles.savedMasks, answer{1})
            % If the answer is not a mask name try again
            answer = inputdlg(char('Not a valid saved mask name.', prompt, 'Press X to stop.'));
        elseif ~isequal(size(handles.savedMasks(answer{1})), handles.abc)
            % If the answer is a mask name, but the mask is the wrong size try again
            answer = inputdlg(char('Mask is not the same size as image.', prompt, 'Press X to stop.'));
        else
            validAnswer = true;
        end
    end
    mask=handles.savedMasks(answer{1});      
end

