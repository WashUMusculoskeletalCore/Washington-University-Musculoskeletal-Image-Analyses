% NAME-TendonFootprint
function TendonFootprint(handles)
    try
        setStatus(handles, 'Busy');
        try
            bwBone = selectMask(handles, 'Please type in the name of the mask representing the bone');      
            bwTendon = selectMask(handles, 'Please type in the name of the mask representing the tendon');
            shpBone = shpFromBW(bwBone,3);
            shpTendon = shpFromBW(bwTendon,3);
        catch err
            error('User exited without selecting a mask.');
        end
        answer = inputdlg('Show 3D figure? y/n');
        if isempty(answer)
            error('ContouringGUI:InputCanceled', 'Input dialog canceled');
        end
        if answer{1} =='y'
        % Plot bone shape
            
            figure
            plot(shpBone);
            title('Surface Reconstruction of Bone');
            % Plot tendon shape
            
            figure
            plot(shpTendon);
            title('Surface Reconstruction of Tendon');
            figure
            plot(shpBone,'FaceColor','b','LineStyle','none');
            hold on;
            plot(shpTendon,'FaceColor','r','FaceAlpha',0.5,'LineStyle','none');
            title('Combined Plot');
            camlight();
            hold off;
        end
        objNo = shpBone.Points;
        objEl = shpBone.boundaryFacets;

        volNo = shpTendon.Points;
        volEl = shpTendon.boundaryFacets;

        fv.vertices = volNo;
        fv.faces = volEl(:,1:3);
        objFV.vertices = objNo;
        objFV.faces = objEl(:,1:3);

        % TODO-this function does not seem to be implemented, function may be broken 
        in = inpolyhedron(fv, objFV.vertices);

        objFV.vertices = objFV.vertices .* handles.info.SliceThickness;
        fv.vertices = fv.vertices .* handles.info.SliceThickness;

        area = 0;
        % TODO-look at output
        faceColor = zeros(length(objFv.faces), 3);
        for i = 1:length(objFV.faces)
            nodesMakeFace = objFV.faces(i,1:3);
            areIn = in(nodesMakeFace);
            if length(find(areIn)) == 3
                area = area + triangleArea3d(objFV.vertices(nodesMakeFace(1),:),objFV.vertices(nodesMakeFace(2),:),objFV.vertices(nodesMakeFace(3),:));
                faceColor(i,:) = [255 0 0];% Red
            elseif length(find(areIn)) == 2
                area = area + (2/3) * triangleArea3d(objFV.vertices(nodesMakeFace(1),:),objFV.vertices(nodesMakeFace(2),:),objFV.vertices(nodesMakeFace(3),:));
                faceColor(i,:) = [0 255 0];% Blue
            elseif length(find(areIn)) == 1
                area = area + (1/3) * triangleArea3d(objFV.vertices(nodesMakeFace(1),:),objFV.vertices(nodesMakeFace(2),:),objFV.vertices(nodesMakeFace(3),:));
                faceColor(i,:) = [0 0 255];% Green
            else
                faceColor(i,:) = [255 0 255];% Yellow
            end
        end

        stlwrite(fullfile(handles.pathstr,'ColorBinary.stl'),objFV,'mode','binary','facecolor',faceColor);
        stlwrite(fullfile(handles.pathstr,'Ascii.stl'),objFV,'mode','ascii');
        stlwrite(fullfile(handles.pathstr,'Volume.stl'),fv,'mode','ascii');

        header = {'DICOM path', 'Area of object contained in volume (mm)'};
        fid = fopen(fullfile(handles.pathstr,'TendonSurfaceArea.txt'),'w');
        fprintf(fid,'%s\t',header{1});
        fprintf(fid,'%s\n',header{2});

        fprintf(fid,'%s\t',handles.pathstr);
        fprintf(fid,'%s\n',num2str(area));
        fclose(fid);

        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles)
    end