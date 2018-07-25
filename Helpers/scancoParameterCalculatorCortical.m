function [out,outHeader,out2] = scancoParameterCalculatorCortical(img,bw,info,threshold,robust)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Expects img to be the slice stack you want to analyze (be sure it's
%%taller than the thickest object you want to analyze), bw is a mask
%%representing ONLY the bone (not the medullary cavity) with pores covered, info is a single
%%info struct from dicominfo, and the threshold is what you're using to
%%delineate bone.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%find start slice
[a b c] = size(bw);
start = 1;
stop = c;

bw = bwBiggest(bw);
img(~bw) = 0;

bwPorosity = img > threshold;
BV = length(find(bwPorosity)) * info.SliceThickness^3;

% bw = imclose(bw,true(5,5,5));
[a b c] = size(bw);
bwFilled = false(size(bw));
for i = 1:c
    bwFilled(:,:,i) = imfill(imclose(bw(:,:,i),strel('disk',5,0)),'holes');
end
TV = length(find(bwFilled)) * info.SliceThickness^3;
BVTV = BV/TV;

BAr = BV / (c*info.SliceThickness);
MAr = (TV - BV) / (c*info.SliceThickness);
TAr = TV / (c*info.SliceThickness);

valuesPorosity = find(img(find(bwPorosity)) > threshold);
porosity = 1 - (length(valuesPorosity) / length(find(bw)));

%find the ultimate erosion to identify the local maxima in the binary array
cc = bwconncomp(bw);
numPixels = cellfun(@numel,cc.PixelIdxList);
[biggest,idx] = max(numPixels);
bw = false(size(bw));
bw(cc.PixelIdxList{idx}) = true;
% stats = regionprops(bw,'BoundingBox');
bwForLargeCalculations = bw;
bwUlt = bwulterode(bwForLargeCalculations);

%identify the background of the binary array
bwBackground = ~bwForLargeCalculations;
%     D1 = bwdistsc(bw);%does what I want for thickness of spacing
% try
%     D2 = bwdist(gpuArray(bwBackground));
%     D2 = gather(D2);
% catch
    D2 = bwdist(bwBackground);%does what I want for thickness of structures
% end
%D2(~bwUlt) = 0;

if robust == 1
    [meanRad,stdRad,D2] = calculateThickness(D2,7);
    TbTh = meanRad * 2 * info.SliceThickness;
    TbThSTD = stdRad * 2 * info.SliceThickness;
else
    %do foreground structure
    rads = D2(find(bwUlt));%find the radii of the spheres at the local maxima
    [r c v] = ind2sub(size(bwUlt),find(bwUlt));
    xyzUlt = [r c v];%find xyz coords of the local maxima
    xyzUlt = xyzUlt .* info.SliceThickness;%convert to physical units
    diams = 2 * rads .* info.SliceThickness;%convert to diameters and in physical units
    TbTh = mean(diams);%mean structure thickness
    TbThSTD = std(diams);%standard deviation of structure thicknesses
end

%find TMD and vBMD
clear bwBackground bwUlt bb xyzUlt

if isfield(info,'Private_0029_1004')
    [densityMatrix junk] = calculateDensityFromDICOM(info,img);
    clear junk;
    TMD = mean(densityMatrix(find(bwPorosity)));
    vBMD = mean(densityMatrix(find(bwFilled)));
else
    TMD = 0;
    cBMD = 0;
end

try
out = {datestr(now),...
    info.Filename,...
    TbTh,...
    TbThSTD,...
    TMD,...
    porosity,...
    TAr,...
    BAr,...
    MAr,...
    start,...
    stop,...
    info.SliceThickness,...
    threshold};
catch
    out = {datestr(now),...
    info.File,...
    TbTh,...
    TbThSTD,...
    TMD,...
    porosity,...
    TAr,...
    BAr,...
    MAr,...
    start,...
    stop,...
    info.SliceThickness,...
    threshold};
end
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
    'Voxel Dimension (mm^3)',...
    'Lower Threshold'};

[a b c] = size(bw);
slicesPerBin = round(0.1 / info.SliceThickness);
if c < slicesPerBin
    return
end
ct=0;
for i = 1:slicesPerBin:c
    ct=ct+1;
    try
        bw2 = bw(:,:,i:i+slicesPerBin);
        img2 = img(:,:,i:i+slicesPerBin);
    catch
        bw2 = bw(:,:,i:end);
        img2 = img(:,:,i:end);
    end
    img2(~bw2) = 0;
    bwPorosity = img2 > threshold;
    BV2(ct) = length(find(bwPorosity)) * info.SliceThickness^3;
    [a1 b1 c1] = size(bw2);
    clear bwFilled2;
    for j = 1:c1
        bwFilled2(:,:,j) = imfill(imclose(bw2(:,:,j),strel('disk',5,0)),'holes');
    end
    TV2(ct) = length(find(bwFilled2)) * info.SliceThickness^3;
    BAr2(ct) = BV2(ct) / (c1*info.SliceThickness);
    MAr2(ct) = (TV2(ct) - BV2(ct)) / (c1*info.SliceThickness);
    TAr2(ct) = TV2(ct) / (c1*info.SliceThickness);
    porosity2(ct) = 1 - (length(bwPorosity) / length(find(bw2)));
    bw2 = bwBiggest(bw2);
    bwUlt = bwulterode(bw2);
    D1 = bwdist(~bw2);
    D1(~bwUlt) = 0;
    
    if robust == 1
        [meanRad2(ct),stdRad2(ct)] = calculateThickness(D1,7);
        TbTh2(ct) = meanRad2(ct) * 2 * info.SliceThickness;
        TbThSTD2(ct) = stdRad2(ct) * 2 * info.SliceThickness;
    else
        %do foreground structure
        rads = D1(find(bwUlt));%find the radii of the spheres at the local maxima
        [r2 c2 v2] = ind2sub(size(bwUlt),find(bwUlt));
        xyzUlt = [r2 c2 v2];%find xyz coords of the local maxima
        xyzUlt = xyzUlt .* info.SliceThickness;%convert to physical units
        diams = 2 * rads .* info.SliceThickness;%convert to diameters and in physical units
        TbTh2(ct) = mean(diams);%mean structure thickness
        TbThSTD2(ct) = std(diams);%standard deviation of structure thicknesses
    end

    if isfield(info,'Private_0029_1004')
        [densityMatrix junk] = calculateDensityFromDICOM(info,img2);
        clear junk;
        TMD2(ct) = mean(densityMatrix(find(bwPorosity)));
        if length(find(bwFilled2)) > 0
            vBMD2(ct) = mean(densityMatrix(find(bwFilled2)));
        else
            vBMD2(ct) = 0;
        end
    else
        TMD2(ct) = 0;
        cBMD2(ct) = 0;
    end

end

out2.BV2 = BV2;
out2.BAr2 = BAr2;
out2.MAr2 = MAr2;
out2.TAr2 = TAr2;
out2.vBMD2 = vBMD2;
out2.TMD2 = TMD2;
out2.TbTh2 = TbTh2;
out2.TbThSTD2 = TbThSTD2;
out2.porosity2 = porosity2;
