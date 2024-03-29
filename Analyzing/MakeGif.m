% NAME-MakeGif
% DESC-Converts the image stack to an animated gif
% IN-handles.img: The 3D image stack
% handles.pathstr: The pathstring to save the file to
% OUT-stack.gif: A gif file of the image stack
function MakeGif(handles)
    try
        setStatus(handles, 'Busy');
        displayPercentLoaded(handles, 0);
        if isfield(handles, 'img')
            [~, ~, c] = size(handles.img);
            filename = fullfile(handles.pathstr,'stack.gif');
            for i = 1:c
                displayPercentLoaded(handles, i/c);
                if i == 1
                    % Create the file
                    imwrite(im2uint8(imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)])),filename,'LoopCount',Inf,'DelayTime',0.01);
                else
                    % Append the next slice to the file
                    imwrite(im2uint8(imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)])),filename,'WriteMode','append','DelayTime',0.01);
                end
            end
        else
            noImgError();
        end
        displayPercentLoaded(handles, 1);
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end