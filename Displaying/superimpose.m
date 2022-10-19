% NAME-superimpose
% DESC-displays the current image slice, or the current image slice with a
% superimposed image
% IN-handles.img: the 3D image
% varargin{1}: the image to superimpose
% handles.slice: the current slice of the image
% handles.lout: the lower range of the output window
% handles.hout: the higher range of the output window
% handles.axesIMG: the axes to align the image to
% handles.colormap: the image colormap
% OUT-Displays the image(s)
function superimpose(handles, varargin)
    adjusted = imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)]);
    if nargin >= 2
        % Show the current slice of handles.img and img2 superimposed
        imshowpair(adjusted,varargin{1},'blend','Parent',handles.axesIMG);
    else
        imshow(adjusted,'Parent',handles.axesIMG);  
    end
    % Set the colormap
    colormap(handles.axesIMG,handles.colormap);   
    % Display Pixel Information tool
    impixelinfo(handles.axesIMG);   
end

