% NAME-ExecuteFilter
% DESC-Applies the chosen filter to the image
% IN-handles.popupmenuFilter: the popup menu for choosing the filter
% handles.sigma: the wieght to use for the filters
% handles,radius: the radius to use for the filters
% OUT-handles.img: the filtered image
function [hObject,eventdata,handles] = ExecuteFilter(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        if isfield(handles, 'img')
            % Apply the filter to the image
            switch handles.filter
                case '3D Median'
                    handles.img = uint16(smooth3(handles.img, 'box', [handles.radius handles.radius handles.radius]));
                case '3D Gaussian'
                    handles.img = imgaussfilt3(handles.img, handles.sigma, 'FilterSize', handles.radius);
                case '2D Median'
                    for i = 1:handles.abc(3)
                        handles.img(:,:,i) = medfilt2(handles.img(:,:,i),[handles.radius handles.radius]);
                    end
                case '2D Gaussian'
                    handles.img = imgaussfilt(handles.img, handles.sigma, 'FilterSize', handles.radius);
                case '2D Mean'
                    h = fspecial('average', handles.radius);
                    handles.img = imfilter(handles.img,h);
                case 'Local Standard Deviation'
                    handles.img = stdfilt(handles.img,true([handles.radius handles.radius handles.radius]));
                case 'Range'
                    handles.img = rangefilt(handles.img,true([handles.radius handles.radius handles.radius]));
                case 'Entropy'
                    handles.img = entropyfilt(handles.img,true([handles.radius handles.radius handles.radius]));
            end
            updateImage(hObject, eventdata, handles);
        end
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end