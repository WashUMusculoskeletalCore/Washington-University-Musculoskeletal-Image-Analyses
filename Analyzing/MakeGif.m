function [hObject,eventdata,handles] = MakeGif(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    [a b c] = size(handles.img);
    filename = fullfile(handles.pathstr,'stack.gif');
    for i = 1:c
        set(handles.textPercentLoaded,'String',num2str(i/c));
        drawnow();
        if i == 1
            imwrite(im2uint8(imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)])),filename,'LoopCount',Inf,'DelayTime',0.01);
        else
            imwrite(im2uint8(imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)])),filename,'WriteMode','append','DelayTime',0.01);
        end
    end
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end