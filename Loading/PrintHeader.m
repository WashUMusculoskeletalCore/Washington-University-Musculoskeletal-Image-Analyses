function PrintHeader(fid, header)
    for i = 1:length(header)-1
        fprintf(fid,'%s\t',header{i});
    end
    fprintf(fid,'%s\n',header{end});
end