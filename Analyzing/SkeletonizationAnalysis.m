function [hObject,eventdata,handles] = SkeletonizationAnalysis(hObject,eventdata,handles)

try
    setStatus(hObject, handles, 'Busy');

    %generates uncorrected skeleton
    handles.bwSkeleton = Skeleton3D(handles.bwContour);
    [handles.A, handles.node, handles.link] = Skel2Graph3D(handles.bwSkeleton,str2num(get(handles.editRadius,'String')));
    [w, l, h] = size(handles.bwSkeleton);
    handles.bwSkeleton = Graph2Skel3D(handles.node,handles.link,w,l,h);
    % Display shape of mask
    hfig = figure;
    set(hfig,'Visible','off')
    shp = shpFromBW(handles.bwContour,2);
    plot(shp,'FaceColor','w','FaceAlpha',0.3,'LineStyle','none');
    camlight();
    hold on;
    handles.bwDist = bwdist(~handles.bwContour); % Gets distance map to edge for area in mask
    handles.bwDist(~handles.bwSkeleton) = 0; % Limit distance map to skeleton
    handles = ReduceDistanceMap(handles,hObject);
    [r, c, v] = ind2sub(size(handles.bwDist),find(handles.bwDist));
    xyzUlt = [r c v];
    for i = 1:length(xyzUlt)
        rads(i) = handles.bwDist(xyzUlt(i,1),xyzUlt(i,2),xyzUlt(i,3));%find xyz coords of the local maxima
    end
    [rads, I] = sort(rads,'ascend');
    xyzUlt = xyzUlt(I,:);
    [x, y, z] = sphere();
    Y = discretize(rads,64); % Sort rads into 64 bins
    cmap = jet(64); % Creates a colormap coresponding to each bucket
    for i = 1:length(rads)
        displayPercentLoaded(hObject, handles, i/length(rads));
        % Creates a colored surface map
        surf((x*rads(i)+xyzUlt(i,1)),(y*rads(i)+xyzUlt(i,2)),(z*rads(i)+xyzUlt(i,3)),'LineStyle','none','FaceColor',cmap(Y(i),:));
        axis tight;
        drawnow();
    end
    hold off;
    saveas(hfig,fullfile(handles.pathstr,'SkeletonizedFigure.fig')); % Save the figure
    
    for i = 1:length(handles.link)
        clear px py pz;
        % Get each node from the link, and the xyz coordinates of each node 
        out(i).nodes = [handles.link(i).n1,handles.link(i).n2];
        out(i).nodeLocs(1,:) = [handles.node(handles.link(i).n1).comx,handles.node(handles.link(i).n1).comy,handles.node(handles.link(i).n1).comz];
        out(i).nodeLocs(2,:) = [handles.node(handles.link(i).n2).comx,handles.node(handles.link(i).n2).comy,handles.node(handles.link(i).n2).comz];
        for k = 1:length(handles.link(i).point)
            [px(k), py(k), pz(k)] = ind2sub(size(handles.bwSkeleton),handles.link(i).point(k)); % Get the coordinates of each point
        end
        out(i).points = [px' py' pz'];
        for k = 1:length(out(i).points(:,1))
            out(i).rads(k) = double(handles.bwDist(out(i).points(k,1),out(i).points(k,2),out(i).points(k,3))); % Get the distance for every point as rads
        end
        out(i).rads = out(i).rads(find(out(i).rads)); % Remove zeros
        %convert to physical units
        out(i).nodeLocs = out(i).nodeLocs .* handles.info.SliceThickness;
        px = px  .* handles.info.SliceThickness;
        py = py  .* handles.info.SliceThickness;
        pz = pz  .* handles.info.SliceThickness;
        out(i).points = out(i).points  .* handles.info.SliceThickness;
        out(i).rads = out(i).rads  .* handles.info.SliceThickness;
        %           %calculate length of snake
        for k = 1:length(px)
            if k == 1
                out(i).length = 0; % Start the length at 0
            else
                out(i).length = out(i).length + sqrt((px(k) - px(k-1))^2 + (py(k) - py(k-1))^2 + (pz(k) - pz(k-1))^2); % Add pythagorean distance between this point and previous to length
            end
        end
    end
    
    
    % Write the output to file
    outHeader = {'File','Date','Nodes','Node Locations','Link Length','Mean Link Radius','STD Link Radius','Link Points'};
    fid = fopen(fullfile(handles.pathstr,'SkeletonizationResults.txt'),'w');
    % Write the header
    for i = 1:length(outHeader)
        if i ~= length(outHeader)
            fprintf(fid,'%s\t',outHeader{i});
        else
            fprintf(fid,'%s\n',outHeader{i}); % Add endline to last line of header
        end
    end
    % Output data
    for i = 1:length(out)
        if ~isempty(out(i).rads)
            fprintf(fid,'%s\t',handles.pathstr); % Filepath
            fprintf(fid,'%s\t',datestr(now)); % Date
            fprintf(fid,'%s\t',[num2str(out(i).nodes(1)) ',' num2str(out(i).nodes(2))]); % Node Pair
            for k = 1:length(out(i).nodeLocs(:,1))
                if k ~= length(out(i).nodeLocs(:,1))
                    fprintf(fid,'%s',[num2str(out(i).nodeLocs(k,:)) ';']); % Format final node coordinate
                else
                    fprintf(fid,'%s\t',num2str(out(i).nodeLocs(k,:))); % Node coordinates
                end
            end
            fprintf(fid,'%s\t',num2str(out(i).length)); % Snake length
            fprintf(fid,'%s\t',num2str(mean(out(i).rads))); % Average rads
            fprintf(fid,'%s\t',num2str(std(out(i).rads))); % Standard deviation of rads
            for k = 1:length(out(i).points)
                if k ~= length(out(i).points)
                    fprintf(fid,'%s',[num2str(out(i).points(k,:)) ';']); % Format final point
                else
                    fprintf(fid,'%s\n',num2str(out(i).points(k,:))); % All points
                end
            end
            
        end
    end
    fclose(fid);
    
    
    %         %corrects skeleton to join sections within a user-specified
    %         %distance
    %         handles.bwDist = bwdist(handles.bwContour);
    %         handles.bwDist(handles.bwContour) = max(max(max(handles.bwDist)));
    
    
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end