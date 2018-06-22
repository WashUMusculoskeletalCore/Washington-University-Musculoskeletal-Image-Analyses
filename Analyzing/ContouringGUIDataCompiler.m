function ContouringGUIDataCompiler()

%%Assumes text files are in measurement folder; select the parent folder to
%%these folders when prompted

pathstrParent = uigetdir(pwd,'Please select the parent folder containing your measurement folders');

CollectCorticalData(pathstrParent);
CollectCancellousData(pathstrParent);

function CollectCorticalData(pathstrParent)
%%cortical first
dirs = dir(pathstrParent);
for i = 3:length(dirs)
    if dirs(i).isdir == 1
        files = dir(fullfile(pathstrParent,dirs(i).name,'*cortical*.txt'));
        if length(files) > 0 && isempty(whos('out'))
            [out] = CreateCorticalResultFile(pathstrParent,dirs(i),files(1));
        end
        for j = 1:length(files)
            if ~contains(files(j).name,'FullLength')
                f = fullfile(pathstrParent,dirs(i).name,files(j).name);
                fid = fopen(f);
                line = fgetl(fid);
                while ischar(line)
                    line = fgetl(fid);
                    if line ~= -1
                        fprintf(out,'%s\n',line);
                    end
                end
            end
        end
    end
end
fclose(fid);
fclose(out);

function [out] = CreateCorticalResultFile(pathstrParent,dirs,file)
try
    out = fopen(fullfile(pathstrParent,'CorticalResultsCompiled.txt'),'w');
    f = fullfile(pathstrParent,dirs.name,file.name);
    fid = fopen(f);
    line = fgetl(fid);
    fprintf(out,'%s\n',line);
catch
    'Cannot create result file, see Dan'
end

function CollectCancellousData(pathstrParent)
%%cortical first
dirs = dir(pathstrParent);
for i = 3:length(dirs)
    if dirs(i).isdir == 1
        files = dir(fullfile(pathstrParent,dirs(i).name,'*cancellous*.txt'));
        if length(files) > 0 && isempty(whos('out'))
            [out] = CreateCancellousResultFile(pathstrParent,dirs(i),files(1));
        end
        for j = 1:length(files)
            if ~contains(files(j).name,'FullLength')
                f = fullfile(pathstrParent,dirs(i).name,files(j).name);
                fid = fopen(f);
                line = fgetl(fid);
                while ischar(line)
                    line = fgetl(fid);
                    if line ~= -1
                        fprintf(out,'%s\t',fullfile(pathstrParent,dirs(i).name));
                        fprintf(out,'%s\n',line);
                    end
                end
            end
        end
    end
end
fclose(fid);
fclose(out);

function [out] = CreateCancellousResultFile(pathstrParent,dirs,file)
try
    out = fopen(fullfile(pathstrParent,'CancellousResultsCompiled.txt'),'w');
    f = fullfile(pathstrParent,dirs.name,file.name);
    fid = fopen(f);
    line = fgetl(fid);
    fprintf(out,'%s\t','File Location');
    fprintf(out,'%s\n',line);
catch
    'Cannot create result file, see Dan'
end
