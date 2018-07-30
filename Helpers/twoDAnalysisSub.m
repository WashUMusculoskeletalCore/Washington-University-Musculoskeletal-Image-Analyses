function [twoDHeader twoDResults] = twoDAnalysisSub(img,info,threshold,bwIn)

%edited as a sub-function expecting an m x n x o matrix that is CT data,
%containing one bone only, and the info struct for one slice of the data set.

% 2D Analysis Program
% Version 4.0
% Ryan Tomlinson
% 8/13/2008
% upd 7/13/2009

% INPUT: 2D CT images (preferably .tif format)
% OUTPUT: XLS Spreadsheet (tab-delimited) of bone measurements

% CHANGE LOG
% 8/29/2008
% Added try/catch for filename issues
% Added error dialog box if output does not exist

% 9/12/2008
% Adding Tissue Area (T.Ar, area inside the periosteal perimeter)
% Medullary Area (T.Ar - B.Ar)
% Periosteal X-Width (x-max - x-min)
% Periosteal Y-Width (y-max - y min)
% as per email 9/11 MJS

% 9/18/2008
% Changed from rotate_image to imrotate. Much less noise in rotation.

% 5/28/2009 (Mark Willingham)
%  Added Ixy 

% 6/25/2009 (Mark Willingham)
% Added Imin and Imax 

% 7/09/09 (Mark Willingham)
% Added automatic rotation by minimizing product MOI
    % Prompt for auto-rotation before asking for angles
    % Setting to ensure bone lays on its long side
% Fixed issues with "find" that switched Ixx & Iyy
% Fixed error in "slicenum" indexing that led to incorrect results
% Added user-defined threshold minima to fix issues with some radius slices
% Added averages to output file after each bone

%7/13/09 (Mark Willingham)
% Clear Ixx_rt(:) etc. after every bone - correct results now
% Remove iterative angle finding now that moments are correct
% Store all images in 'a' to increase speed when processing multiple bones
% Output angle after each bone (no  longer automatically computed before headers are written)
% Improve rotation dialog box order - Auto? no longer in manual roation loop
% Change how phi calculates angle for more accurate rotations
% Removed user-defined threshold minima as it's not less necessary

% 10/02/09 Ryan Tomlinson
% Fixed bug in ymax calculation

% 12/30/13 Dan Leib
% Altered to accept DICOM input so metadata can be used instead of tube
% size inputs

[a b c] = size(img);

pixelwidth = info.SliceThickness;
pixelarea = pixelwidth^2;

autorotate = 1;
proceed = 1;
degree = 0;
autohoriz = 1;


%% NOW PROCESSING

for i = 1:c
    img2 = img(:,:,i);
    bw = bwIn(:,:,i);
    bw = imrotate(bw, degree);
    bw = bwBiggest(bw);
    % Find position of Centroid
    [I J] = find(bw > 0);
    I = I .* pixelwidth; %mm (pixels * mm/pixels)
    J = J .* pixelwidth; %mm
    ycent = mean(I(:));
    xcent = mean(J(:));

    % Find MOIs
    for j=1:length(I)
        Iyy_rt(j) = double((J(j) - xcent)^2) * pixelarea;
        Ixx_rt(j) = double((I(j) - ycent)^2) * pixelarea;
        Ixy_rt(j) = (double((I(j) - ycent)*(J(j) - xcent)))*pixelarea;
    end

    Iyy(i) = sum(Iyy_rt(:)); clear Iyy_rt;
    Ixx(i) = sum(Ixx_rt(:)); clear Ixx_rt;
    Ixy(i) = sum(Ixy_rt(:)); clear Ixy_rt;

end
phi  = pi/180*degree - 0.5*atan(2*mean(Ixy)/(mean(Ixx)-mean(Iyy)));
        
% Ensure the long axis is horizontal (if that option was previously selected)
if mean(Iyy) < mean(Ixx) && autohoriz == 1
    degree = 90+180/pi*phi;
else
    degree = 180/pi*phi;
end
    
