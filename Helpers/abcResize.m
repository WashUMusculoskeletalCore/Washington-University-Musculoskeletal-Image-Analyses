% NAME-abcResize
% DESC-performs all neccessary changes whenever the image size changes
% IN-handles.img: the resized image
% OUT-handles.abc: the 3D dimensions of the image
function [handles, hObject] = abcResize(handles, hObject)
    prevABC = handles.abc;
    handles.abc = size(handles.img, [1 2 3]);
    if handles.abc(1) ~= prevABC(1)
        % Move primitive center to center of image
        handles.primitiveCenter(1) = round(handles.abc(1)/2);
        set(handles.editPrimitiveHorizontal, 'String', num2str(handles.primitiveCenter(1)));
    end
    if handles.abc(2) ~= prevABC(2)
        handles.primitiveCenter(2) = round(handles.abc(2)/2);
        set(handles.editPrimitiveVertical, 'String', num2str(handles.primitiveCenter(2)));
    end
    if handles.abc(3) ~= prevABC(3)
        % Adjust the slice slider
        handles.slice=1;
        set(handles.editSliceNumber,'String', '1');
        handles.sliderIMG = resizeSlider(handles.sliderIMG, handles.abc(3));
    end
    guidata(hObject, handles);
end

