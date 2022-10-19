% NAME-RotateWidestHorizontal
% DESC-Calculates the angle to rotate in order to minimize the moment of inertia
% arround the x axis (make the object as horizontal as possible)
% IN-bwIn: the black and white image to find the angle for
% OUT-degree: the angle of the axis in degrees
function degree = RotateWidestHorizontal(bwIn)
    [~, ~, c] = size(bwIn);
    Iyy = zeros(1, c);
    Ixx = zeros(1, c);
    Ixy = zeros(1, c);
    for i = 1:c
        bw = bwIn(:,:,i);
        bw = bwBiggest(bw); % Get the biggest object
        % Find position of Centroid
        [I, J] = find(bw > 0); % gets the row and collumn numbers of every nonzero pixel of bw
        % Get the average row and collumn of every pixel
        ycent = mean(I(:));
        xcent = mean(J(:));

        % Preallocate moment of intertia
            Iyy_rt = zeros(1, length(I));
            Ixx_rt = zeros(1, length(I));
            Ixy_rt = zeros(1, length(I));
        % Find moments of inertia
        for j=1:length(I)
            % Get the distance from the center squared for each point
            Iyy_rt(j) = double((J(j) - xcent)^2);
            Ixx_rt(j) = double((I(j) - ycent)^2);
            Ixy_rt(j) = (double((I(j) - ycent)*(J(j) - xcent)));
        end
        % Get the total distance from the center squared
        Iyy(i) = sum(Iyy_rt(:));
        Ixx(i) = sum(Ixx_rt(:));
        Ixy(i) = sum(Ixy_rt(:));

    end
    % Calculate the angle of the axes with the highest/lowest moment of inertia
    phi  = -0.5*atan(2*mean(Ixy)/(mean(Ixx)-mean(Iyy)));

    % Ensure the long axis is horizontal
    % 180/pi is conversion from radians to degrees
    if mean(Iyy) < mean(Ixx)
        degree = 90+180/pi*phi;
    else
        degree = 180/pi*phi;
    end