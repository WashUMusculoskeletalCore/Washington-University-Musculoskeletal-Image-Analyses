function [meanRad,stdRad,D2] = calculateThickness(D2,suppress)

tic;
D2 = double(D2);
maxRad = ceil(max(max(max(D2))));
D2 = padarray(D2,[ceil(maxRad)+1 ceil(maxRad)+1 ceil(maxRad)+1]);
% D2 = gpuArray(D2);
% D2(D2<(maxRad/suppress)) = 0;
bw = false(size(D2));
bw(D2 > 0) = 1;

[aa bb cc] = size(D2);

[a b c] = size(bw);
% bw2 = Skeleton3D(bw);
% for i = 1:c
%     bw2(:,:,i) = bwmorph(bw(:,:,i),'skel',100);
% end

% D2(~bw2) = 0;

%sort radii by size to avoid accidental voids
[aa bb cc] = size(D2);

initLen = length(find(D2));
[x y z] = ind2sub(size(D2),find(D2));
D2Reshaped = reshape(D2,[aa*bb*cc,1]);
[D2Sorted I]= sort(D2Reshaped,'descend');
[D2Sorted] = find(D2Sorted);
[x2 y2 z2] = ind2sub(size(D2),I(1:length(D2Sorted)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%for testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%for testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% tic
for i = 1:length(x2)
    if mod(i,300) == 0
        clc
        i/initLen
    end
    if D2(x2(i),y2(i),z2(i)) > 0

        radToTest = D2(x2(i),y2(i),z2(i));

        bw3 = false(size(D2));
        bw3(x2(i),y2(i),z2(i)) = 1;
%         bw3(x2(i)-ceil(maxRad):x2(i)+ceil(maxRad),y2(i)-ceil(maxRad):y2(i)+ceil(maxRad),z2(i)-ceil(maxRad):z2(i)+ceil(maxRad)) = 1;
        bw3 = imdilate(bw3,true([2*ceil(maxRad)+1,2*ceil(maxRad)+1,2*ceil(maxRad)+1]));
        [a1 b1 c1] = ind2sub(size(bw3),find(bw3));
        
        radsTesting = D2(bw3);

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
            D2(inds(j,1),inds(j,2),inds(j,3)) = 0;
        end

    end
    
end
% toc;

endLen = length(find(D2));
% StackSlider(D2)
rads = D2(find(D2));%find the radii of the spheres at the local maxima
% % rads(rads < (2)) = 0;
% [r c v] = ind2sub(size(D2),find(D2));
% xyzUlt = [r c v];%find xyz coords of the local maxima
% % plot the spheres inside the surface
% shp = shpFromBW(bw,2);
% figure
% plot(shp,'FaceColor','w','LineStyle','none','FaceAlpha',0.3);
% camlight();
% drawnow();
% hold on;
% [x y z] = sphere;
% for i = 1:length(xyzUlt)
%     surf((x*rads(i)+xyzUlt(i,1)),(y*rads(i)+xyzUlt(i,2)),(z*rads(i)+xyzUlt(i,3)),'LineStyle','none','FaceColor','r');
%     axis tight;
%     drawnow();
% end

meanRad = mean(rads);
stdRad = std(rads);
toc;
