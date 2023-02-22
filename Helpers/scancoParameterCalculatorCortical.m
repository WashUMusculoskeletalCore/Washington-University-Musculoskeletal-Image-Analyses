% NAME-scancoParameterCalculatorCortical
% DESC-Calculates parameters for cortical bone analysis report
% IN-img: The 3D image of bone, should be taller than the thickest object
% needing to be analyzed
% bw: The black and white mask representing only the bone (not the 
% medullary cavity) with pores covered
% info: The struct containing DICOM info
% threshold: the lower brightness threshold, used to delineate bone
% OUT-out: the parameters for the report
% outHeader: the headers for the report
% out2: the parameters for the continuous report
function [out,outHeader,out2,outHeader2] = scancoParameterCalculatorCortical(handles, img, bw,info,threshold,robust)
    displayPercentLoaded(handles, 0);
    % Get the number of slices
    [~, ~, c] = size(bw);

    % Isolate the largest component of the mask
    bw = bwBiggest(bw);
    img(~bw) = 0;

    bwPorosity = img > threshold;
    BV = nnz(bwPorosity) * info.SliceThickness^3; % Bone Volume

    bwFilled = false(size(bw));
    for i = 1:c
        bwFilled(:,:,i) = imfill(imclose(bw(:,:,i),strel('disk',5,0)),'holes');
        displayPercentLoaded(handles, i/(5*c));
    end
    TV = nnz(bwFilled) * info.SliceThickness^3; % Total Volume

    BAr = BV / (c*info.SliceThickness); % Bone Area
    MAr = (TV - BV) / (c*info.SliceThickness); % Medullary Area
    TAr = TV / (c*info.SliceThickness); % Total Area

    porosity = 1 - (nnz(bwPorosity) / length(find(bw)));

    displayPercentLoaded(handles, 2/5);

    % Find the ultimate erosion to identify the local maxima in the binary array
    cc = bwconncomp(bw);
    numPixels = cellfun(@numel,cc.PixelIdxList);
    [~,idx] = max(numPixels);
    bw = false(size(bw));
    bw(cc.PixelIdxList{idx}) = true;
    bwUlt = bwulterode(bw);

    %identify the background of the binary array
    bwBackground = ~bw;
    dist = bwdist(bwBackground);% Get the distance from the edges

    displayPercentLoaded(handles, 3/5);

    if robust == 1
        [meanRad,stdRad,~] = calculateThickness(handles, dist);
        TbTh = meanRad * 2 * info.SliceThickness;
        TbThSTD = stdRad * 2 * info.SliceThickness;
    else
        % Do foreground structure
        rads = dist(bwUlt);% Find the radii of the spheres at the local maxima
        diams = 2 * rads .* info.SliceThickness;% Convert to diameters and in physical units
        TbTh = mean(diams);% Mean structure thickness
        TbThSTD = std(diams);% Standard deviation of structure thicknesses
    end


    % Find TMD(Tissue Mineral Density)
    if isfield(info,'Private_0029_1004')
        [densityMatrix , ~] = calculateDensityFromDICOM(info,img);
        TMD = mean(densityMatrix(bwPorosity));
    else
        TMD = 0;
    end

    if isfield(info, 'Filename')
        file=info.Filename;
    else
        file=info.File;
    end

    out = {datestr(now),...
        file,...
        TbTh,...
        TbThSTD,...
        TMD,...
        porosity,...
        TAr,...
        BAr,...
        MAr,...
        1,...
        c,...
        info.SliceThickness,...
        threshold};

    outHeader = {'Date Analysis Performed',...
        'File ID',...
        'Mean Cortical Thickness (mm)',...
        'Cortical Thickness Standard Deviation (mm)',...
        'Tissue Mineral Density(mgHA/cm^3)',...
        'Porosity',...
        'Total Area (mm^2)',...
        'Bone Area (mm^2)',...
        'Medullary Area (mm^2)',...
        'Start Slice',...
        'Stop Slice',...
        'Voxel Dimension (mm)',...
        'Lower Threshold',...
        'pMOI (mm)'};
    
    outHeader2 = {'Date Analysis Performed',...
        'File ID',...
        'Bone Volume mm^3',...
        'Bone Area (mm^2)',...
        'Medullary Area (mm^2)',...
        'Total Area (mm^2)',...
        'Volumetric Bone Density(mgHA/cm^3)',...
        'Tissue Mineral Density(mgHA/cm^3)',...
        'Mean Cortical Thickness (mm)',...
        'Cortical Thickness Standard Deviation (mm)',...
        'Porosity'};

    displayPercentLoaded(handles, 4/5);

    % Divide the image into bins of slices and calculate parameters for
    % each bin
    
    % Give each bin a size of aproximately 0.1mm
    slicesPerBin = round(0.1 / info.SliceThickness);
    if c < slicesPerBin
        % If there is only one bin, reuse values
        out2 = {BV, BAr, MAr, TAr, 0, TMD,TbTh, TbThSTD, porosity};
        displayPercentLoaded(handles, 1);
        return
    end
    % Preallocate all arrays
    zers = zeros(1, ceil(c/slicesPerBin));
    BV2 = zers;
    TV2 = zers;
    BAr2 = zers;
    MAr2 = zers;
    TAr2 = zers;
    porosity2 = zers;
    meanRad2 = zers;
    stdRad2 = zers;
    TbTh2 = zers;
    TbThSTD2 = zers;
    TMD2= zers;
    vBMD2 = zers;

    ct=0;
    for i = 1:slicesPerBin:c
        ct=ct+1;
        % Get the current bin of slices
        if i+slicesPerBin < c
            bw2 = bw(:,:,i:i+slicesPerBin);
            img2 = img(:,:,i:i+slicesPerBin);
        else
            bw2 = bw(:,:,i:end);
            img2 = img(:,:,i:end);
        end
        img2(~bw2) = 0;
        bwPorosity = img2 > threshold;
        BV2(ct) = length(find(bwPorosity)) * info.SliceThickness^3; % Bone Volume
        [~, ~, c1] = size(bw2);
        bwFilled2=false(size(bw2));
        for j = 1:c1
            bwFilled2(:,:,j) = imfill(imclose(bw2(:,:,j),strel('disk',5,0)),'holes');
        end
        TV2(ct) = nnz(bwFilled2) * info.SliceThickness^3; % Total Volume
        BAr2(ct) = BV2(ct) / (c1*info.SliceThickness); % Bone Area
        MAr2(ct) = (TV2(ct) - BV2(ct)) / (c1*info.SliceThickness); % Medullary Area
        TAr2(ct) = TV2(ct) / (c1*info.SliceThickness); % Total Area
        porosity2(ct) = 1 - (length(bwPorosity) / length(find(bw2)));
        % Find the ultimate erosion to identify the local maxima in the binary array
        bw2 = bwBiggest(bw2);
        bwUlt = bwulterode(bw2);
        D1 = bwdist(~bw2);
        D1(~bwUlt) = 0;

        if robust == 1
            [meanRad2(ct),stdRad2(ct)] = calculateThickness(handles, D1);
            TbTh2(ct) = meanRad2(ct) * 2 * info.SliceThickness;% Mean structure thickness
            TbThSTD2(ct) = stdRad2(ct) * 2 * info.SliceThickness;% Standard deviation of structure thicknesses
        else
            % Do foreground structure
            rads = D1(bwUlt);% Find the radii of the spheres at the local maxima
            diams = 2 * rads .* info.SliceThickness;% Convert to diameters and in physical units
            TbTh2(ct) = mean(diams);% Mean structure thickness
            TbThSTD2(ct) = std(diams);% Standard deviation of structure thicknesses
        end

        TMD2(ct) = 0; % Tissue Mineral Density
        vBMD2(ct) = 0; % Volumetric Bone Mineral Density
        if isfield(info,'Private_0029_1004')
            [densityMatrix , ~] = calculateDensityFromDICOM(info,img2);
            TMD2(ct) = mean(densityMatrix(bwPorosity)); % Tissue Mineral Density
            if ~isempty(find(bwFilled2, 1))
                vBMD2(ct) = mean(densityMatrix(bwFilled2));
            end
        end
        displayPercentLoaded(handles, (4/5)+i/(c*5))
    end
    out2 = {BV2, BAr2, MAr2, TAr2, vBMD2, TMD2,TbTh2, TbThSTD2, porosity2};
    displayPercentLoaded(handles, 1);