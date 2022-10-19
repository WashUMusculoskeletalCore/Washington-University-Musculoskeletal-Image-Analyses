function updateThreshold(hObject, handles)
    if isfield(handles, 'img')
        % Update the upper and lower threshold
        if handles.moveLower
            handles.lowerThreshold = handles.threshold;
            set(handles.textLowerThreshold,'String',num2str(handles.lowerThreshold));
        elseif handles.moveUpper
            handles.upperThreshold = handles.threshold;
            set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
        end
            
        % Display the area currently within the threshold
        if handles.moveUpper
            lowThresh = handles.lowerThreshold;
        else
            lowThresh = handles.threshold;
        end
        highThresh = handles.upperThreshold;
        thresh = false(size(handles.img(:,:,handles.slice)));
        thresh(handles.img(:,:,handles.slice) >= lowThresh) = 1;
        thresh(handles.img(:,:,handles.slice) > highThresh) = 0;
        superimpose(handles, thresh);
        guidata(hObject, handles)
    end
end

