% NAME-WriteCurrentImageStackToDICOM
% DESC-Writes each slice of the current image to a DICOM file
% IN-handles.img: the current image
% handles.DICOMPrefix: the prefix to add to the beginning of every output filename
% handles.info: the info struct to be copied added to the files
% OUT-IO:Writes a set of DICOM files to output directory
function WriteCurrentImageStackToDICOM(hObject, eventdata, handles)
    try
        setStatus(hObject, handles, 'Busy');
        if isfield(handles, 'img')
            handles.info.Rows = handles.abc(1);
            handles.info.Columns = handles.abc(2);
            % TODO-config files
            handles.info.InstitutionName = 'Washington University in St. Louis';
            handles.info.SliceThickness = handles.info.SliceThickness / handles.imgScale;
            handles.info.Height = handles.abc(1);
            handles.info.Width = handles.abc(2);
            handles.info.PixelSpacing = [handles.info.SliceThickness;handles.info.SliceThickness];
            handles.info.PixelSpacing = handles.info.PixelSpacing .* handles.imgScale;
            handles.info.StudyDescription = handles.DICOMPrefix;

            % Initialize directory
            outDir = fullfile(handles.pathstr,handles.DICOMPrefix); 
            mkdir(outDir);
            % Write each image to a file with DICOM info
            % For ZEISS scans
            if ~isempty(strfind(handles.info.Manufacturer,'Zeiss'))
                info = dicominfo(fullfile(pwd,'ZeissDICOMTemplate.dcm'));% Read info from a known working Zeiss DICOM
                for i = 1:handles.abc(3)
                    info.FileName = [handles.DICOMPrefix sprintf('%05d', i) '.dcm']; % Gives i as a 5 digit number with leading zeros 
                    info.Rows = handles.info.Rows;
                    info.Columns = handles.info.Columns;
                    info.InstitutionName = handles.info.InstitutionName;
                    info.SliceThickness = handles.info.SliceThickness;
                    info.Height = handles.info.Height;
                    info.Width = handles.info.Width;
                    info.PixelSpacing = handles.info.PixelSpacing;
                    info.StudyDescription = handles.info.StudyDescription;
                    info.KVP = handles.info.KVP;
                    info.MediaStorageSOPInstanceUID = ['1.2.826.0.1.3680043.8.435.3015486693.35541.' sprintf('%05d', i)];
                    info.SOPInstanceUID = info.MediaStorageSOPInstanceUID;
                    info.PatientName.FamilyName = handles.DICOMPrefix;
                    info.ImagePositionPatient(3) = info.ImagePositionPatient(3) + info.SliceThickness;
                    displayPercentLoaded(hObject, handles, i/handles.abc(3));
                    fName = [handles.DICOMPrefix sprintf('%05d', i) '.dcm'];
                    dicomwrite(handles.img(:,:,i),fullfile(outDir,fName),info);
                end
            % For SCANCO and all other scans   
            else
                info = handles.info;
                for i = 1:handles.abc(3)
                    info.SliceLocation = info.SliceLocation + info.SliceThickness;
                    info.ImagePositionPatient = info.ImagePositionPatient + info.SliceThickness;
                    fName = [handles.DICOMPrefix '-' sprintf('%05d', i)  '.dcm'];
                    info.FileName = fullfile(outDir, fName);
                    displayPercentLoaded(hObject, handles, i/handles.abc(3));
                    if ~isempty(strfind(handles.info.Manufacturer,'SCANCO'))
                        dicomwrite(handles.img(:,:,i),fullfile(outDir, fName), 'WritePrivate', true, info);
                    else
                        dicomwrite(handles.img(:,:,i),fullfile(outDir, fName), info);
                    end
                end
            end
        else
            noImgError();
        end
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end