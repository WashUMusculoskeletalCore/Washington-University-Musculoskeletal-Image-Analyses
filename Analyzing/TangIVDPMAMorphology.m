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
function TangIVDPMAMorphology(handles, notocord)
    try
        setStatus(handles, 'Busy');
        displayPercentLoaded(handles, 0);
        if isfield(handles, 'img')
            % Get two masks from saved masks, NP and total
            bwNP = selectMask(handles, 'Please type in the name of the mask representing the NP');
            bwTotal = selectMask(handles, 'Please type in the name of the mask representing the complete disc');
            displayPercentLoaded(handles, 1/5);
            setStatus(handles, 'Analyzing');
            % Crop the image to the area covered by either mask
            bw = bwNP | bwTotal;
            [~, ~, bwNP, bwTotal, img] = CropImg(bw, bwNP, bwTotal, handles.img);
            displayPercentLoaded(handles, 2/5);
            % Get the area in the disk but not NP to find AF(annulus fibrosus)
            bwAF = bwTotal & ~bwNP;
            % Find average value of the area of the image covered by each mask
            meanTotal = mean(img(bwTotal));
            meanAF = mean(img(bwAF));
            meanNP = mean(img(bwNP));
            % Calculate volume
            afVolume = nnz(bwAF) * handles.info.SliceThickness^3;
            totalVolume = nnz(bwTotal) * handles.info.SliceThickness^3;
            npVolume = nnz(bwNP) * handles.info.SliceThickness^3;    
            if notocord
                % Calculate the notocord only parameters
                bwNC = img(bwNP) > handles.lowerThreshold;
                meanNC = mean(img(bwNC));
                ncVolume = nnz(bwNC) * handles.info.SliceThickness^3;
                ncShp = shpFromBW(bwNC,3);
                ncArea = ncShp.surfaceArea * handles.info.SliceThickness^2;
            end
            displayPercentLoaded(handles, 3/5);
            % Generate a graphic
            answer = inputdlg('Do you want to generate a picture? y or n');
            if isempty(answer)
                error('ContouringGUI:InputCanceled', 'Input dialog canceled');
            end
            if strcmpi(answer{1},'y')
                setStatus(handles, 'Creating figure');
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
            setStatus(handles, 'Writing report');
            displayPercentLoaded(handles, 4/5)
            % Create the notocord only headers and parameters
            if notocord
                ncHeaders = ["NC Volume (mm^3)","NC Area (mm^2)"];
                meanNCHeader = "Mean NC";
                ncData = {ncVolume, ncArea};
                meanNCData = meanNC;
            else
                ncHeaders = [];
                meanNCHeader = [];
                ncData = [];
                meanNCData = [];
            end
            headers = num2cell(["Date Analysis Performed","DICOM Path","Total Volume (mm^3)","AF Volume (mm^3)","NP Volume (mm^3)", ncHeaders,...
                "Lower Threshold","Upper Threshold","Mean Total","Mean AF","Mean NP",meanNCHeader]);

            data = num2cell([string(datestr(now)),string(handles.pathstr),totalVolume,afVolume,npVolume,ncData,...
                handles.lowerThreshold,handles.upperThreshold,meanTotal,meanAF,meanNP,meanNCData]);

            PrintReport(fullfile(handles.pathstr,'TangIVDPMAResults.txt'), headers, data);
        else
            noImgError;
        end
        displayPercentLoaded(handles, 1);
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end
