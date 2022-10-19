function FractureCallusVascularity(handles)
    try
        setStatus(handles, 'Busy');
        %[outCallus, outHeaderCallus] = scancoParameterCalculatorCancellousCallus(handles.img > handles.threshold,handles.bwContour,handles.img,handles.info);
        
        %bw is the trabecular structures
        %bw2 is the whole metaphyseal compartment being analyzed
        %img is the original DICOM images
        %info is one of the info structs for metadata

        [~, bwTotal, bwBone] = CropImg(handles.bwContour, handles.img > handles.threshold);

        [BV, TV, BVTV] = BoneVolume(bwBone, bwTotal, handles.info.SliceThickness);
        
        % Identify the background of the binary array
        bwBackground = ~bwBone & bwTotal;
        D1 = bwdist(bwBone) .* bwTotal; 
        D2 = bwdist(bwBackground) .* bwTotal; 
        
        % Foreground structure
        rads = nonzeros(D2);% Find the radii of the spheres at the local maxima
        diams = 2 * rads .* handles.info.SliceThickness;% Convert to diameters and in physical units
        
        TbTh = mean(diams);% Mean structure thickness
        TbThSTD = std(diams);% Standard deviation of structure thicknesses
        
        % Background structure
        bwUlt = bwulterode(bwBackground);
        rads = D1(bwUlt);%find the radii of the spheres at the local maxima
        diams = 2 * rads .* handles.info.SliceThickness;%convert to diameters and in physical units
        
        TbSp = mean(diams);%mean structure thickness
        TbSpSTD = std(diams);%standard deviation of structure thicknesses
        
        TN = 1/TbSp;
        
        %find TMD and vBMD
        if isfield(handles.info,'Private_0029_1004')
            [densityMatrix, ~] = calculateDensityFromDICOM(handles.info, handles.img);
            TMD = mean(densityMatrix(bwBone));
            vBMD = mean(densityMatrix(bwTotal));
        else
            TMD = 0;
            vBMD = 0;
        end
        

        SMI = 0;
        
        cc = bwconncomp(bwBone);
        numPixels = cellfun(@numel,cc.PixelIdxList);
        [~,idx] = max(numPixels);
        bwBone = false(size(bwBone));
        bwBone(cc.PixelIdxList{idx}) = true;
                            
        [connectivity, ~] = imEuler3d(bwBone,26);%calculate Euler characteristic of foreground structure
        ConnD = (1-connectivity) / TV;
        
        out = {TV,...
            BV,...
            BVTV,...
            ConnD,...
            SMI,...
            TbTh,...
            TbThSTD,...
            TbSp,...
            TbSpSTD,...
            TN,...
            vBMD,...
            TMD,...
            handles.info.SliceThickness,...
            [1 ,handles.abc(3)],...
            handles.threshold,...
            handles.radius};
        outHeader = {'Total Volume (mm^3)',...
            'Vessel Volume (mm^3)',...
            'VVTV',...
            'Connectivity',...
            'Structural Model Index',...
            'Mean Vessel Thickness (mm)',...
            'Vessel Thickness Standard Deviation (mm)',...
            'Mean Vessel Spacing (mm)',...
            'Vessel Spacing Standard Deviation (mm)',...
            'Vessel Number',...
            'Volumetric Bone Mineral Density (mgHA/cm^3)',...
            'Tissue Mineral Density(mgHA/cm^3)',...
            'Voxel Dimension (mm^3)',...
            'Slices',...
            'Threshold',...
            'Median Filter Radius'};

        PrintReport(fullfile(handles.pathstr,'CallusResults.txt'), outHeader, out);
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end