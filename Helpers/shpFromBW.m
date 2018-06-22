function [shp] = shpFromBW(bw,radius)

[X Y Z] = ind2sub(size(bw),find(bw));

shp = alphaShape([X Y Z],radius);