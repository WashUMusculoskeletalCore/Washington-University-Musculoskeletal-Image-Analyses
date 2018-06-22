function SaveMasksAsLabelMatrix(hObject,eventdata,handles)

names = fieldnames(handles);
pathstr = fullfile(handles.pathstr,'labelImage.tif');
[a b c] = size(handles.img);
labels = zeros(a,b,c,'uint8');
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
saveastiff(labels,pathstr);