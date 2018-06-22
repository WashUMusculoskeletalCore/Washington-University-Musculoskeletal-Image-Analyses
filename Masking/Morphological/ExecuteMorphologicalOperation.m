function [hObject,eventdata,handles] = ExecuteMorphologicalOperation(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    
    if strcmp(handles.morphologicalOperation,'Close') == 1
        if strcmp(handles.morphological2D3D,'2D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                [a b c] = size(handles.bwContour);
                for i = 1:c
                    handles.bwContour(:,:,i) = imclose(handles.bwContour(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                [a b c] = size(handles.img);
                for i = 1:c
                    handles.img(:,:,i) = imclose(handles.img(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            end
        elseif strcmp(handles.morphological2D3D,'3D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                handles.bwContour = imclose(handles.bwContour,true(handles.morphologicalRadius));
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                handles.img = imclose(handles.img,true(handles.morphologicalRadius));
            end
        end
    elseif strcmp(handles.morphologicalOperation,'Open') == 1
        if strcmp(handles.morphological2D3D,'2D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                [a b c] = size(handles.bwContour);
                for i = 1:c
                    handles.bwContour(:,:,i) = imopen(handles.bwContour(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                [a b c] = size(handles.img);
                for i = 1:c
                    handles.img(:,:,i) = imopen(handles.img(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            end
        elseif strcmp(handles.morphological2D3D,'3D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                handles.bwContour = imopen(handles.bwContour,true(handles.morphologicalRadius));
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                handles.img = imopen(handles.img,true(handles.morphologicalRadius));
            end
        end
    elseif strcmp(handles.morphologicalOperation,'Erode') == 1
        if strcmp(handles.morphological2D3D,'2D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                [a b c] = size(handles.bwContour);
                for i = 1:c
                    handles.bwContour(:,:,i) = imerode(handles.bwContour(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                [a b c] = size(handles.img);
                for i = 1:c
                    handles.img(:,:,i) = imerode(handles.img(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            end
        elseif strcmp(handles.morphological2D3D,'3D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                handles.bwContour = imerode(handles.bwContour,true(handles.morphologicalRadius));
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                handles.img = imerode(handles.img,true(handles.morphologicalRadius));
            end
        end
    elseif strcmp(handles.morphologicalOperation,'Dilate') == 1
        if strcmp(handles.morphological2D3D,'2D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                [a b c] = size(handles.bwContour);
                for i = 1:c
                    handles.bwContour(:,:,i) = imdilate(handles.bwContour(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                [a b c] = size(handles.img);
                for i = 1:c
                    handles.img(:,:,i) = imdilate(handles.img(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            end
        elseif strcmp(handles.morphological2D3D,'3D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                handles.bwContour = imdilate(handles.bwContour,true(handles.morphologicalRadius));
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                handles.img = imdilate(handles.img,true(handles.morphologicalRadius));
            end
        end
    elseif strcmp(handles.morphologicalOperation,'Fill') == 1
        if strcmp(handles.morphological2D3D,'2D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                [a b c] = size(handles.bwContour);
                for i = 1:c
                    handles.bwContour(:,:,i) = imfill(handles.bwContour(:,:,i),'holes');
                end
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                [a b c] = size(handles.img);
                for i = 1:c
                    handles.img(:,:,i) = imfill(handles.img(:,:,i),'holes');
                end
            end
        elseif strcmp(handles.morphological2D3D,'3D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                handles.bwContour = imfill(handles.bwContour,'holes');
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                handles.img = imfill(handles.img,'holes');
            end
        end
    end
    
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end