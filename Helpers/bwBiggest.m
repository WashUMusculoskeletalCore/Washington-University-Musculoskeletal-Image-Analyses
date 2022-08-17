% NAME-bwBiggest
% DESC-remove all pixels from bw except the largest connected component
% IN-bw:the black and white image
% OUT-bw:the largest component of the image
function [bw] = bwBiggest(bw)
    % get a list of connected components
    cc = bwconncomp(bw);
    % find the component with the most pixels
    numPixels = cellfun(@numel,cc.PixelIdxList);
    [~, idx] = max(numPixels);
    % Remove all other components
    bw = false(size(bw));
    bw(cc.PixelIdxList{idx}) = 1;