% NAME-YMaxForStrain
% DESC-Allows the user to select a point, then displays the y-distance 
% between those points and the center of mass of the mask.
% IN-handles.bwContour: The 3D mask
% IO: Point selected by user
% OUT-dPix: The distance in pixels, displayed in a message box
% dPhys: The distance in milimeters, displayed in a message box
function YMaxForStrain(handles)
    if isfield(handles, 'bwContour')
        % Find position of Centroid
        [I , ~] = find(handles.bwContour(:,:,handles.slice) > 0);
        if size(I) > 0
            ycent = mean(I(:));
            % Display the center line
            line=yline(handles.axesIMG, ycent, 'Color', 'r');
            % Let the user select a point
            pt = drawpoint(handles.axesIMG);
            % Get y-distance for the point
            dPix = abs(pt.Position(2)-ycent);
            % Convert pixels to physical units
            dPhys = dPix * handles.info.SliceThickness;
            % Open a message and wait for the user to close it
            waitfor(msgbox(['Vertical distance is ' num2str(dPix) ' pixels and ' num2str(dPhys) 'mm']));
            delete(pt);
            delete(line);
        else
            errorMsg();
        end
    else
        noMaskError();
    end