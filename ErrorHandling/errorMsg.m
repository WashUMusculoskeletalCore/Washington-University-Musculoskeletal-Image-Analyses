% NAME-errorMsg
% DESC-displays an error message to the user
% IN-message: the message to be displayed
% title: the title of the error textbox
% OUT-UI: display an error message textbox
function message = errorMsg(message, title)
    if nargin > 0
        if nargin == 1
            title = 'Error';
        end
    else
        message = 'An error occured';
    end
    errordlg(message, title);
end



