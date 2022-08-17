% NAME-abcResize
% DESC-performs all neccessary changes whenever the image size changes
% IN-handles.img: the resized image
% OUT-handles.abc: the 3D dimensions of the image
function [hObject, handles] = abcResize(hObject, handles)
    if isfield(handles, 'abc')
        prevABC = handles.abc;
    else
        prevABC = [0 0 0];
    end
    handles.abc = size(handles.img, [1 2 3]);
    if handles.abc(1) ~= prevABC(1)
        % Move primitive center to center of image
        handles.primitiveHorizontal = round(handles.abc(1)/2);
        set(handles.editPrimitiveHorizontal, 'String', num2str(handles.primitiveHorizontal));
    end
    if handles.abc(2) ~= prevABC(2)
        handles.primitiveVertical = round(handles.abc(2)/2);
        set(handles.editPrimitiveVertical, 'String', num2str(handles.primitiveVertical));
    end
    if handles.abc(3) ~= prevABC(3)
        % Adjust the slice slider
        handles.slice=1;
        set(handles.editSliceNumber,'String', '1');
        handles.sliderIMG = resizeSlider(handles.sliderIMG, handles.abc(3));
        if  ~isfield(handles, 'endMorph') || handles.endMorph > handles.abc(3)
            handles.endMorph = handles.abc(3);
            (set(handles.editEndMorph,'String', num2str(handles.endMorph)));
        end
    end
end

