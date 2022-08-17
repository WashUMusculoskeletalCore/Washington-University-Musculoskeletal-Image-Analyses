% NAME-SkeletonizationAnalysis
% DESC-Calculates the skeletonization of the mask and outputs it to a file
% IN-handles.bwContour: The 3D mask
% OUT-Displays and outputs a thickness map for the skeleton
% Outputs a tsv file containing the skeleton link data
function [hObject,eventdata,handles] = SkeletonizationAnalysis(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        if isfield(handles, 'bwContour')
            %generates uncorrected skeleton
            bwSkeleton = Skeleton3D(handles.bwContour);
            [~, node, link] = Skel2Graph3D(bwSkeleton, str2double(get(handles.editRadius,'String')));
            [w, l, h] = size(bwSkeleton);
            bwSkeleton = Graph2Skel3D(node,link,w,l,h);
            % Display shape of mask
            hfig = figure;
            set(hfig,'Visible','on')
            shp = shpFromBW(handles.bwContour,2);
            plot(shp,'FaceColor','w','FaceAlpha',0.3,'LineStyle','none');
            camlight();
            hold on;
            bwDist = bwdist(~handles.bwContour); % Gets distance map to edge for area in mask
            bwDist(~bwSkeleton) = 0; % Limit distance map to skeleton
            spheres = findSpheres(hObject, handles, bwDist); % Find the local maxima spheres
            % Get the points in the distance map
            [a, b, c] = ind2sub(size(spheres),find(spheres));
            xyzUlt = [a b c];
            % Sort the points by radius value
            rads = zeros(1, length(xyzUlt));
            for i = 1:length(xyzUlt)
                rads(i) = spheres(xyzUlt(i,1),xyzUlt(i,2),xyzUlt(i,3));% Find xyz coords of the local maxima
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
            out = struct;
            for i = 1:length(link)
                displayPercentLoaded(hObject, handles, i/length(link));
                % Get each node from the link, and the xyz coordinates of each node 
                out(i).nodes = [link(i).n1, link(i).n2];
                out(i).nodeLocs(1,:) = [node(link(i).n1).comx, node(link(i).n1).comy, node(link(i).n1).comz];
                out(i).nodeLocs(2,:) = [node(link(i).n2).comx, node(link(i).n2).comy, node(link(i).n2).comz];
                % Preallocate arrays
                px = zeros(length(link(i).point), 1);
                py = zeros(length(link(i).point), 1);
                pz = zeros(length(link(i).point), 1);
                % Get a list of cooridates for each point in the link
                for k = 1:length(link(i).point)
                    [px(k), py(k), pz(k)] = ind2sub(size(bwSkeleton), link(i).point(k)); 
                end
                out(i).points = [px py pz];
                 % Get the distance map radius for every point as rads
                for k = 1:length(out(i).points(:,1))
                    out(i).rads(k) = double(bwDist(out(i).points(k,1),out(i).points(k,2),out(i).points(k,3)));
                end
                out(i).rads = nonzeros(out(i).rads); % Remove zeros
                %convert to physical units
                out(i).nodeLocs = out(i).nodeLocs .* handles.info.SliceThickness;
                px = px  .* handles.info.SliceThickness;
                py = py  .* handles.info.SliceThickness;
                pz = pz  .* handles.info.SliceThickness;
                out(i).points = out(i).points  .* handles.info.SliceThickness;
                out(i).rads = out(i).rads  .* handles.info.SliceThickness;
                %  Calculate length of snake
                for k = 1:length(px)
                    if k == 1
                         % Start the length at 0
                        out(i).length = 0;
                    else
                        % Add pythagorean distance between this point and previous to length
                        out(i).length = out(i).length + sqrt((px(k) - px(k-1))^2 + (py(k) - py(k-1))^2 + (pz(k) - pz(k-1))^2); 
                    end
                end
            end


            % Write the output to file
            outHeader = {'File','Date','Nodes','Node Locations','Link Length','Mean Link Radius','STD Link Radius','Link Points'};
            fid = fopen(fullfile(handles.pathstr,'SkeletonizationResults.txt'),'w');
            % Write the header
            for i = 1:length(outHeader)
                if i ~= length(outHeader)
                    fprintf(fid,'%s\t',outHeader{i}); % Print the header and a tab
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

            else
            noMaskError();
        end
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end