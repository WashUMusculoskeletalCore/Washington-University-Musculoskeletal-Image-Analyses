function [out,outHeader] = scancoParameterCalculatorCancellous(bw,bw2,img,info,robust)
%scancoParameterCalculatorCancellous
% DESC-Calculates all parameters for the cancellous analysis
% IN-bw: A black and white mask of the trabecular structures
% bw2: A black and white mask of the whole metaphyseal compartment being analyzed
% img :The original DICOM images
% info.sliceThickness: The thickness of each slice, in milimeters
% robust: whether or not to use robust thickness
% OUT-out:the list of parameters. Note that Analysis Path is not included
% outHeaders: the list of headers for the output

    
    img(~bw2) = 0;
    %Find bone volume
    BV = length(find(bw)) * info.SliceThickness^3;
    %find total volume
    TV = length(find(bw2)) * info.SliceThickness^3;
    %find BV/TV
    BVTV = BV/TV;

    % Find the ultimate erosion to identify the local maxima in the binary array
    bwUlt = bwulterode(bw);
    % Identify the background of the binary array and the local maxima
    bwBackground = bw2 & ~bw;
    bwBackUlt = bwulterode(bwBackground);
    % Find the distance from the edge for each local maxima in the binary
    % array and background
    D1 = bwdist(bw);
    D2 = bwdist(bwBackground);
    D2(~bw2) = 0;
    D1(~bw2) = 0;
    D2(~bwUlt) = 0;
    D1(~bwBackUlt) = 0;
    
    if robust == 1
        [meanRad,stdRad,~] = calculateThickness(hObject, handles, D2);
        [meanRadSpace,stdRadSpace,~] = calculateThickness(hObject, handles, D1);
    else
        % do foreground structure
        rads = nonzeros(D2); % Find the radii of the spheres at the local maxima
        meanRad = mean(rads);
        stdRad = std(rads);
        % do background structure
        rads = nonzeros(D1);% Find the radii of the spheres at the local maxima
        meanRadSpace = mean(rads);
        stdRadSpace = std(rads);
    end
    % Double radius to convert to diameter, and multiply by
    % SliceThickness to convert to physical units
    TbTh = meanRad * 2 * info.SliceThickness;% mean trabecular thickness
    TbThSTD = stdRad * 2 * info.SliceThickness;% standard deviation of trabecular thicknesses
    TbSp = meanRadSpace * 2 * info.SliceThickness;% mean trabecular spacing
    TbSpSTD = stdRadSpace * 2 * info.SliceThickness;% standard deviation of trabecular spacing

    TN = 1/TbSp; % Trabecular Number

    %find TMD and vBMD
    try
        [densityMatrix , ~] = calculateDensityFromDICOM(info,img);
        TMD = mean(densityMatrix(bw)); % Volumetric Bone Mineral Density       
        vBMD = mean(densityMatrix(bw2)); % Tissue Mineral Density
    catch
        TMD = 0;
        vBMD = 0;
    end

    % Calculate Structural Model Index
    dr = 0.000001;
    shp = shpFromBW(bw,3);
    faces = shp.boundaryFacets;
    vertices = shp.Points;
    vertexNormals = vertexNormal2(vertices,faces);% Calculate vertex normals for expansion
    newVertices = vertices + dr*vertexNormals;% Generate new vertex locations for different mesh
    % Get difference of surface area between meshes
    BS = meshSurfaceArea(vertices,faces);
    dS = meshSurfaceArea(newVertices,faces);
    dS = abs(BS - dS);
    SMI = (6 * BV * (dS/dr)) / BS^2;

    cc = bwconncomp(bw);
    numPixels = cellfun(@numel,cc.PixelIdxList);
    [~,idx] = max(numPixels);
    bw = false(size(bw));
    bw(cc.PixelIdxList{idx}) = true;

    [connectivity , ~] = imEuler3d(bw,26);%calculate Euler characteristic of foreground structure
    ConnD = (1-connectivity) / TV;

    out = {datestr(now),TV,BV,BVTV,ConnD,SMI,TbTh,TbThSTD,TbSp,TbSpSTD,TN,vBMD,TMD,info.SliceThickness};
    outHeader = {'Date Completed',...
        'Analysis Path',...
        'Total Volume (mm^3)',...
        'Bone Volume (mm^3)',...
        'BVTV',...
        'Connectivity',...
        'Structural Model Index',...
        'Mean Trabecular Thickness (mm)',...
        'Trabecular Thickness Standard Deviation (mm)',...
        'Mean Trabecular Spacing (mm)',...
        'Trabecular Spacing Standard Deviation (mm)',...
        'Trabecular Number',...
        'Volumetric Bone Mineral Density (mgHA/cm^3)',...
        'Tissue Mineral Density(mgHA/cm^3)',...
        'Voxel Dimension (mm^3)'...
        'Threshold'...
        };
