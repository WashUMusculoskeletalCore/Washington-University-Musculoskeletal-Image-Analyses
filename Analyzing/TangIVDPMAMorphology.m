% NAME-TangIVDPMAMorphology
% DESC-Analyzes different regions of the intervertebral disc using saved
% masks and generates a results file. Has an option to analyze the notocord
% IN-notocord: set to true if this analysis should include the notocord
% handles.savedMasks: The saved 3D masks, must include masks for the
% full intervertebral disc and the NP (nucleus pulposus)
% handles.img: the 3D image to be analyzed
% handles.lowerThreshold: the brightness threshold used to identify the notocord
% OUT-TangIVDPMAResults.txt: a tab delimited text file containing the
% results of the analysis
% Disc.fig: a 3D image file showing the masks
function [hObject,eventdata,handles] = TangIVDPMAMorphology(hObject,eventdata,handles,notocord)
    try
        setStatus(hObject, handles, 'Busy');
        if isfield(handles, 'img')
            % Get two masks from saved masks, NP and total
%             answer = inputdlg('Please type in the name of the mask representing the NP');
%             while ~isKey(handles.savedMasks, answer{1})
%                 answer = inputdlg('Not a valid saved mask name. Please type in the name of the mask representing the NP or enter nothing to quit');
%                 if answer{1} == ""
%                     error('No mask selected');
%                 end
%             end
%             bwNP = handles.savedMasks(answer{1});
            bwNP = selectMask(handles, 'Please type in the name of the mask representing the NP');
%             answer = inputdlg('Please type in the name of the mask representing the complete disc');
%             while ~isKey(handles.savedMasks, answer{1})
%                 answer = inputdlg('Not a valid saved mask name. Please type in the name of the mask representing the complete disc or enter nothing to quit');
%                 if answer{1} == ""
%                     error('No mask selected');
%                 end
%             end
%             bwTotal = handles.savedMasks(answer{1});
            bwTotal = selectMask(handles, 'Please type in the name of the mask representing the complete disc');
                
            % Get the area in the disk but not NP to find AF(annulus fibrosus)
            bwAF = bwTotal(~bwNP);
            % Find average value of the area of the image covered by each mask
            meanTotal = mean(handles.img(bwTotal));
            meanAF = mean(handles.img(bwAF));
            meanNP = mean(handles.img(bwNP));
            % Calculate volume
            afVolume = nnz(bwAF) * handles.info.SliceThickness^3;
            totalVolume = nnz(bwTotal) * handles.info.SliceThickness^3;
            npVolume = nnz(bwNP) * handles.info.SliceThickness^3;    
            if notocord
                bwNC = handles.img(bwNP) > handles.lowerThreshold;
                meanNC = mean(handles.img(bwNC));
                ncVolume = nnz(bwNC) * handles.info.SliceThickness^3;
                ncArea = shpFromBW(bwNC,3);
                ncArea = ncArea.surfaceArea * handles.info.SliceThickness^2;
            end
            
            % Generate a graphic
            answer = inputdlg('Do you want to generate a picture? y or n');
            if strcmpi(answer{1},'y')
                shp = shpFromBW(bwTotal,3);
                figure;
                plot(shp,'FaceColor','b','LineStyle','none','FaceAlpha',0.3);
                hold on;
                shp = shpFromBW(bwNP,3);
                plot(shp,'FaceColor','r','LineStyle','none');
                if notocord
                    shp = shpFromBW(bwNC,3);
                    plot(shp,'FaceColor','c','LineStyle','none');
                end
                camlight();
                saveas(gcf,fullfile(handles.pathstr,'Disc.fig'));
            end
            % Output to file
            fid = fopen(fullfile(handles.pathstr,'TangIVDPMAResults.txt'),'a');
            fprintf(fid,'%s\t','Date Analysis Performed');
            fprintf(fid,'%s\t','DICOM Path');
            fprintf(fid,'%s\t','Total Volume (mm^3)');
            fprintf(fid,'%s\t','AF Volume (mm^3)');
            fprintf(fid,'%s\t','NP Volume (mm^3)');
            if notocord
                fprintf(fid,'%s\t','NC Volume (mm^3)');
                fprintf(fid,'%s\t','NC Area (mm^2)');
            end
            fprintf(fid,'%s\t','Lower Threshold');
            fprintf(fid,'%s\t','Upper Threshold');
            fprintf(fid,'%s\t','Mean Total');
            fprintf(fid,'%s\t','Mean AF');         
            if notocord
               fprintf(fid,'%s\t','Mean NP');
               fprintf(fid,'%s\n','Mean NC'); 
            else
                fprintf(fid,'%s\n','Mean NP');
            end
            fprintf(fid,'%s\t',datestr(now));
            fprintf(fid,'%s\t',handles.pathstr);
            fprintf(fid,'%s\t',num2str(totalVolume));
            fprintf(fid,'%s\t',num2str(afVolume));
            fprintf(fid,'%s\t',num2str(npVolume));
            if notocord
                fprintf(fid,'%s\t',num2str(ncVolume));
                fprintf(fid,'%s\t',num2str(ncArea));
            end
            fprintf(fid,'%s\t',num2str(handles.lowerThreshold));
            fprintf(fid,'%s\t',num2str(handles.upperThreshold));
            fprintf(fid,'%s\t',num2str(meanTotal));
            fprintf(fid,'%s\t',num2str(meanAF));
            if notocord
                fprintf(fid,'%s\t',num2str(meanNP));
                fprintf(fid,'%s\n',num2str(meanNC));
            else
                fprintf(fid,'%s\n',num2str(meanNP));
            end
            fclose(fid);
        else
            noImageError();
        end
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end
