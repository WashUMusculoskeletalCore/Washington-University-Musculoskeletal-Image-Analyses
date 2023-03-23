function [out,outHeader] = scancoParameterCalculatorCancellous(handles,bw,bw2,img,info,robust)
%scancoParameterCalculatorCancellous
% DESC-Calculates all parameters for the cancellous analysis
% IN-bw: A black and white mask of the trabecular structures
% bw2: A black and white mask of the whole metaphyseal compartment being analyzed
% img :The original DICOM images
% info.sliceThickness: The thickness of each slice, in milimeters
% robust: whether or not to use robust thickness
% OUT-out:the list of parameters. Note that Analysis Path is not included
% outHeaders: the list of headers for the output

    displayPercentLoaded(handles, 0);

    [BV, TV, BVTV] = BoneVolume(bw, bw2, info.SliceThickness);

    
    % Identify the background of the binary array
    bwBackground = bw2 & ~bw;
    % Find the distance from the edge for each point in the binary
    % array and background
    D1 = bwdist(bw);
    D2 = bwdist(bwBackground);
    D2(~bw2) = 0;
    D1(~bw2) = 0;
    

    displayPercentLoaded(handles, 1/5);

    if robust == 1        
        [meanRad,stdRad,~] = calculateThickness(D2);
        [meanRadSpace,stdRadSpace,~] = calculateThickness(D1);
    else
        % Find the ultimate erosion to identify the local maxima in the
        % binary array
        bwUlt = bwulterode(bw);
        bwBackUlt = bwulterode(bwBackground);
        D2(~bwUlt) = 0;
        D1(~bwBackUlt) = 0;
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

    displayPercentLoaded(handles, 2/5);

    %find TMD and vBMD
    try
        [densityMatrix , ~] = calculateDensityFromDICOM(info,img);%.*uint16(bw2));
        TMD = mean(densityMatrix(bw), 'all'); % Tissue Mineral Density      
        vBMD = mean(densityMatrix(bw2), 'all' ); % Volumetric Bone Mineral Density
    catch
        TMD = 0;
        vBMD = 0;
    end
    
    displayPercentLoaded(handles, 3/5);

    % Calculate Structural Model Index
    dr = 0.000001;
    [X,Y,Z]=meshgrid(1:size(bw,2),1:size(bw,1),1:size(bw,3));
    [faces, vertices] = MarchingCubes(X,Y,Z,double(bw), 0.99999999999);
    if isempty(faces)
        error('ContouringGUI:InputError', 'Mask must form a 3D shape.')
    end
    
    vertexNormals = vertexNormal2(vertices,faces);% Calculate vertex normals for expansion
    newVertices = vertices + dr*vertexNormals;% Generate new vertex locations for different mesh
    % Get difference of surface area between meshes
    BS = meshSurfaceArea(vertices,faces)*info.SliceThickness^2;
    dS = meshSurfaceArea(newVertices,faces)*info.SliceThickness^2;
    dS = dS - BS;
    dr = dr*info.SliceThickness;
    SMI = (6 * BV * (dS/dr)) / BS^2;

    displayPercentLoaded(handles, 4/5)

    % Clean any isolated holes and bone
    cc = bwconncomp(bwBackground, 6);
    numPixels = cellfun(@numel,cc.PixelIdxList);
    [~,idx] = max(numPixels);
    bw = bw2;
    bw(cc.PixelIdxList{idx}) = false;


    cc = bwconncomp(bw, 26);
    numPixels = cellfun(@numel,cc.PixelIdxList);
    [~,idx] = max(numPixels);
    bw = false(size(bw));
    bw(cc.PixelIdxList{idx}) = true;


    [chi , ~] = imEuler3d(bw,6);%calculate Euler characteristic
    ConnD = (1-chi) / TV;

    % Compile output and headers
    out = {datestr(now),handles.pathstr,TV,BV,BVTV,ConnD,SMI,TbTh,TbThSTD,TbSp,TbSpSTD,TN,vBMD,TMD,info.SliceThickness,handles.lowerThreshold};
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
        'Voxel Dimension (mm)'...
        'Threshold'...
        };
        displayPercentLoaded(handles, 1);