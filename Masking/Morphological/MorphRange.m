% NAME-MorphRange
% DESC-Uses mask at start and end of morph range as template to generate
% mask in the middle
% IN-handles.endMorph: The slice at the top of the area to be generated
% handles.startMorph: The slice at the bottom of the area to be generated
% handles.bwContour: The 3d mask, must have values at startMorph and 
% endMorph slices
% OUT-handles.bwContour: The 3d mask between startMorph and endMorph slices
function MorphRange(hObject, handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'bwContour')
            % Adjust the morph ranges if needed to ensure they make sense
            sm = handles.startMorph;
            em = handles.endMorph;
            if sm < 1
                sm = 1;
            end
            if sm > handles.abc(3)
                sm = handles.abc(3);
            end
            if em > handles.abc(3)
                em = handles.abc(3);
            end
            if em < sm
               em = sm;
            end
            
            % Get the shape formed by the mask at startMorph and endMorph and
            % apply the it to the mask between start and end
            bwTemp = interp_shape(handles.bwContour(:,:,em), handles.bwContour(:,:,sm), em-sm+1);
            handles.bwContour(:,:,sm:em) = bwTemp;        
            updateContour(hObject, handles);
        else
            noMaskError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end

