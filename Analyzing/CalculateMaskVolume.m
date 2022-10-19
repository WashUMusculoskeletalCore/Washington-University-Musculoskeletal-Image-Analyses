% NAME-CalculateMaskVolume
% DESC-Calculates the volume of the mask
% IN-handles.mask: the 3D mask
% handles.info.SliceThickness: the thickness of each slice in mm, used for
% voxel size
% OUT-UI: displays a textbox with the volume
function CalculateMaskVolume(handles)
    % Get the number of nonzero elements of bwContour
    nz = nnz(handles.bwContour);
    % Multiply by the voxel size cubed
    vol = nz * handles.info.SliceThickness^3;
    msgbox(['The volume of this mask is ' num2str(vol) 'mm^3']);

