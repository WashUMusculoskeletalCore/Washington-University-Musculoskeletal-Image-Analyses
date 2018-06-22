function [handles] = ReduceDistanceMap(handles,hObject)

try
    set(handles.textBusy,'String','Busy');
    drawnow();
    maxRad = max(max(max(handles.bwDist)));
    
    %pad array to account for radius
    handles.bwDist = padarray(handles.bwDist,[double(2*ceil(maxRad)+2) double(2*ceil(maxRad)+2) double(2*ceil(maxRad)+2)]);
    
    initLen = length(find(handles.bwDist));
    [x y z] = ind2sub(size(handles.bwDist),find(handles.bwDist));
    [aa bb cc] = size(handles.bwDist);
    handles.bwDistReshaped = reshape(handles.bwDist,[aa*bb*cc,1]);
    [handles.bwDistSorted I]= sort(handles.bwDistReshaped,'descend');
    [handles.bwDistSorted] = handles.bwDistSorted(find(handles.bwDistSorted));
    [x2 y2 z2] = ind2sub(size(handles.bwDist),I(1:length(handles.bwDistSorted)));
    
    
    for i = 1:length(x2)
        if mod(i,50) == 0 || i == length(x2)
            set(handles.textPercentLoaded,'String',num2str(i/length(x2)));
            drawnow();
        end
        if handles.bwDist(x2(i),y2(i),z2(i)) > 0
            
            radToTest = handles.bwDist(x2(i),y2(i),z2(i));
            
            bw3 = false(size(handles.bwDist));
            %                 bw3(x2(i),y2(i),z2(i)) = 1;
            %                  bw3 = imdilate(bw3,true([2*ceil(maxRad)+1,2*ceil(maxRad)+1,2*ceil(maxRad)+1]));
            bw3(((x2(i)-(2*ceil(maxRad)+1)):(x2(i)+(2*ceil(maxRad)+1))),...
                ((y2(i)-(2*ceil(maxRad)+1)):(y2(i)+(2*ceil(maxRad)+1))),...
                ((z2(i)-(2*ceil(maxRad)+1)):(z2(i)+(2*ceil(maxRad)+1)))) = 1;
            [a1 b1 c1] = ind2sub(size(bw3),find(bw3));
            
            radsTesting = handles.bwDist(bw3);
            
            ds = sqrt((a1-x2(i)).^2 + (b1-y2(i)).^2 + (c1-z2(i)).^2);%location of cube - location of radius
            rirj = radToTest + radsTesting;
            
            inds = rirj >= ds;% find spheres that intersect
            [thisMax I] = max(radsTesting(inds));
            inds = [a1(inds),b1(inds),c1(inds)];
            if radToTest >= thisMax
                inds2 = inds == [x2(i),y2(i),z2(i)];
                for j = 1:length(inds2)
                    if inds2(j,1) == 1 && inds2(j,2) == 1 && inds2(j,3) == 1
                        inds(j,:) = [];
                    end
                end
            else
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
    
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end