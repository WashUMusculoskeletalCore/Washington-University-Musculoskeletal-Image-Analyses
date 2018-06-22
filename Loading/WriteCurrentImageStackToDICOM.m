function WriteCurrentImageStackToDICOM(hObject,eventdata,handles)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    [a b c] = size(handles.img);
    
    zers = '00000';
    handles.info.Rows = a;
    handles.info.Columns = b;
    handles.info.InstitutionName = 'Washington University in St. Louis';
    handles.info.SliceThickness = handles.info.SliceThickness / handles.imgScale;
    handles.info.Height = a;
    handles.info.Width = b;
    handles.info.PixelSpacing = [handles.info.SliceThickness;handles.info.SliceThickness];
    handles.info.PixelSpacing = handles.info.PixelSpacing .* handles.imgScale;
    handles.info.StudyDescription = handles.DICOMPrefix;
    
    
    %for ZEISS scans
    if ~isempty(strfind(handles.info.Manufacturer,'Zeiss'))
        mkdir(fullfile(handles.pathstr, handles.DICOMPrefix));
        tmpDir = fullfile(handles.pathstr,handles.DICOMPrefix);
        tmp = dicominfo(fullfile(pwd,'ZeissDICOMTemplate.dcm'));%read info from a known working Zeiss DICOM
        tmp2 = tmp;
        for i = 1:c
            tmp2.FileName = [handles.DICOMPrefix zers(1:end - length(num2str(i))) num2str(i) '.dcm'];
            tmp2.Rows = handles.info.Rows;
            tmp2.Columns = handles.info.Columns;
            tmp2.InstitutionName = handles.info.InstitutionName;
            tmp2.SliceThickness = handles.info.SliceThickness;
            tmp2.Height = handles.info.Height;
            tmp2.Width = handles.info.Width;
            tmp2.PixelSpacing = handles.info.PixelSpacing;
            tmp2.StudyDescription = handles.info.StudyDescription;
            tmp2.KVP = handles.info.KVP;
            zers2 = '000000';
            slice = num2str(i);
            len = length(slice);
            tmp2.MediaStorageSOPInstanceUID = ['1.2.826.0.1.3680043.8.435.3015486693.35541.' zers(1:end-len) num2str(i)];
            tmp2.SOPInstanceUID = tmp2.MediaStorageSOPInstanceUID;
            tmp2.PatientName.FamilyName = handles.DICOMPrefix;
            tmp2.ImagePositionPatient(3) = tmp2.ImagePositionPatient(3) + tmp2.SliceThickness;
            set(handles.textPercentLoaded,'String',num2str(i/c));
            drawnow();
            fName = [handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.dcm'];
            dicomwrite(handles.img(:,:,i),fullfile(tmpDir,fName),tmp2);
        end
    elseif ~isempty(strfind(handles.info.Manufacturer,'SCANCO'))
        mkdir(fullfile(handles.pathstr,handles.DICOMPrefix));
        tmpDir = fullfile(handles.pathstr,handles.DICOMPrefix);
        %sort out info struct for writing; dicomwrite won't write private fields
        tmp = handles.info;
        if isfield(tmp,'Private_0029_1000')%identifies as Scanco original DICOM file
            handles.info.ReferringPhysicianName.FamilyName = num2str(tmp.Private_0029_1004);%will be slope for density conversion
            handles.info.ReferringPhysicianName.GivenName = num2str(tmp.Private_0029_1005);%intercept
            handles.info.ReferringPhysicianName.MiddleName = num2str(tmp.Private_0029_1000);%scaling
            handles.info.ReferringPhysicianName.NamePrefix = num2str(tmp.Private_0029_1006);%u of water
        end
        for i = 1:c
            if i == 1
                info = handles.info;
                info.FileName = fullfile(handles.pathstr,[handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i) '.dcm']);
            else
                info.SliceLocation = info.SliceLocation + info.SliceThickness;
                info.ImagePositionPatient = info.ImagePositionPatient + info.SliceThickness;
                info.FileName = fullfile(handles.pathstr,[handles.DICOMPrefix zers(1:end-length(num2str(i))) num2str(i)  '.dcm']);
                %         info.MediaStorageSOPInstanceUID = num2str(str2num(info.MediaStorageSOPInstanceUID) + 1);
                %         info.SOPInstanceUID = num2str(str2num(info.SOPInstanceUID) + 1);
                
            end
            set(handles.textPercentLoaded,'String',num2str(i/c));
            drawnow();
            fName = [handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.dcm'];
            dicomwrite(handles.img(:,:,i),fullfile(tmpDir,fName),info);
        end
    else
        mkdir(fullfile(handles.pathstr,handles.DICOMPrefix))
        tmpDir = fullfile(handles.pathstr,handles.DICOMPrefix);
        %sort out info struct for writing; dicomwrite won't write private fields
        tmp = handles.info;
        for i = 1:c
            if i == 1
                info = handles.info;
                info.SliceLocation = 1;
                info.FileName = fullfile(handles.pathstr,[handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i) '.dcm']);
            else
                info.SliceLocation = info.SliceLocation + info.SliceThickness;
                info.ImagePositionPatient = info.ImagePositionPatient + info.SliceThickness;
                info.FileName = fullfile(handles.pathstr,[handles.DICOMPrefix zers(1:end-length(num2str(i))) num2str(i)  '.dcm']);
                %         info.MediaStorageSOPInstanceUID = num2str(str2num(info.MediaStorageSOPInstanceUID) + 1);
                %         info.SOPInstanceUID = num2str(str2num(info.SOPInstanceUID) + 1);
                
            end
            set(handles.textPercentLoaded,'String',num2str(i/c));
            drawnow();
            fName = [handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.dcm'];
            dicomwrite(handles.img(:,:,i),fullfile(tmpDir,fName),info);
        end
        
    end
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end