function [handles] = ReduceDistanceMap(handles,hObject)

try
    setStatus(hObject, handles, 'Busy');
    maxRad = max(max(max(handles.bwDist)));
    
    %pad array to account for radius
    handles.bwDist = padarray(handles.bwDist,[double(2*ceil(maxRad)+2) double(2*ceil(maxRad)+2) double(2*ceil(maxRad)+2)]);
    % Get initial nonzero length of bwDist
    initLen = length(find(handles.bwDist));
    % Get coordinates for all elements of bwDist
    [x y z] = ind2sub(size(handles.bwDist),find(handles.bwDist));
    % Get dimensions of bwDist
    [aa bb cc] = size(handles.bwDist);
    % Reshape bwDist into a 1d matrix
    handles.bwDistReshaped = reshape(handles.bwDist,[aa*bb*cc,1]);
    % Sort the reshaped matrix
    [handles.bwDistSorted I]= sort(handles.bwDistReshaped,'descend');
    % Remove any zeros
    [handles.bwDistSorted] = handles.bwDistSorted(find(handles.bwDistSorted));
    % Get the coordinates for each sorted index
    [x2 y2 z2] = ind2sub(size(handles.bwDist),I(1:length(handles.bwDistSorted)));
    
    
    for i = 1:length(x2)
        if mod(i,50) == 0 || i == length(x2)
            % Update percentage complete
            displayPercentLoaded(hObject, handles, i/length(x2));
            drawnow();
        end
        if handles.bwDist(x2(i),y2(i),z2(i)) > 0
            
            radToTest = handles.bwDist(x2(i),y2(i),z2(i));
            
            bw3 = false(size(handles.bwDist));
            %                 bw3(x2(i),y2(i),z2(i)) = 1;
            %                  bw3 = imdilate(bw3,true([2*ceil(maxRad)+1,2*ceil(maxRad)+1,2*ceil(maxRad)+1]));
            % Mark a cube arround each coordinate
            bw3(((x2(i)-(2*ceil(maxRad)+1)):(x2(i)+(2*ceil(maxRad)+1))),...
                ((y2(i)-(2*ceil(maxRad)+1)):(y2(i)+(2*ceil(maxRad)+1))),...
                ((z2(i)-(2*ceil(maxRad)+1)):(z2(i)+(2*ceil(maxRad)+1)))) = 1;
            [a1 b1 c1] = ind2sub(size(bw3),find(bw3));
            % Get every point in the distance map within the cube
            radsTesting = handles.bwDist(bw3);
            % Get the distance between every point in the cube and the
            % center
            ds = sqrt((a1-x2(i)).^2 + (b1-y2(i)).^2 + (c1-z2(i)).^2);%location of cube - location of radius
            rirj = radToTest + radsTesting;
            % Mark the sphere around the point
            inds = rirj >= ds;% find spheres that intersect
            % Get the highest value in the distance map within the sphere
            [thisMax I] = max(radsTesting(inds));
            % Get a list of every point in the cube and the sphere
            inds = [a1(inds),b1(inds),c1(inds)];
            if radToTest >= thisMax
                inds2 = inds == [x2(i),y2(i),z2(i)];
                for j = 1:length(inds2)
                    if inds2(j,1) == 1 && inds2(j,2) == 1 && inds2(j,3) == 1
                        inds(j,:) = [];
                    end
                end
            else
                % Remove the max point if it has a higher value than rad to
                % test
                inds(I,:) = [];
            end
            for j = 1:length(inds)
                handles.bwDist(inds(j,1),inds(j,2),inds(j,3)) = 0;
            end
            
        end
        
    end
    
    %remove padding
    handles.bwDist = handles.bwDist((2*ceil(maxRad)+2):end-(2*ceil(maxRad)+2),...
        (2*ceil(maxRad)+2):end-(2*ceil(maxRad)+2),...
        (2*ceil(maxRad)+2):end-(2*ceil(maxRad)+2));
    
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end