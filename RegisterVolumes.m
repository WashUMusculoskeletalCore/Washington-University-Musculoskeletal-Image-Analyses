function varargout = RegisterVolumes(varargin)
% REGISTERVOLUMES MATLAB code for RegisterVolumes.fig
%      REGISTERVOLUMES, by itself, creates a new REGISTERVOLUMES or raises the existing
%      singleton*.
%
%      H = REGISTERVOLUMES returns the handle to a new REGISTERVOLUMES or the handle to
%      the existing singleton*.
%
%      REGISTERVOLUMES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGISTERVOLUMES.M with the given input arguments.
%
%      REGISTERVOLUMES('Property','Value',...) creates a new REGISTERVOLUMES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RegisterVolumes_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RegisterVolumes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RegisterVolumes

% Last Modified by GUIDE v2.5 27-Sep-2022 11:47:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RegisterVolumes_OpeningFcn, ...
                   'gui_OutputFcn',  @RegisterVolumes_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% NAME-RegisterVolumes_OpeningFcn
% DESC-Executes just before RegisterVolumes is made visible, initializes handles
function RegisterVolumes_OpeningFcn(hObject, ~, handles, varargin)

    % Choose default command line output for RegisterVolumes
    handles.output = hObject;
    
    handles.sliceMoving = 1;
    handles.sliceReference = 1;
    handles.fusedSlice = 1;
    
    % Update handles structure
    guidata(hObject, handles);


