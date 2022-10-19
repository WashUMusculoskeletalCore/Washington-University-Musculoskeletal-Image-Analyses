% NAME-PrintReport
% DESC-Prints a report file. Will create a new file, or append to it if it
% exists. Can print multiple lines of data.
% IN-filename: The name and path of the file to save to
% header: A cell array containing the headers
% results: A cell array containing the results. Results can be arrays
% OUT: Creates or updates (filename)
function PrintReport(filename, header, results)
    if exist(filename,'file') ~= 2
        % Create the file if it doesn't exist
        fid = fopen(filename,'w');
        % Write the headers
        for i = 1:length(header)-1
            fprintf(fid,'%s\t',header{i});
        end
        fprintf(fid,'%s\n',header{end});
    else
        % Append to the file if it does exist
        fid = fopen(filename,'a');
    end          
    % Converts all character arrays in the results into strings
    % Ensures that each character is not treated as a new line
    for i = 1:length(results)
        results{i} = convertCharsToStrings(results{i});
    end
    % Find the number of rows to print
    sz = max(cellfun(@length, results));
    for i = 1:sz
        for j = 1:length(results)-1
            % Print the results that have data for this row, skip the others
            if length(results{j}) >= i
                fprintf(fid,'%s\t',num2str(results{j}(i)));
            else
               fprintf(fid,'%s\t','');
            end
        end
        if length(results{end}) >= i
            fprintf(fid,'%s\n',num2str(results{end}(i)));
        else
            fprintf(fid,'%s\n','');
        end
    end
    fclose(fid);
end