%Analyze all the slices with the given rotations, croppings, etc.
for i = 1:c
    img2 = img(:,:,i);
    bw = bwIn(:,:,i);
    bw = imrotate(bw, degree);
    bw = bwBiggest(bw);
    
    [a b] = size(bw);

    % Find position of Centroid
    [I J] = find(bw > 0);      
    I = I .* pixelwidth; %mm (pixels * mm/pixels)
    J = J .* pixelwidth; %mm
    ycent = mean(I(:));
    xcent = mean(J(:));

    % Find Periosteal X width and Y width
    pywidth(i) = max(I) - min(I);
    pxwidth(i) = max(J) - min(J);

    % Find Bone Area
    bonearea(i) = length(I)*pixelarea;

    % Find MOIs
    for j=1:length(I)
        Iyy_rt(j) = double((J(j) - xcent)^2) * pixelarea;
        Ixx_rt(j) = double((I(j) - ycent)^2) * pixelarea;
        Ixy_rt(j) = (double((I(j) - ycent)*(J(j) - xcent)))*pixelarea;
    end

    Iyy(i) = sum(Iyy_rt(:)); clear Iyy_rt;
    Ixx(i) = sum(Ixx_rt(:)); clear Ixx_rt;
    Ixy(i) = sum(Ixy_rt(:)); clear Ixy_rt;

    % Find Ymax (distance from centroid to bottom of the bone)
    ymax(i) = abs(max(I - ycent));

    % Find Tissue Area (T.Ar)
    tissuearea = imfill(bw,[round(ycent/pixelwidth) round(xcent/pixelwidth)]);
    tarea(i) = sum(tissuearea(:))*pixelarea;

    % Find Medullary Area (M.Ar)
    medarea = not(imfill(bw,[1 1]));
    marea(i) = sum(medarea(:))*pixelarea;

    % Find average Cortical Thickness
    ycentpixel = round(ycent/pixelwidth);
    xcentpixel = round(xcent/pixelwidth);

    horpixels = (bw(ycentpixel,:));
    verpixels = (bw(:,xcentpixel));
    
    %12:00
    first = 0;
    for j=1:ycentpixel
        if sum(bw(j, xcentpixel-1:xcentpixel+1)) > 0
            if first == 0
                noonfirst = j;
                first=1;
            else
                noonlast = j;
            end
        end
    end
    try
        noonth(i) = abs(noonlast-noonfirst) * pixelwidth;
    catch
        noonth(i) = 0;
    end

    %3:00
    first = 0;
    for j=xcentpixel:b
        if sum(bw(ycentpixel-1:ycentpixel+1,j)) > 0
            if first == 0
                threefirst = j;
                first=1;
            else
                threelast = j;
            end
        end
    end
    try
        threeth(i) = abs(threelast-threefirst) * pixelwidth;
    catch
        threeth(i) = 0;
    end

    %6:00
    first = 0;
    for j=ycentpixel:a
        if sum(bw(j,xcentpixel-1:xcentpixel+1)) > 0
            if first == 0
                sixfirst = j;
                first=1;
            else
                sixlast = j;
            end
        else
            thing = 5;
        end
    end
    try
        sixth(i) = abs(sixlast-sixfirst) * pixelwidth;
    catch
        sixth(i) = 0;
    end

    %9:00
    first = 0;
    for j=1:xcentpixel
        if sum(bw(ycentpixel-1:ycentpixel+1,j)) > 0
            if first == 0
                ninefirst = j;
                first=1;
            else
                ninelast = j;
            end
        end
    end
    try
        nineth(i) = abs(ninelast-ninefirst) * pixelwidth;
    catch
        nineth(i) = 0;
    end
    avgth(i) = (noonth(i)+threeth(i)+sixth(i)+nineth(i))/4;
end
%Output the averages after each bone's data
twoDHeader = {'Bone Area' 'Iyy (mm^4' 'Ixx (mm^4)' 'Ixy(mm^4)' 'Ymax' 'T.ar' 'M.ar' 'Periosteal X Width'...
            'Periosteal Y Width' '12:00 Thickness' '3:00 Thickness' '6:00 Thickness' '9:00 Thickness' 'Average Thickness' 'Bone Rotation'};
twoDResults = [...
mean(bonearea)...
mean(Iyy)...
mean(Ixx)...
mean(Ixy)...
mean(ymax)...
mean(tarea)...
mean(marea)...
mean(pxwidth)...
mean(pywidth)...
mean(noonth)...
mean(threeth)...
mean(sixth)...
mean(nineth)...
mean(avgth)...
degree...
];
    
    
