% NAME-Translate
% DESC-shifts the mask in the desired direction
% IN-handles.translateUp: the distance to travel if translating up
% handles.translateDown: the distance to travel if translating down
% handles.translateLeft: the distance to travel if translating left
% handles.translateRight: the distance to travel if translating right
% direction: the direction to translate in, options are 'Up', 'Down',
% 'Left', and 'Right'
% OUT-handles.bwContour: the mask to be translated
function [hObject,eventdata,handles] = Translate(hObject, eventdata, handles, direction)
    if isfield(handles, 'bwContour')
        [row, col] = find(handles.bwContour(:,:,handles.slice));
        switch direction
            case 'Up'
                row = row - handles.translateUp;
            case 'Down'
                row = row + handles.translateDown;
            case 'Left'
                col = col - handles.translateLeft;
            case 'Right'
                col = col + handles.translateRight;
            otherwise
                disp('Invalid direction');
        end 
        tmp = false(size(handles.bwContour(:, :, handles.slice)));
        for i = 1:length(row)
            tmp(row(i), col(i)) = 1;
        end

        %cent = [round(mean(row)) round(mean(col))];
        %set(handles.textCenterLocation,'String',[num2str(cent(1)) ' ' num2str(cent(2))]);

        handles.bwContour(:,:,handles.slice) = tmp;

        updateImage(hObject, eventdata, handles);
    end
end

