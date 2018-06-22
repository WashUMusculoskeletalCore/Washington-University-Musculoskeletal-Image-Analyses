function [bw] = bwIndex(bw,index)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Grab an aribtrary nth bw object by size; 1 is biggest, n is smallest
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cc = bwconncomp(bw);
numPixels = cellfun(@numel,cc.PixelIdxList);
[~,I] = sort(numPixels,'descend');
bw = false(size(bw));
bw(cc.PixelIdxList{(I(index))}) = 1;