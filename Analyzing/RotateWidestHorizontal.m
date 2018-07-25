function [degree] = RotateWidestHorizontal(img,bwIn)

[a b c] = size(img);
degree = 0;

for i = 1:c
    img2 = img(:,:,i);
    bw = bwIn(:,:,i);
    bw = bwBiggest(bw);
    % Find position of Centroid
    [I J] = find(bw > 0);
    ycent = mean(I(:));
    xcent = mean(J(:));

    % Find MOIs
    for j=1:length(I)
        Iyy_rt(j) = double((J(j) - xcent)^2);
        Ixx_rt(j) = double((I(j) - ycent)^2);
        Ixy_rt(j) = (double((I(j) - ycent)*(J(j) - xcent)));
    end

    Iyy(i) = sum(Iyy_rt(:)); clear Iyy_rt;
    Ixx(i) = sum(Ixx_rt(:)); clear Ixx_rt;
    Ixy(i) = sum(Ixy_rt(:)); clear Ixy_rt;

end
phi  = pi/180*degree - 0.5*atan(2*mean(Ixy)/(mean(Ixx)-mean(Iyy)));
        
% Ensure the long axis is horizontal (if that option was previously selected)
if mean(Iyy) < mean(Ixx)
    degree = 90+180/pi*phi;
else
    degree = 180/pi*phi;
end