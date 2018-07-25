function ThicknessVisualization(hObject,eventdata,handles)

try
	set(handles.textBusy,'String','Busy');
	guidata(hObject, handles);
    drawnow();
    bw = handles.bwContour;
    D1 = bwdist(~bw);%does what I want for thickness of spacing
    bwUlt = bwulterode(bw);
    D1(~bwUlt) = 0;

    maxRad = ceil(max(max(max(double(D1)))));
    D1 = padarray(D1,[ceil(maxRad)+1 ceil(maxRad)+1 ceil(maxRad)+1]);

    [aa bb cc] = size(D1);
    [a b c] = size(bw);

    initLen = length(find(D1));
    [x y z] = ind2sub(size(D1),find(D1));
    D1Reshaped = reshape(D1,[aa*bb*cc,1]);
    [D1Sorted I]= sort(D1Reshaped,'descend');
    [D1Sorted] = find(D1Sorted);
    [x2 y2 z2] = ind2sub(size(D1),I(1:length(D1Sorted)));

    tic
    for i = 1:length(x2)
        if mod(i,500) == 0
    %         clc
            set(handles.textPercentLoaded,'String',num2str(i/initLen));
            drawnow()
        end
        if D1(x2(i),y2(i),z2(i)) > 0

            radToTest = D1(x2(i),y2(i),z2(i));

            bw3 = false(size(D1));
            bw3(x2(i),y2(i),z2(i)) = 1;
            bw3 = imdilate(bw3,true([2*ceil(maxRad)+1,2*ceil(maxRad)+1,2*ceil(maxRad)+1]));
            [a1 b1 c1] = ind2sub(size(bw3),find(bw3));

            radsTesting = D1(bw3);

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
                D1(inds(j,1),inds(j,2),inds(j,3)) = 0;
            end
        end

    end
    toc 

    shp = shpFromBW(bw,3);
    figure;
    plot(shp,'FaceColor','w','LineStyle','none');
    alpha(gca,0.4);
    camlight;
    hold on;
    [x y z] = sphere;
    [x2 y2 z2] = ind2sub(size(D1),find(D1));
    rads = D1(find(D1));
    rangeRads = max(rads) - min(rads);
    binRads = rangeRads / 256;
    if rangeRads == 0
        bin(1) = 0;
        bin(2) = max(rads);
        trans = [1 1];
    else
        for i = 1:255
            bin(i) = binRads * i;
            trans(i) = i/255;
        end
    end
    if length(bin) > 256
        map = colormap(jet(256));
    else
        map = colormap(jet(length(bin)));
    end
    for i = 1:length(find(D1))
        for j = 2:length(bin)
            if rads(i) > bin(j-1) && rads(i) <= bin(j)
                surf(x*rads(i)+x2(i)-maxRad,y*rads(i)+y2(i)-maxRad,z*rads(i)+z2(i)-maxRad,'FaceColor',map(j-1,:),'FaceAlpha',trans(j),'LineStyle','none');
                axis tight;
                drawnow();
            end
        end
    end
    saveas(gcf,fullfile(handles.pathstr,[get(handles.editDICOMPrefix,'String') '.fig']));
    guidata(hObject, handles);
    set(handles.textBusy,'String','Not Busy');
catch
    	set(handles.textBusy,'String','Failed');
end
