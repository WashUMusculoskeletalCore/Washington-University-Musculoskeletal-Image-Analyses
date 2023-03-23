% NAME-calculateThickness
% DESC-Uses a distance map to find the average thickness and standard
% deviation of a shape
% IN-dm: The distance map
% OUT-meanRad: The average radius of the thickness spheres
% stdRad: The standard deviation of radius of the thickness spheres
function [meanRad,stdRad,rads] = calculateThickness(dmOrig)
    dm = double(dmOrig);
    rads = dm;
    % Filter the map to not contained spheres
    idx = find(dm);
    [a,b,c]=ind2sub(size(dm), idx);
    for n=1:length(a)
        x=a(n);
        y=b(n);
        z=c(n);
        r=dm(x,y,z);
        rf = floor(r);
        % Get the cube containing the sphere centered at xyz with radius r
        if rf>0
            for i=max(x-rf,1):min(x+rf,size(dm,1))
                for j=max(y-rf,1):min(y+rf, size(dm,2))
                    for k=max(z-rf,1):min(z+rf, size(dm,3))
                        % If the point is in the sphere and the shape
                        if (x-i)^2+(y-j)^2+(z-k)^2 <= r^2 && rads(i,j,k)>0
                            rads(i,j,k)=max(rads(i,j,k), r);                      
                            if dm(i,j,k) > 0
                                % If the radius of the checked sphere plus the distance is
                                % smaller than the checking sphere, remove it
                                if (dm(i,j,k)+sqrt((x-i)^2+(y-j)^2+(z-k)^2)<=r)&&(i~=x||j~=y||k~=z)
                                    dm(i,j,k)=0;
                                end
                                % If the radius of the checking sphere plus the distance is
                                % smaller than the checked sphere, remove it and end the current loop
                                if (dm(i,j,k)>=sqrt((x-i)^2+(y-j)^2+(z-k)^2)+r)&&(i~=x||j~=y||k~=z)
                                    dm(x,y,z)=0;
                                    r=0;
                                    break;
                                end
                            end
                        end
                    end
                    if r==0
                       break;
                    end
                end
                if r==0
                    break;
                end
            end
        end
    end
    % Find the average and standard deviation of the largest sphere per
    % point
    rads = nonzeros(rads); 
    meanRad = mean(rads);
    stdRad = std(rads);
end