% NAME-errorMsg
% DESC-displays an error message to the user
% IN-message: the message to be displayed
% title: the title of the error textbox
% OUT-UI: display an error message textbox
function message = errorMsg(varargin)
    if nargin > 0
        message = varargin{1};
        if nargin > 1
            title=varargin{2};
        else
            title = 'Error';
        end
    else
        message = 'An error occured';
    end
    errordlg(message, title);
end



