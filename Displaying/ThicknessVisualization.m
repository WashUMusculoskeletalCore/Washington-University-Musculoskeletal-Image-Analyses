% NAME-ThicknessVisualization
% DESC-Creates a 3D visualization showing the thickness of different parts
% of the mask
% IN-handles.bwContour: the 3D mask
% OUT-Creates a 3D image showing the relative thickness of each section
% of the mask
% TODO-look into this deeper for potential optimization
function ThicknessVisualization(hObject, handles)
    try
        setStatus(hObject, handles, 'Busy');
        bw = handles.bwContour;
        % Create distance map
        D1 = bwdist(~bw);% does what I want for thickness of spacing
        % Find local maximums
        bwUlt = bwulterode(bw);
        % Limit distance map to local maximums
        D1(~bwUlt) = 0;
        D1 = findSpheres(hObject, handles, D1);
        % Get a 21x21x3 set of points that form the surface of a sphere with radius 1
        [x, y, z] = sphere;
        [x2, y2, z2] = ind2sub(size(D1),find(D1));
        % Get the all nonzero values in D1 
        rads = nonzeros(D1);
        shp = shpFromBW(bw,3);
        % Create the visualization
        figure;
        plot(shp,'FaceColor','w','LineStyle','none');
        alpha(gca,0.4);
        camlight;
        hold on;
        % Find the range of all radii and convert it to a scale of 256
        % values
        rangeRads = max(rads) - min(rads);
        binRads = rangeRads / 256;
        if rangeRads == 0
            bin(1) = 0;
            bin(2) = max(rads);
            trans = [1 1];
        else
            bin=zeros(1, 255);
            trans=zeros(1, 255);
            for i = 1:255
                bin(i) = binRads * i;
                trans(i) = i/255;
            end
        end
        if length(bin) > 256
            map = colormap(jet(256));
        else
            map = colormap(jet(length(bin)));
        end
        for i = 1:length(find(D1))
            for j = 2:length(bin)
                if rads(i)-min(rads) > bin(j-1) && rads(i)-min(rads) <= bin(j)
                    surf(x*rads(i)+x2(i), y*rads(i)+y2(i), z*rads(i)+z2(i),'FaceColor',map(j-1,:),'FaceAlpha',trans(j),'LineStyle','none');
                    axis tight;
                    drawnow();
                end
            end
        end
        saveas(gcf,fullfile(handles.pathstr,[get(handles.editDICOMPrefix,'String') '.fig']));
        guidata(hObject, handles);
        setStatus(hObject, handles, 'Not Busy');
    catch err
            setStatus(hObject, handles, 'Failed');
            reportError(err);
    end
