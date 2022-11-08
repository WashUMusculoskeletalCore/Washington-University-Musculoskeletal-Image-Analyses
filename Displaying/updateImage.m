% NAME-updateImage
% DESC-updates the display of the image and the mask
% IN-handles.img: the 3D image
% handles.bwContour: the 3D mask
% handles.axesIMG: the axes to display the image on
% OUT: displays an image of the current slice
function updateImage(hObject, handles)
    if isfield(handles, 'img')
        if isfield(handles,'bwContour') && handles.toggleMask
            % Show the mask and image blended together
            superimpose(handles, handles.bwContour(:,:,handles.slice));
        else
            % Show just the image
            superimpose(handles);
        end
        impixelinfo(handles.axesIMG);
        guidata(hObject,handles);
    end
end