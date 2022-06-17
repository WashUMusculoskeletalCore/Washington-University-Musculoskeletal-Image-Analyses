function [hObject,eventdata,handles] = MakeGif(hObject,eventdata,handles)

try
    setStatus(hObject, handles, 'Busy');
    [~, ~, c] = size(handles.img);
    filename = fullfile(handles.pathstr,'stack.gif');
    for i = 1:c
        displayPercentLoaded(hObject, handles, i/c);
        if i == 1
            imwrite(im2uint8(imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)])),filename,'LoopCount',Inf,'DelayTime',0.01);
        else
            imwrite(im2uint8(imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)])),filename,'WriteMode','append','DelayTime',0.01);
        end
    end
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end