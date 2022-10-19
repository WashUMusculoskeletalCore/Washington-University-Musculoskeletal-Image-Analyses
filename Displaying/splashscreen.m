% NAME-splashscreen
% DESC-Displays a splashscreen for 5 seconds or until the user clicks on it
% IN-hObject: The object creating the splashsceen
% OUT-hObject: Sets the calling object's position to the splashscreen's position
function hObject = splashscreen(hObject)
    % Display splashscreen
    splashscreen = imread('Splashscreen.jpg');
    f=figure(MenuBar="none",ToolBar="none",WindowStyle="modal", NumberTitle=hObject.NumberTitle, ...
        Name=hObject.Name, Units=hObject.Units, Position=hObject.Position, WindowButtonDownFcn={@deleteCallback, hObject});
    axes(Units="normalized", Position=[0 0 1 1]);
    imshow(splashscreen);
    t = timer(StartDelay=5, TasksToExecute=1, TimerFcn={@timerDeleteCallback, f, hObject});
    start(t);
    waitfor(f);
end

% NAME-deleteCallback
% DESC-Called when the splashscreen is clicked, closes the splashscreen
function deleteCallback(src, ~, hObject)
    closeSplashscreen(src, hObject);
end

% NAME-timerDeleteCallback
% DESC-Called when the splashscreen timer expires, closes the splashscreen
function timerDeleteCallback(~, ~, f, hObject)
    if ishandle(f)
        closeSplashscreen(f, hObject);
    end
end

% NAME-closeSplashscreen
% DESC-closes the splashscreen
% IN-screen: The splashscreen
% app: The application that created the splashscreen
% OUT-app: Sets the position to match the splashscreen
function closeSplashscreen(screen, app)
    app.Position = screen.Position;
    app.WindowState = screen.WindowState;
    close(screen);
end