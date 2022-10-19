% NAME-UpdateEmptyRegions
% DESC-Identifies the ranges of all masked slices
% IN-handles.bwContour: the 3d mask
% OUT-handles.maskedRanges: the list of ranges with a mask
function handles = UpdateEmptyRegions(handles)
    if isfield(handles, 'bwContour')
        % Create an array showing 1 for every slice without a mask
        empties = zeros([1, handles.abc(3)]);
        for i = 1:handles.abc(3)
            if isempty(find(handles.bwContour(:,:,i), 1))
                empties(i) = 1;
            end
        end

        % Find where the empties array changes and mark as starts or stops
        diffs = diff(empties);
        starts = find(diffs == -1);
        starts = starts + 1;
        stops = find(diffs == 1);

        % Also mark start and end as start or stop if not empty
        if empties(1) ~= 1
            starts = [1,starts];
        end

        if empties(handles.abc(3)) ~= 1
            stops = [stops, handles.abc(3)];
        end

        % Pair every start with its respective stop
        el = cell(length(starts));
        for i = 1:length(starts)
            el{i} = [num2str(starts(i)) ' , ' num2str(stops(i))];
        end
    else
        el=[];
    end
    set(handles.text13,'String',el);   
    handles.maskedRanges = el;
        