% NAME-RegisterVolumes_OutputFcn
% DESC-Returns the handle for the RegisterVolumes figure to the calling function
function varargout = RegisterVolumes_OutputFcn(~, ~, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;


% NAME-pushbuttonFlipAxis_Callback
% DESC-Flips the moving image over the selected axis
% IN-handles.popupmenuAxis: The axis popup menu
% OUT-handles.imgMoving: The moving image
function pushbuttonFlipAxis_Callback(hObject, ~, handles)
    if isfield(handles, 'imgMoving')
        axNum = str2double(handles.axis);
        handles.imgMoving = flip(handles.imgMoving, axNum);
        updateImage(hObject, handles);
    else
        noImgError;
    end

% NAME-pushbuttonRotate_Callback
% DESC-Rotates the image the specified number of degrees
% IN-handles.degrees: The angle to rotate
% handles.popupmenuPlanarAxial: The popup menu to select planar or axial rotation
% OUT-handles.imgMoving: The moving image
function pushbuttonRotate_Callback(hObject, ~, handles)
    if isfield(handle, 'imgMoving')
        switch handles.plAx
            case 'planar'
                % Rotate the image around the center point
                handles.imgMoving = imrotate(handles.imgMoving,handles.degrees);
            case 'axial'
                % Select the axis to rotate around
                ax = str2double(handles.axis);
                matrix = [0,0,0];
                matrix(ax)=1;
                handles.imgMoving = imrotate3(handles.imgMoving,handles.degrees,matrix);
        end
        updateSliders(hObject,handles);  
    else
        noImgError;
    end

% NAME-pushbuttonRegisterVolumes_Callback
% DESC-Attempts to allign the moving image to the reference image
% IN-handles.imgMoving: The moving image
% handles.imgReference: The reference image
% handles.iterations
% OUT-handles.imgRegistered: The transformed moving image
% handles.imgRegTform: The transformation used to created the registered image
function pushbuttonRegisterVolumes_Callback(hObject, ~, handles)
    if isfield(handles, 'imgReference') && isfield(handles, 'imgMoving')
        % Configure image registration for images with similar brightness and
        % contrast (monomodal)
        [optimizer, ~] = imregconfig('monomodal');
        % Set the Mattes Mutual Information algorithm as the metric to use during
        % registration
        metric = registration.metric.MattesMutualInformation;
        optimizer.MaximumIterations = handles.iterations;
    
        % Identify a rigid transformation that will make the moving image matcg
        % the reference image
        handles.imgRegTform = imregtform(handles.imgMoving,handles.imgReference,'rigid',optimizer,metric,...
            'DisplayOptimization',1,'PyramidLevels',4);
        % Transform and display the moving image at the same size as the
        % reference image
        handles.imgRegistered = imwarp(handles.imgMoving,handles.imgRegTform,'OutputView',imref3d(size(handles.imgReference)));
        
        [~, ~, c] = size(handles.imgRegistered);
        % Create a composite of the reference and registered images slice by slice
        % Preallocated array
        sz = max(size(handles.imgReference, [1 2 3]), size(handles.imgRegistered, [1 2 3]));
        handles.fused = zeros(sz, "uint16");
        for i = 1:c
            handles.fused(:,:,i) = im2uint16(imfuse(handles.imgReference(:,:,i),handles.imgRegistered(:,:,i),'blend'));
        end
        % Update sliders to size of fused image
        [~, ~, c] = size(handles.fused);
        handles.sliderFused = resizeSlider(handles.sliderFused, c);
        % Display the fused image
        imshow(handles.fused(:,:,1),'Parent',handles.axesFused);
        updateSliders(hObject, handles)
    else
        noImgError;
    end

% NAME-pushbuttonLoadMovingVolume_Callback
% DESC-Loads a DICOM or txm file into the moving image
% IN-Gets a filename from the user
% handles.movingFileType: The moving image filetype selected
% OUT-handles.imgMoving: The moving image
% handles.infoMoving: The moving image data
function pushbuttonLoadMovingVolume_Callback(hObject, ~, handles)
    loadVolume(hObject, handles, 'moving');

% NAME-pushbuttonLoadReferenceVolume_Callback
% DESC-Loads a DICOM or txm file into the reference image
% IN-Gets a filename from the user
% handles.referenceFileType: The reference image filetype selected
% OUT-handles.imgReference: The reference image
% handles.infoReference: The reference image data
function pushbuttonLoadReferenceVolume_Callback(hObject, ~, handles)
    loadVolume(hObject, handles, 'reference');

% NAME-loadVolume
% DESC-Loads a DICOM or txm file
% IN-image: Determines whether to load the moving or refernce image
% OUT-handles.(img): The loaded image
% handles.(info): The info data structure
function loadVolume(hObject, handles, image)
    switch image
        case 'moving'
            filetype = 'movingFileType';
            pathstr = 'pathstrMoving';
            img = 'imgMoving';
            info = 'infoMoving';
            slider = 'sliderMoving';
        case 'reference'
            filetype = 'referenceFileType';
            pathstr = 'pathstrReference';
            img = 'imgReference';
            info = 'infoReference';
            slider =  'sliderReference';
    end
    
    switch handles.(filetype)
        % Select directory containing DICOM stack in UI
        case 'DICOM'
            handles.(pathstr) = uigetdir(pwd,'Please select the folder of the volume to be registered');
            [handles.(img), handles.(info)] = readDICOMStack(handles.(pathstr));
        % Select txm file in UI
        case'TXM'
            [fileName, pathName] = uigetfile([pwd '\*.txm'],'Please select your TXM file');
            [header, headerShort] = txmheader_read8(fullfile(pathName,fileName));
            % Fills info with preset value
            % TODO- Move presets to configuraion file
            handles.(info) = headerShort;
            handles.(info).SliceThickness = handles.(info).PixelSize;
            handles.(info).SliceThickness = handles.(info).SliceThickness / 1000;
            handles.(info).Height = handles.(info).ImageHeight;%may need to be switched with below
            handles.(info).Width = handles.(info).ImageWidth;
            handles.(info).BitDepth = 16;
            handles.(info).Format = 'DICOM';
            handles.(info).FileName = handles.(info).File;
            handles.(info).FileSize = handles.(info).Height * handles.(info).Width * 2^16;
            handles.(info).FormatVersion = 3;
            handles.(info).ColorType = 'grayscale';
            handles.(info).Modality = 'CT';
            handles.(info).Manufacturer = 'Zeiss';
            handles.(info).InstitutionName = 'Washington University in St. Louis';
            handles.(info).PatientName = fileName(1:end-4);
            handles.(info).KVP = txmdata_read8(header,'Voltage');
            handles.(info).DeviceSerialNumber = '8802030299';
            handles.(info).BitsAllocated = 16;
            handles.(info).BitsStored = 15;
            handles.(info).SliceLocation = 20;
            handles.(info).ImagePositionPatient = [0;0;handles.(info).SliceLocation];
            handles.(info).PixelSpacing = [handles.(info).SliceThickness;handles.(info).SliceThickness];
        
            handles.(img) = zeros([headerShort.ImageWidth headerShort.ImageHeight headerShort.NoOfImages],'uint16');
            % Adjust slider to new size
            ct=0;
            for i = 1:headerShort.NoOfImages
                ct=ct+1;
                handles.(img)(:,:,i) = txmimage_read8(header,ct,0,0);
            end
    
    end

    % Adjust slider to new size
    [~,~,c] = size(handles.(img));
    handles.(slider) = resizeSlider(handles.(slider), c);    
    updateImage(hObject, handles);

% NAME-updateImage
% DESC-Displays the moving and reference images
% IN-handles.imgMoving: The moving image
% handles.imgReference: The reference image
% handles.sliceMoving: The moving image current slice
% handles.sliceReference: The reference image current slice
% OUT-Displays the images on the axes
function updateImage(hObject, handles)
    % Show the moving image
    if isfield(handles,'imgMoving')
        imshow(imadjust(handles.imgMoving(:,:,handles.sliceMoving)),'Parent',handles.axesMovingXY);
    end
    % Show the reference image
    if isfield(handles,'imgReference')
        imshow(imadjust(handles.imgReference(:,:,handles.sliceReference)),'Parent',handles.axesReferenceXY);
    end
    % Show the fused image
    if isfield(handles,'fused')
            imshow(handles.fused(:,:,handles.fusedSlice),'Parent',handles.axesFused);   
    end
    guidata(hObject, handles);


% NAME-pushbuttonCenterMovingToReference_Callback
% DESC-Pads the moving and reference images to align their centers
% OUT-handles.imgReference: The reference image
% handles.imgMoving: The moving image
function pushbuttonCenterMovingToReference_Callback(hObject, ~, handles)
    if isfield(handles, 'imgReference') && isfield(handles, 'imgMoving')
        % For each dimension, if either image is larger than the other, pad the
        % start of the array by half the difference
        [ar, br, cr] = size(handles.imgReference);
        [am, bm, cm] = size(handles.imgMoving);
        
        if ar > am
            aDiff = ar - am;
            handles.imgMoving = padarray(handles.imgMoving,[round(aDiff/2) 0 0]);
        elseif ar < am
            aDiff = am - ar;
            handles.imgReference = padarray(handles.imgReference,[round(aDiff/2) 0 0]);
        end
        
        if br > bm
            bDiff = br - bm;
            handles.imgMoving = padarray(handles.imgMoving,[0 round(bDiff/2) 0]);
        elseif br < bm
            bDiff = bm - br;
            handles.imgReference = padarray(handles.imgReference,[0 round(bDiff/2) 0]);
        end
        
        if cr > cm
            cDiff = cr - cm;
            handles.imgMoving = padarray(handles.imgMoving,[0 0 round(cDiff/2)]);
        elseif cr < cm
            cDiff = cm - cr;
            handles.imgReference = padarray(handles.imgReference,[0 0 round(cDiff/2)]);
        end
        updateSliders(hObject,handles);    
    else
        noImgError;
    end

% NAME-pushbuttonMove_Callback
% DESC-Moves the moving image in the chosen direction
% IN-handles.popupmenuUDLR: The direction popup menu
% handles.numVox: The number of voxels to move the image
% OUT-handles.imgMoving: The moving image
function pushbuttonMove_Callback(hObject, ~, handles)
    if isfield(handles, 'imgMoving')
        [a, b, c] = size(handles.imgMoving);
        
        switch handles.direction
            case 'Left'
                handles.imgMoving = handles.imgMoving(:,handles.numVox:end,:);
                handles.imgMoving(:,end:end+handles.numVox-1,:) = 0;
            case 'Up'
                handles.imgMoving = handles.imgMoving(handles.numVox:end,:,:);
                handles.imgMoving(end:end+handles.numVox-1,:,:) = 0;
            case 'Right'
                handles.imgMoving = handles.imgMoving(:,1:end-handles.numVox,:);
                zeroPad = zeros(a,handles.numVox,c, "uint16");
                handles.imgMoving = [zeroPad,handles.imgMoving];
            case 'Down'
                handles.imgMoving = handles.imgMoving(1:end-handles.numVox,:,:);
                zeroPad = zeros(handles.numVox,b,c,"uint16");
                handles.imgMoving = [zeroPad;handles.imgMoving];
        end
        updateSliders(hObject,handles);
    else
        noImgError;
    end

% NAME-updateSliders
% DESC-Resize sliders based on resized image
% IN-handles.imgReference: The reference image
% handles.imgMoving: The moving image
% OUT-handles.sliderReference: The reference image slider
% handles. sliderMoving: The moving image slider
function handles = updateSliders(hObject, handles)
    % Resize reference slider
    if isfield(handles, 'imgReference')
        [~, ~, c] = size(handles.imgReference);
        handles.sliderReference = resizeSlider(handles.sliderReference, c); 
    end   
    % Resize moving slider
    if isfield(handles, 'imgMoving')
        [~, ~, c] = size(handles.imgMoving);
        handles.sliderMoving = resizeSlider(handles.sliderMoving, c);
    end       
    updateImage(hObject, handles);

% NAME-pushbuttonCropReference_Callback
% DESC-Creates a cropping tool to crop the reference image
% IN-User selects region to crop
% OUT-handles.imgReference: The reference image
function pushbuttonCropReference_Callback(hObject, ~, handles)
    if isfield(handles, 'imgReference')
        handles.imgReference = cropImageTool(handles.axesReferenceXY, handles.imgReference);
        updateImage(hObject, handles);
    else
        noImgError;
    end

% NAME-pushbuttonCropMoving_Callback
% DESC-Creates a cropping tool to crop the moving image
% IN-User selects region to crop
% OUT-handles.imgMoving: The moving image
function pushbuttonCropMoving_Callback(hObject, ~, handles)
    if isfield(handles, 'imgMoving')
        handles.imgMoving = cropImageTool(handles.axesMovingXY, handles.imgMoving);
        updateImage(hObject, handles);
    else
        noImgError;
    end

% NAME-cropImageTool
% DESC-Creates a cropping tool to crop an image
% IN-User selects region to crop
% axes-The axes containing the image to crop
% OUT-image: The cropped image
function image = cropImageTool(axes, image)
    % Create an interactive croping tool
    [~,rect] = imcrop(axes);
    [~, ~, c] = size(image);
    % Initialize temporary image with size of cropped image
    tmpImg = zeros([size(imcrop(image(:,:,1),rect), [1 2]), size(image, 3)], "uint16");
    % Crop every slice of moving image using rect
    for i = 1:c
        tmpImg(:,:,i) = imcrop(image(:,:,i),rect);
    end  
    image = tmpImg;

% NAME-pushbuttonWrite_Callback
% DESC-Writes the registered image to a file
% IN-handles.imgRegistered-The registed image
% handles.infoMoving: The info struct from the moving image
% handles.pathstrMoving: The pathastring from the moving image
% OUT-Writes the registered image as a DICOM
function pushbuttonWrite_Callback(~, ~, handles)
    % Save files from registered image
    if isfield(handles, 'imgRegistered')
        writeCurrentImageStackToDICOM(handles.imgRegistered,handles.infoMoving,handles.pathstrMoving);
        tform = handles.imgRegTform;
        save([handles.pathstrMoving '\Registered\Tform.mat'],'tform');
        % Creates directory for fused images
        mkdir(fullfile(handles.pathstrMoving,'Fused'));
    
        zers = '00000';
        [~, ~, c] = size(handles.fused);
        myDir = fullfile(handles.pathstrMoving,'Fused');
        for i = 1:c
            % Give every filename a unique 5 digit number with leading zeroes
            fName = ['Fused -' zers(1:end-length(num2str(i))) num2str(i) '.tif'];
            % Save the file
            imwrite(handles.fused(:,:,i),fullfile(myDir,fName));
        end
    else
        noImgError;
    end

% NAME-writeCurrentImageStackToDICOM
% DESC-Writes an image to a DICOM file
% IN-img: The image to write
% info: The DICOM info structure
% pathstr: The filepath to write to
function writeCurrentImageStackToDICOM(img,info,pathstr)
    
    DICOMPrefix = 'Registered';
    
    [a, b, c] = size(img);
    
    zers = '00000';
    info.Rows = a;
    info.Columns = b;
    info.InstitutionName = 'Washington University in St. Louis';
    info.Height = a;
    info.Width = b;
    info.PixelSpacing = [info.SliceThickness;info.SliceThickness];
    info.StudyDescription = DICOMPrefix;
    
    %for ZEISS scans
    if ~isempty(strfind(info.Manufacturer,'Zeiss'))
        mkdir(fullfile(pathstr, DICOMPrefix));
        tmpDir = fullfile(pathstr,DICOMPrefix);
        tmp = dicominfo(fullfile(pwd,'ZeissDICOMTemplate.dcm'));%read info from a known working Zeiss DICOM
        tmp2 = tmp;
        for i = 1:c
            tmp2.FileName = [DICOMPrefix zers(1:end - length(num2str(i))) num2str(i) '.dcm'];
            tmp2.Rows = info.Rows;
            tmp2.Columns = info.Columns;
            tmp2.InstitutionName = info.InstitutionName;
            tmp2.SliceThickness = info.SliceThickness;
            tmp2.Height = info.Height;
            tmp2.Width = info.Width;
            tmp2.PixelSpacing = info.PixelSpacing;
            tmp2.StudyDescription = info.StudyDescription;
            tmp2.KVP = info.KVP;
            slice = num2str(i);
            len = length(slice);
            tmp2.MediaStorageSOPInstanceUID = ['1.2.826.0.1.3680043.8.435.3015486693.35541.' zers(1:end-len) num2str(i)];
            tmp2.SOPInstanceUID = tmp2.MediaStorageSOPInstanceUID;
            tmp2.PatientName.FamilyName = DICOMPrefix;
            tmp2.ImagePositionPatient(3) = tmp2.ImagePositionPatient(3) + tmp2.SliceThickness;
            set(textPercentLoaded,'String',num2str(i/c));
            drawnow();
            fName = [DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.dcm'];
            dicomwrite(img(:,:,i),fullfile(tmpDir,fName),tmp2);
        end
    elseif ~isempty(strfind(info.Manufacturer,'SCANCO'))
        mkdir(fullfile(pathstr,DICOMPrefix));
        tmpDir = fullfile(pathstr,DICOMPrefix);
        %sort out info struct for writing; dicomwrite won't write private fields
        tmp = info;
        if isfield(tmp,'Private_0029_1000')%identifies as Scanco original DICOM file
            info.ReferringPhysicianName.FamilyName = num2str(tmp.Private_0029_1004);%will be slope for density conversion
            info.ReferringPhysicianName.GivenName = num2str(tmp.Private_0029_1005);%intercept
            info.ReferringPhysicianName.MiddleName = num2str(tmp.Private_0029_1000);%scaling
            info.ReferringPhysicianName.NamePrefix = num2str(tmp.Private_0029_1006);%u of water
        end
        for i = 1:c
            if i == 1
                info.FileName = fullfile(pathstr,[DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i) '.dcm']);
            else
                info.SliceLocation = info.SliceLocation + info.SliceThickness;
                info.ImagePositionPatient = info.ImagePositionPatient + info.SliceThickness;
                info.FileName = fullfile(pathstr,[DICOMPrefix zers(1:end-length(num2str(i))) num2str(i)  '.dcm']);
            end
            fName = [DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.dcm'];
            dicomwrite(img(:,:,i),fullfile(tmpDir,fName),info);
        end
    else
        mkdir(fullfile(pathstr,DICOMPrefix))
        tmpDir = fullfile(pathstr,DICOMPrefix);
        %sort out info struct for writing; dicomwrite won't write private fields
        for i = 1:c
            if i == 1
                info.SliceLocation = 1;
                info.FileName = fullfile(pathstr,[DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i) '.dcm']);
            else
                info.SliceLocation = info.SliceLocation + info.SliceThickness;
                info.ImagePositionPatient = info.ImagePositionPatient + info.SliceThickness;
                info.FileName = fullfile(pathstr,[DICOMPrefix zers(1:end-length(num2str(i))) num2str(i)  '.dcm']);
            end
            set(textPercentLoaded,'String',num2str(i/c));
            drawnow();
            fName = [DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.dcm'];
            dicomwrite(img(:,:,i),fullfile(tmpDir,fName),info);
        end
    end

% Generic Callbacks
% Parameters for these should be set in the Callback property of the
% appropriate UIControl

% NAME-editTextBox_CreateFcn  
% DESC-Executes on object creation, sets the backup background color to white     
function editTextBox_CreateFcn(hObject, ~, ~)
    setBackground(hObject, 'white');

% NAME-slider_CreateFcn
% DESC-Executes on object creation, sets the backup background color to dark grey 
function slider_CreateFcn(hObject, ~, ~)
    setBackground(hObject, [.9, .9, .9]);

% NAME-slider_Callback
% DESC-Gets a value from a slider
% IN-hObject: The slider
% model: The name of the field to store the value in
% textbox: The textbox connected with the slider
% update_Fcn: The function to call after the values are updated
% OUT-handles.(model): The selected value 
% handles.(textbox) String: The value displayed in the textbox       
function slider_Callback(hObject, ~, handles, model)
    % Check if the value has changed since the last callback to prevent
    % callback queue buildup
    if isfield(handles, model) && handles.(model) ~= round(get(hObject,'Value'))
        handles.(model) = round(get(hObject,'Value'));
        updateImage(hObject, handles);       
    end    

% NAME-popupmenu_Callback
% IN-hObject: The popup menu
% model: The fieldname to store the data in
% OUT-handles.(model): The selected filetype
function popupmenu_Callback(hObject, ~, handles, model)
    handles.(model) = getPopupSelection(hObject);
    guidata(hObject, handles);

% NAME-editPopup_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white, initialize the model value 
% IN-hObject: The popup menu
% model: The name of the field to store the value in
% OUT-handles.(model): The selected value      
 function editPopup_CreateFcn(hObject, eventdata, handles, model)
    editTextBox_CreateFcn(hObject, eventdata, handles);
    popupmenu_Callback(hObject, eventdata, handles, model);  

% NAME-editNumberTextBox_Callback
% DESC-Gets a number entered in a text box and automatically corrects
% incorrect values if possible
% IN-hObject: The textbox
% model: The name of the field to store the value in
% isInt: True if the value must be an int
% nonzero: True if the vale must be nonzero
% min: The minimum value
% max: The maximum value
% OUT-handles.(model): The selected value      
function editNumberTextBox_Callback(hObject, ~, handles, model, isInt, nonzero, min, max)
    value = str2double(get(hObject,'String'));    
    if ~isnan(value) % Check that the value is a number
        % Ensure that the value matches all requirements and fix it if it
        % doesn't
        changed = false; % Flag to determine if the value must be adjusted
        if exist('isInt', 'var') && isInt && value ~= round(value)
            value = round(value);
            changed = true;
        end
        if exist('min', 'var') && value < min
            value = min;
            changed = true;
        elseif exist('max', 'var') && value > max
            value = max;
            changed = true;
        end
        if ~(exist('nonzero', 'var') && nonzero && value == 0)
            handles.(model) = value;
            % If the value has been fixed, update the textbox
            if changed
                set(hObject, 'String', num2str(value));
            end
            guidata(hObject, handles);
            return;
        end
    end
    % If the value entered is not a fixable, replace the text with the
    % original value if it exists, or a blank
    if isfield(handles, model)
        set(hObject, 'String', num2str(handles.(model)));
    else
        set(hObject, 'String', '');
    end

% NAME-editNumberTextBox_CreateFcn  
% DESC-Executes on object creation, sets the backup background color to white, initialize the model value 
% IN-hObject: The text box
% model: The name of the field to store the value in
% OUT-handles.(model): The selected value   
function editNumberTextBox_CreateFcn(hObject, eventdata, handles, model)
    editTextBox_CreateFcn(hObject, eventdata, handles)
    handles.(model) = str2double(get(hObject,'String'));
    guidata(hObject, handles);
