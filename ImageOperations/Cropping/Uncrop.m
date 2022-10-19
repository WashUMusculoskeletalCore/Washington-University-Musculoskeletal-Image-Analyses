function img = Uncrop(img, pad)
    img = padarray(img, [pad(1), pad(3), pad(5)], 'pre');
    img = padarray(img, [pad(2), pad(4), pad(6)], 'post');
end

