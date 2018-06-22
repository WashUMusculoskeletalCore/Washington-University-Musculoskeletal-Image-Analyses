function YMaxForStrain(hObject,eventdata,handles)

[a b c] = size(handles.bwContour);    
for i = 1:c
    % Find position of Centroid
    [I J] = find(handles.bwContour(:,:,i) > 0);
    % I = I .* pixelwidth; %mm (pixels * mm/pixels)
    % J = J .* pixelwidth; %mm
    ycent = mean(I(:));
    xcent = mean(J(:));

    tmp = zeros(size(handles.bwContour(:,:,i)));
    tmp(handles.bwContour(:,:,i)) = 2;
    tmp(~handles.bwContour(:,:,i)) = 1;
    h = figure; imagesc(tmp);
    [x,y] = ginput(2);

    d1 = abs(y(1)-ycent);
    d2 = abs(y(2)-ycent);

    d1 = d1 * handles.info.SliceThickness;
    d2 = d2 * handles.info.SliceThickness;

    msgbox(['D1 for slice ' num2str(i) ' is ' num2str(d1)]);
    msgbox(['D2 for slice ' num2str(i) ' is ' num2str(d2)]);
    
    close(h);
    
end