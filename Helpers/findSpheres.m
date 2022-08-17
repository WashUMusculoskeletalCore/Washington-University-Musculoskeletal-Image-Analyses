% NAME-findSpheres
% DESC-Uses a distance map to find a set of non-intersecting sphere
% IN-dm: The 3D distance map
% OUT-dm: The distance map reduced to the sphere centers
function dm = findSpheres(hObject, handles, dm)
    % Find maximum radius in distance map 
    maxRad = ceil(max(max(max(double(dm)))));
    % Extend the array by the radius in all dirrections
    dm = padarray(dm,[ceil(maxRad)+1 ceil(maxRad)+1 ceil(maxRad)+1]);
    [a, b, c] = size(dm);
    initLen = length(find(dm));
    % Reshape map into a 1D array
    reshaped = reshape(dm,[a*b*c, 1]);
    % Get the indexes of the points from largest to smallest
    [~, I]= sort(reshaped,'descend');
    % Get the location of each point in sorted order
    [x, y, z] = ind2sub(size(dm), I(1:initLen));
    displayPercentLoaded(hObject, handles, 0);
    % Check every point
    for i = 1:length(x)
        if mod(i,500) == 0
            % Update loading percentage
            displayPercentLoaded(hObject, handles, i/initLen);
        end
        if dm(x(i),y(i),z(i)) > 0
            % Get the distance at the point
            radToTest = dm(x(i),y(i),z(i));
            % Mark a cube area to test around each coordinate
            cube = false(size(dm));
            cube(x(i),y(i),z(i)) = 1;
            cube = imdilate(cube,true([2*ceil(maxRad)+1, 2*ceil(maxRad)+1, 2*ceil(maxRad)+1]));
            [a1, b1, c1] = ind2sub(size(cube),find(cube));
            % Get every distance in the distance map within the cube
            radsTesting = dm(cube);
            % Get distance from current point
            ds = sqrt((a1-x(i)).^2 + (b1-y(i)).^2 + (c1-z(i)).^2);
            % Get points where the sum of their radius and the tested
            % points radius is greater or equal to the disance between
            % them (Their spheres intersect)
            rirj = radToTest + radsTesting;
            intersect = rirj >= ds;
            % Find the largest intersecting sphere in range
            [thisMax, I] = max(radsTesting(intersect));
            inds = [a1(intersect),b1(intersect),c1(intersect)];
            % Remove the largest sphere from the list of indexes
            if radToTest >= thisMax
                inds2 = inds == [x(i),y(i),z(i)];
                for j = 1:length(inds2)
                    if inds2(j,1) == 1 && inds2(j,2) == 1 && inds2(j,3) == 1
                        inds(j,:) = [];
                    end
                end
            else
                inds(I,:) = [];
            end
            % Remove all points in range except the largest sphere center
            % from the distance map
            for j = 1:length(inds)
                dm(inds(j,1),inds(j,2),inds(j,3)) = 0;
            end
        end
    end
    displayPercentLoaded(hObject, handles, 1);
    % Remove padding
    dm = dm((ceil(maxRad)+1):end-(ceil(maxRad)+1),...
    (ceil(maxRad)+1):end-(ceil(maxRad)+1),...
    (ceil(maxRad)+1):end-(ceil(maxRad)+1));
end