function SaveMasksAsLabelMatrix(hObject,eventdata,handles)

names = fieldnames(handles);
% Determine the path to save to
pathstr = fullfile(handles.pathstr,'labelImage.tif');
[a b c] = size(handles.img);
% Create 3d array of labels
labels = zeros(a,b,c,'uint8');
% Check every handles field and combines one-five to labels
% TODO- might be faster to only check the 5 fields
for i = 1:length(names)
    if strcmp(names(i),'one') == 1
        labels(handles.one) = 1;
    elseif strcmp(names(i),'two') == 1
        labels(handles.two) = 2;
    elseif strcmp(names(i),'three') == 1
        labels(handles.three) = 3;
    elseif strcmp(names(i),'four') == 1
        labels(handles.four) = 4;
    elseif strcmp(names(i),'five') == 1
        labels(handles.five) = 5;
    end
end
% imwrite(labels,pathstr);
% Save labels as a tiff file
saveastiff(labels,pathstr);