% NAME-bwIndex
% DESC-Gets the nth largest connected component in the black and white image
% IN-bw:the black and white image
% index: the size rank of the object to get, 1 is largest
% OUT-bw: the selected component
function [bw] = bwIndex(bw,index)
    % Get a sorted list of components by size
    cc = bwconncomp(bw);
    numPixels = cellfun(@numel,cc.PixelIdxList);
    [~, I] = sort(numPixels,'descend');
    % Remove all components except the selected one
    bw = false(size(bw));
    bw(cc.PixelIdxList{(I(index))}) = 1;