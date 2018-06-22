function [hObject,eventdata,handles] = TendonFootprint(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    answer = inputdlg('Please type in the name of the mask representing the bone');
    handles.bwBone = eval(['handles.' answer{1}]);
    answer = inputdlg('Please type in the name of the mask representing the tendon');
    handles.bwTendon = eval(['handles.' answer{1}]);
    
    handles.shpBone = shpFromBW(handles.bwBone,3);
    figure
    plot(handles.shpBone);
    title('Surface Reconstruction of Bone');
    handles.shpTendon = shpFromBW(handles.bwTendon,3);
    figure
    plot(handles.shpTendon);
    title('Surface Reconstruction of Tendon');
    figure
    plot(handles.shpBone,'FaceColor','b','LineStyle','none');
    hold on;
    plot(handles.shpTendon,'FaceColor','r','FaceAlpha',0.5,'LineStyle','none');
    title('Combined Plot');
    camlight();
    hold off;
    
    objNo = handles.shpBone.Points;
    objEl = handles.shpBone.boundaryFacets;
    
    volNo = handles.shpTendon.Points;
    volEl = handles.shpTendon.boundaryFacets;
    
    fv.vertices = volNo;
    fv.faces = volEl(:,1:3);
    objFV.vertices = objNo;
    objFV.faces = objEl(:,1:3);
    
    in = inpolyhedron(fv,objFV.vertices);
    
    objFV.vertices = objFV.vertices .* handles.info.SliceThickness;
    fv.vertices = fv.vertices .* handles.info.SliceThickness;
    
    area = 0;
    
    for i = 1:length(objFV.faces)
        nodesMakeFace = objFV.faces(i,1:3);
        areIn = in(nodesMakeFace);
        if length(find(areIn)) == 3
            area = area + triangleArea3d(objFV.vertices(nodesMakeFace(1),:),objFV.vertices(nodesMakeFace(2),:),objFV.vertices(nodesMakeFace(3),:));
            faceColor(i,:) = [255 0 0];
        elseif length(find(areIn)) == 2
            area = area + (2/3) * triangleArea3d(objFV.vertices(nodesMakeFace(1),:),objFV.vertices(nodesMakeFace(2),:),objFV.vertices(nodesMakeFace(3),:));
            faceColor(i,:) = [0 255 0];
        elseif length(find(areIn)) == 1
            area = area + (1/3) * triangleArea3d(objFV.vertices(nodesMakeFace(1),:),objFV.vertices(nodesMakeFace(2),:),objFV.vertices(nodesMakeFace(3),:));
            faceColor(i,:) = [0 0 255];
        else
            faceColor(i,:) = [255 0 255];
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
    
    guidata(hObject, handles);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end