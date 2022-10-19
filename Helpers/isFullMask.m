% NAME-isFullMask
% DESC-Checks if a mask exists in every slice
% IN-mask: The 3D mask
% OUT-masked: True if there is a non-empty mask in every slice, false otherwise
function masked = isFullMask(mask)
    masked = true;
    for i = 1:size(mask, 3)
        if nnz(mask(:,:,i)) == 0
            masked = false;
            break;
        end
    end
end

