function varargout = contouringGUI(varargin)
% CONTOURINGGUI MATLAB code for contouringGUI.fig
%      CONTOURINGGUI, by itself, creates a new CONTOURINGGUI or raises the existing
%      singleton*.
%
%      H = CONTOURINGGUI returns the handle to a new CONTOURINGGUI or the handle to
%      the existing singleton*.
%
%      CONTOURINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTOURINGGUI.M with the given input arguments.
%
%      CONTOURINGGUI('Property','Value',...) creates a new CONTOURINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before contouringGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to contouringGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help contouringGUI

% Last Modified by GUIDE v2.5 11-Oct-2022 10:35:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @contouringGUI_OpeningFcn, ...
    'gui_OutputFcn',  @contouringGUI_OutputFcn, ...
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

% NAME-contouringGUI_OpeningFcn
% DESC-Executes just before contouringGUI is made visible, initializes the
% workspace
function contouringGUI_OpeningFcn(hObject, ~, handles, varargin)

    % Choose default command line output for contouringGUI
    handles.output = hObject;

    %set potential filter parameters
    handles.pathstr = getenv('USERPROFILE');
    % sysLine = ['md "' handles.pathstr '\Documents\contouringGUI"'];
    % system(sysLine);
    % handles.pathstr = [handles.pathstr '\Documents\contouringGUI'];
    % sysLine = ['del "' handles.pathstr '\*.mat'];
    % system(sysLine);
    handles.robust = 0;

    % pause flag
    handles.startStop = 0;
    handles.moveLower = false;
    handles.moveUpper = false;

    setStatus(handles, 'Not Busy');

    handles.STLColor = [255 0 0]; % Red
    handles.rotateAxis = 2; % X axis    
    handles.toggleMask = get(handles.togglebuttonToggleMask,'Value') == 1; 

    hObject = splashscreen(hObject);

    % Update handles structure
    guidata(hObject, handles);
 
 
% NAME-pushbuttonLoadTifStack_Callback
% DESC-Executes on button press, loads an image from a tif stack
function pushbuttonLoadTifStack_Callback(hObject, ~, handles)
    LoadTiffStack(hObject, handles);
    
function varargout = contouringGUI_OutputFcn(~, ~, handles)
    varargout{1} = handles.output;
    % Display a message box with information on opening
	%msgbox('Test', 'modal');
    
% NAME pushbuttonLoadIMG
% DESC-Executes on button press, loads an image from DICOM stack
function pushbuttonLoadIMG_Callback(hObject, ~, handles) 
    LoadDICOMStack(hObject, handles);
    
% NAME-pushbuttonDrawContour_Callback    
% DESC-Executes on button press, allows the user to draw a black and white
% mask
% IN-UI: Freehand 2d image draw by user
% handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function pushbuttonDrawContour_Callback(hObject, ~, handles)% %%encapsulated
    DrawContour(hObject, handles);
    
% NAME-pushbuttonSubtractContour_Callback
% DESC-Executes on button press, allows the user to draw a black and white
% mask to be removed from the current mask
% IN-UI: Freehand 2d image draw by user
% handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function pushbuttonSubtractContour_Callback(hObject, ~, handles)
    SubtractContour(hObject, handles);
    
% NAME-pushbuttonAddContour_Callback
% DESC-Executes on button press, allows the user to draw a black and white
% mask to be added to the current mask
% IN-UI: Freehand 2d image draw by user
% handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function pushbuttonAddContour_Callback(hObject, ~, handles)
    AddContour(hObject, handles);
    
% NAME-pushbuttonMorphRange_Callback
% DESC-Executes on button press, uses mask at start and end of morph range 
% as template to generate mask in the middle
% IN-handles.endMorph: The slice at the top of the area to be generated
% handles.startMorph: The slice at the bottom of the area to be generated
% handles.bwContour: The 3d mask, must have values at startMorph and 
% endMorph slices
% OUT-handles.bwContour: The 3d mask between startMorph and endMorph slices 
function pushbuttonMorphRange_Callback(hObject, ~, handles)
    MorphRange(hObject, handles);
    
% NAME-pushbuttonAdjustCurrentSlice_Callback
% DESC-Executes on button press, adjusts the mask on the current slice to
% match the image
% IN-handles.img: The 3d image to be matched
% handles.bwContour: The 3d mask, should have a value on the current slice
% close to a object in the image
% handles.slice: The number of the current slice to be adjusted
% OUT-Handles.bwCountor: The 3d mask, with the current slice adjusted
function pushbuttonAdjustCurrentSlice_Callback(hObject, ~, handles)
    AdjustCurrentSlice(hObject, handles);

% NAME-pushbuttonExecuteAnalysis_Callback
% DESC-Executes on button press, performs the chosen analysis
% IN-handles.analysis: The analysis option chosen by dropdown menu
% OUT-Calls the chosen function
function pushbuttonExecuteAnalysis_Callback(hObject, ~, handles)
switch handles.analysis
    case 'Cortical'
        CorticalAnalysis(handles);
    case 'Cancellous'
        CancellousAnalysis(handles);       
    case 'TangIVDPMA'
        TangIVDPMAMorphology(handles, false);   
    case 'MakeDatasetIsotropic'
        MakeDatasetIsotropic(hObject, handles);
    case 'GenerateHistogram'
        GenerateHistogram(handles);
    case 'SaveCurrentImage'
        SaveCurrentImage(handles);
    case 'WriteToTiff'
        WriteToTiff(handles);
    case 'MakeGif'
        MakeGif(handles);
    case 'LinearMeasure'
        LinearMeasure(handles);           
    case 'TangIVDPMANotochord'
        TangIVDPMAMorphology(handles, true);    
    case 'NeedlePuncture'
        NeedlePunctureImage(handles);    
    case 'MaskVolume'
        CalculateMaskVolume(handles);    
    case 'RegisterVolumes'
        RegisterVolumes;    
    case 'DensityAnalysis'
        DensityAnalysis(handles);    
    case 'ConvertTo-DistanceMap'
        DistanceMap(hObject, handles);   
    case 'ConvertTo-Hounsfield'
        ConvertToDensity(hObject, handles, 2);    
    case 'ConvertTo-mgHAperCCM'
        ConvertToDensity(hObject, handles, 1);	
    case 'WriteToDICOM'
        WriteCurrentImageStackToDICOM(handles);	
    case 'ThicknessVisualization'
        ThicknessVisualization(handles);	
    case 'CTHistomorphometry'
        CTHistomorphometry(handles);   
    otherwise
        disp('pushbuttonExecuteAnalysis_Callback: Invalid option chosen');
end

% NAME-togglebuttonIterateBackwards_Callback
% DESC-Executes on button toggle, Generates 3d mask matching image object 
% boundary by iteratively using existing mask as guide for mask in previous slice
% IN-handles.bwContour: The 3d mask, must have a value for the current slice
% handles.slice: the current slice to start at
% handles.img: the 3d image to be matched, should be continuous
% handles.startStop: a toggle button to start and stop the process
% handles.contourMethod: the contouring method to be used by the algorithm
% handles.smoothFactor: the smooth factor to be used by the algorithm
% handles.contractionBias: the contraction bias to be used by the algorithm
% handles.iterations: The number of iterations to be used by the algorithm
% OUT-handles.bwContour: will be matched
% handles.slice: will move down
% handles.togglebuttonIterateForwards: Turns off if on
% UI: display the new masks
function togglebuttonIterateBackwards_Callback(hObject, ~, handles)
    set(handles.togglebuttonIterateForwards,'Value', 0);
    IterateContour(hObject, handles);

% NAME-togglebuttonIterateForwards_Callback
% DESC-Executes on button toggle, Generates 3d mask matching image object 
% boundary by iteratively using existing mask as guide for mask in next slice
% IN-handles.bwContour: The 3d mask, must have a value for the current slice
% handles.slice: the current slice to start at
% handles.img: the 3d image to be matched, should be continuous
% handles.startStop: a toggle button to start and stop the process
% handles.contourMethod: the contouring method to be used by the algorithm
% handles.smoothFactor: the smooth factor to be used by the algorithm
% handles.contractionBias: the contraction bias to be used by the algorithm
% handles.iterations: The number of iterations to be used by the algorithm 
% OUT-handles.bwContour: will be matched
% handles.slice: will move up
% handles.togglebuttonIterateBackwards: Turns off if on
% UI: display the new masks
function togglebuttonIterateForwards_Callback(hObject, ~, handles)
    set(handles.togglebuttonIterateBackwards,'Value', 0);
    IterateContour(hObject, handles);

% NAME-pushbuttonClearMaskRange_Callback  
% DESC-remove all masks between the startMorph and endMorph slices 
% IN-handles.startMorph: the number of the slice to start clearing
% handles.endMorph: the number of the slice to stop clearing
% OUT-handles.bwContour: all slices in range set to false
function pushbuttonClearMaskRange_Callback(hObject, ~, handles)
    if isfield(handles, 'bwContour')
        startRange=max([handles.startMorph, 1]);
        endRange=min([handles.endMorph, size(handles.bwContour, 3)]);
        handles.bwContour(:,:,startRange:endRange) = false(size(handles.bwContour(:,:,startRange:endRange)));
        updateContour(hObject, handles);
    else
        noMaskError;
    end

% NAME-pushbuttonClearAllMasks_Callback
% DESC-executes on button press, removes bwContour field if it exists, deleting all masks
% OUT-handles.bwContour, deletes this field
function pushbuttonClearAllMasks_Callback(hObject, ~, handles)
    if isfield(handles,'bwContour')
        handles = rmfield(handles,'bwContour');
        updateContour(hObject, handles);
    else
        noMaskError;
    end
        

% NAME-editStartMorph
% DESC-Executes on text entry, sets the starting slice to match the
% chosen value
% IN-hObject: The textbox
% OUT-handles.startMorph: the start of the slice range for morphological operations
function editStartMorph_Callback(hObject, eventdata, handles)
    if isfield(handles, 'img')
        editNumberTextBox_Callback(hObject, eventdata, handles, 'startMorph', true, true, 1, handles.endMorph);
    else
        set(hObject, 'String', '');
    end

% NAME-editEndMorph
% DESC-Executes on text entry, sets the stopping slice to match the
% chosen value
% IN-hObject: The textbox
% OUT-handles.endMorph: the end of the slice range for morphological operations   
function editEndMorph_Callback(hObject, eventdata, handles)
    if isfield(handles, 'img')
        editNumberTextBox_Callback(hObject, eventdata, handles, 'endMorph', true, true, handles.startMorph, handles.abc(3));
    else
        set(hObject, 'String', '');
    end

% NAME-pushbuttonUpdateEmptyRegions_Callback
% DESC-Executes on button press in pushbuttonUpdateEmptyRegions, identify
% the ranges of all masked slices
% IN-handles.bwContour: the 3d mask
% OUT-handles.maskedRanges: the list of ranges with a mask
function pushbuttonUpdateEmptyRegions_Callback(hObject, ~, handles)
    try
        setStatus(handles, 'Busy');
        handles = UpdateEmptyRegions(handles);
        guidata(hObject, handles);
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end

% NAME-pushbuttonCreate3DObject_Callback
% DESC-Executes on button press, displays a 3D image of the mask
% IN-handles.bwContour: the black and white mask
% handles.sphereSize: the maximum distance between adjacent points in the
% shape
% OUT-handles.shp: a 3 shape created from the mask, 
% Displays the shape drawn as a 3D image
function pushbuttonCreate3DObject_Callback(hObject, ~, handles)
    setStatus(handles, 'Busy');
    if isfield(handles, 'bwContour')
        % Generate 3d shape from masks 
        [~, mask] = CropImg(handles.bwContour);
        handles.shp = shpFromBW(mask, handles.sphereSize);
        % Create new window and display the shape in it
        figure();
        plot(handles.shp,'FaceColor',handles.STLColor ./ 255,'LineStyle','none');
        camlight();

        guidata(hObject, handles);
    else
        noMaskError();
    end
    setStatus(handles, 'Not Busy');

% NAME-pushbuttonWriteSTL_Callback
% DESC-Executes on button press, writes the shape to a stl file
% IN-handles.shp: the shape to be written to the file, contains
% shp.boundaryFacets and shp.points
% handles.stlWriteMethod: the method to be used to write to the file, can
% be ascii or binary(default)
% handles.pathstr: the pathstring of the folder to write to
% handles.DICOMPrefix: the prefix to apply to the filename
% handles.STLColor: the color to use in binary files
% OUT-IO: writes a stl file
function pushbuttonWriteSTL_Callback(~, ~, handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'shp')
        if strcmpi(handles.stlWriteMethod,'ascii') == 1
            % Generate a filename
            fName = [handles.DICOMPrefix '-' num2str(handles.info.SliceThickness) 'mm_scale-stl-ascii.stl'];
            % Write shape to an ascii file
            stlwrite(fullfile(handles.pathstr,fName),handles.shp.boundaryFacets,handles.shp.Points,'mode','ascii');
        else 
            % Generate a filename
            fName = [handles.DICOMPrefix  '-' num2str(handles.info.SliceThickness) 'mm_scale-stl.stl'];
            % Write shape to a binary file
            stlwrite(fullfile(handles.pathstr,fName),handles.shp.boundaryFacets,handles.shp.Points,'FaceColor',handles.STLColor);
        end
        else
            errorMsg('Use the Create 3D object button to generate the shape first.');
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end
    
% NAME-pushbuttonSetMaskThreshold_Callback
% DESC-Executes on button press, sets mask to 1 in all parts of image between
% thresholds and 0 elsewhere
% IN-handles.img: the 3D image
% handles.lowerThreshold, handles.upperThreshold: the lower and upper
% bounds of brightness to examine in the image
% OUT-handles.bwContour: the 3D mask
function pushbuttonSetMaskThreshold_Callback(hObject, ~, handles)
    setStatus(handles, 'Busy');
    if isfield(handles, 'img')
        handles.bwContour = handles.img >= handles.lowerThreshold & handles.img <= handles.upperThreshold;
        updateContour(hObject, handles);
    else
        noImgError();
    end
    setStatus(handles, 'Not Busy');

% NAME-pushbuttonRemoveSpeckleNoiseFromMask_Callback
% DESC-Executes on button press, removes small objects from mask
% IN-handles.speckleSize: the maximum size of object to be removed
% OUT-handles.bwContour: the 3D mask
function pushbuttonRemoveSpeckleNoiseFromMask_Callback(hObject, ~, handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'bwContour')
            % Remove all areas smaller than speckleSize from BWContour
            handles.bwContour = bwareaopen(handles.bwContour,handles.speckleSize);
            updateContour(hObject, handles);
        else
            noMaskError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end

% NAME-pushbuttonScaleImageSize_Callback
% DESC-Executes on button press in pushbuttonScaleImageSize, resizes the
% image
% IN-handles.imgScale: the factor to scale the image by
% OUT-handles.img: the image to be rescaled
% handles.bwContour: the mask to also be rescaled
% handles.abc: the height, width, and depth of the image
% handles.sliderIMG: the slider to select the slice
% handles.textVoxelSize: the size of text ovelaid on the image
% handles.info.sliceThickness: the size of one voxel
function pushbuttonScaleImageSize_Callback(hObject, ~, handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'img')
            % Resize img in 3 dimensions by imgScale
            handles.img = imresize3(handles.img,handles.imgScale);
            % Set abc to new size
            handles = abcResize(handles);
            % Reset slider to new size
            handles.sliderIMG = resizeSlider(handles.sliderIMG, handles.abc(3));
            % Rescale the voxel size
            handles.info.SliceThickness = handles.info.SliceThickness / handles.imgScale;
            set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
            % If bwContour exists, resize it too
            if isfield(handles,'bwContour')
                % imresize3 doesn't handles logical arrays, so convert to int
                handles.bwContour = logical(imresize3(int8(handles.bwContour),handles.imgScale));
                updateContour(hObject, handles);
            else
                updateImage(hObject, handles);
            end
        else
            noImgError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end

% NAME-pushbuttonIsolateObjectOfInterest_Callback
% DESC-Executes on button press, isolates the region selected by the mask
% IN-handles.bwContour: the 3D mask
% OUT-handles.img: the 3D image
function pushbuttonIsolateObjectOfInterest_Callback(hObject, ~, handles)
    % Remove everything not in mask from image
    if isfield(handles, 'bwContour')
        handles.img(~handles.bwContour) = 0;
        updateImage(hObject, handles);
    else
        noMaskError();
    end

% NAME-pushbuttonCropImageToMask_Callback    
% DESC-Executes on button press, crops the image around the box containing
% the mask
% IN-handles.bwContour: the 3D mask
% OUT-handles.img: the 3D image
function pushbuttonCropImageToMask_Callback(hObject, ~, handles)
    if isfield(handles, 'bwContour')
        [~, handles.bwContour, handles.img] = CropImg(handles.bwContour, handles.img);
        % Set abc to new size 
        handles = abcResize(handles);
        updateContour(hObject, handles);
    else
        noMaskError();
    end

% NAME-pushbuttonSetMaskToComponent_Callback
% DESC-Executes on button press, select one mask component and remove all
% others
% IN-UI: the component selected by dropdown menu
% OUT-handles.bwContour-the 3D mask, reduced to one component
function pushbuttonSetMaskToComponent_Callback(hObject, ~, handles)
    try        
        setStatus(handles, 'Busy');
        if isfield(handles, 'bwContour')
            % Get a sorted list of components by size descending
            cc = bwconncomp(handles.bwContour);
            numObj = cc.NumObjects;
            numPixels = cellfun(@numel,cc.PixelIdxList);
            [~, I] = sort(numPixels,'descend');
            % Ask the user to select a component
            index = 0;
            while isnan(index) || index <= 0 || index ~= floor(index) 
                answer = inputdlg(['Select a component 1-' num2str(numObj)]);
                if isempty(answer)
                    error('ContouringGUI:InputCanceled', 'Input dialog canceled');
                end
                index = str2double(answer{1});
            end
            % Remove all components except the selected one
            bw = false(size(handles.bwContour));
            bw(cc.PixelIdxList{(I(index))}) = 1;
            handles.bwContour = bw;
            updateContour(hObject, handles);
        else
            noMaskError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end

% NAME-pushbuttonInvertImage_Callback  
% DESC-Inverts the image, replacing light with dark and vice versa
% IN-handles.dataMax/dataMin: the minimum and maximum values of the image
% data
% handles.img: the original 3D image
% OUT-handles.img: the image with black and white reversed
function pushbuttonInvertImage_Callback(hObject, ~, handles)
    if isfield(handles, 'img')
        % This formula will keep the range of values the same
        handles.img = handles.dataMax+handles.dataMin - handles.img;
        updateImage(hObject, handles);
    else
        noImgError();
    end

% NAME-popupmenuSTLColor_Callback
% DESC-Executes on selection change, sets the STL color to match the
% selected option
% IN-handles.popupmenuSTLColor-the color chosen in the popup memu
% OUT-handles.STLColor-the color used in STL files, in rgb format
function popupmenuSTLColor_Callback(hObject, ~, handles)
    switch getPopupSelection(handles.popupmenuSTLColor)
        case 'Red'
            handles.STLColor = [255 0 0];
        case 'Green'
            handles.STLColor = [0 255 0];
        case 'Blue'
            handles.STLColor = [0 0 255];
        case 'Cyan'
            handles.STLColor = [0 255 255];
        case 'Magenta'
            handles.STLColor = [255 0 255];
        case 'Yellow'
            handles.STLColor = [255 255 0];
        case 'Black'
            handles.STLColor = [0 0 0];
        case 'White'
            handles.STLColor = [255 255 255];
    end
    guidata(hObject, handles);


% NAME-textPercentLoaded_CreateFcn    
% DESC-Sets the percent loaded to 0
function textPercentLoaded_CreateFcn(hObject, ~, ~)
    set(hObject,'String', [sprintf('%0.3f', 0), ' %']);

% NAME-pushbuttonRotateImage_Callback
% DESC-Executes on button press, rotates the image and mask a selected 
% number of degrees
% IN-handles.rotateDegrees: The number of degrees to rotate
% OUT-handles.img: The rotated image
% handles.bwContour: The rotated mask
function pushbuttonRotateImage_Callback(hObject, ~, handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'img')
            Rotate(hObject, handles, handles.rotateDegrees);
        else
            noImgError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end
    
% NAME-pushbuttonMultiRotate_Callback
% DESC-Creates a window allowing the user to rotate the image multiple times 
% without data loss
% IN-handles.img: The 3D image
% handles.rotateDegrees: The number of degrees to rotate
% OUT-handles.rotatePreview: The preview window
% handles.rotateAxes: The axes for displaying the preview image
% handles.rotateOriginal: The displayed slice of the original image to be rotated
% handles.currentAngle: The sum of all angles the image has been rotated by
function pushbuttonMultiRotate_Callback(hObject, ~, handles)
    setStatus(handles, 'Busy');
    if isfield(handles, 'img')
        if ~isfield(handles, 'rotatePreview') || ~isgraphics(handles.rotatePreview)
            % Initialize the preview
            handles.rotatePreview = figure(Name='Rotation Preview', NumberTitle='off',DeleteFcn={@multiRotateClose, hObject});
            set(gcf, 'MenuBar', 'none', 'ToolBar', 'none');
            handles.rotateAxes = axes;
            handles.rotateOriginal = handles.img(:,:,handles.slice);
            handles.currentAngle = 0;
        else
            % Bring the preview into focus
            figure(handles.rotatePreview);
        end
        % Update the image
        handles.currentAngle = handles.currentAngle+handles.rotateDegrees;
        rotation = imrotate(handles.rotateOriginal,handles.currentAngle,"crop");
        imshow(rotation, Parent=handles.rotateAxes);
        guidata(hObject, handles);
        setStatus(handles,'Not Busy')
    else
        noImgError;
    end
% NAME-multiRotateClose
% DESC-Called when rotation preview is closed, applies the rotation to the
% image
% IN- handles.currentAngle: The sum of all angles the image has been rotated by
% OUT-handles.img: The rotated image
% handles.bwContour: The rotated mask
function multiRotateClose(~,~, hObject)
    try
        % Retrieve the up to date handles data
        handles = guidata(hObject);
        setStatus(handles,'Busy');
        % Ask whether or not to use the rotation
        answer = inputdlg(['Rotate the image ' num2str(handles.currentAngle) ' degrees? y/n']);
        if isempty(answer)
            error('ContouringGUI:InputCanceled', 'Input dialog canceled');
        end
        if answer{1} =='y'
            Rotate(hObject, handles, handles.currentAngle)
        end
        setStatus(handles,'Not Busy');
    catch err
        reportError(err, handles);
    end

% NAME-pushbuttonFlipImage_Callback
% DESC-Executes on button press, flips the image along the chosen axis
% IN-handles.rotateAxis: the axis to flip along
% OUT-handles.img: the flipped image
% handles.bwContour: the flipped mask
function pushbuttonFlipImage_Callback(hObject, ~, handles)
    if isfield(handles, 'img')
        % Flip the image and mask around the axis
        handles.img = flip(handles.img,handles.rotateAxis);
        if isfield(handles,'bwContour')
            handles.bwContour = flip(handles.bwContour,handles.rotateAxis);
            updateContour(hObject, handles);
        else
            updateImage(hObject, handles);
        end
    else
        noImgError();
    end

% NAME-popupmenuRotationAxis_Callback
% DESC-Executes on selection change, sets the rotation and flip axis based 
% on the selection
% IN-handles.popupmenuRotationAxis: the axis (xyz) selected in the popup menu
% OUT-handles.rotateAxis: the matrix dimension coresponding to the axis
function popupmenuRotationAxis_Callback(hObject, ~, handles)
    switch getPopupSelection(handles.popupmenuRotationAxis)
        case 'X'
            handles.rotateAxis = 2;
        case 'Y'
            handles.rotateAxis = 1;
        case 'Z'
            handles.rotateAxis = 3;
    end
    guidata(hObject, handles);
   
% NAME-pushbuttonSetMaskByClicking    
% DESC-Executes on button press, allows user to select which mask
% components to keep by clicking on them
% IN-IO: opens a getpts tool to let the user click on the mask
% handles.axesIMG: the axis for the image, used as a reference for point
% selection
% OUT-handles.bwContour: the selected components of the mask
function pushbuttonSetMaskByClicking_Callback(hObject, ~, handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'bwContour')
            % Interactive point selection
            [x, y] = getpts(handles.axesIMG);
            z(1:length(x), 1) = handles.slice;
            pt = round([y, x, z]);% points to use to select mask component
            % Labels connected components of mask
            [pad, handles.bwContour] = CropImg(handles.bwContour);
            cc = bwlabeln(handles.bwContour);
            handles.bwContour = zeros(size(handles.bwContour), 'logical');
            % Get the label at each point, and add all points with that label
            % to mask
            for i = 1:length(pt(:,1))
                try
                    label = cc(pt(i,1)-pad(1), pt(i,2)-pad(3), pt(i,3)-pad(5));
                catch err
                    % If the point is out of bounds, just skip it without crashing
                    if strcmp(err.identifier, 'MATLAB:badsubscript')
                        label = 0;
                    else
                        throw(err);
                    end
                end
                if label ~= 0
                    handles.bwContour(cc==label)=1;
                end
            end
            handles.bwContour = Uncrop(handles.bwContour, pad);
            updateContour(hObject, handles);
        else
            noMaskError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end


% NAME-pushbuttonMorphAll_Callback
% DESC-Executes on button press, extrapolates a shape for the mask
% IN: handles.bwContour: the 3D mask
% OUT: handles.bwContour: the 3D mask with gaps filled in
function pushbuttonMorphAll_Callback(hObject, ~, handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'bwContour')
            empties = zeros(1, handles.abc(3));
            % Identify all slices without mask
            for i = 1:handles.abc(3)
                if isempty(find(handles.bwContour(:,:,i), 1))
                    empties(i) = 1;
                end
            end

            % Identify slices where mask starts and stops
            diffs = diff(empties);
            starts = find(diffs == -1);
            starts = starts + 1;
            stops = find(diffs == 1);

            % If first and last slice aren't empty, add to starts and stops 
            if empties(1) ~= 1
                starts = [1, starts];
            end
            % If there is only one start, there are no gaps
            if length(starts) > 1
                if empties(handles.abc(3)) ~= 1
                    stops = [stops, handles.abc(3)];
                end

                % Identify the range of each mask section
                ranges = zeros(length(starts), 2);
                for i = 1:length(starts)
                    ranges(i,:) = [starts(i), stops(i)];
                end

                % Identify the start and stop of each unmasked section
                for i = 1:length(ranges)-1
                    start = ranges(i,2);
                    stop = ranges(i+1,1);
                    % Attempts to fill gaps by extrapolating from starting and
                    % stopping slice of mask
                    bwTemp = interp_shape(handles.bwContour(:,:,stop),handles.bwContour(:,:,start),abs(start-stop + 1));
                    %bwTemp = flip(bwTemp,3);
                    handles.bwContour(:,:,start+1:stop-1) = bwTemp;
                end
                updateContour(hObject, handles);
            end
        else
            noMaskError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end

% NAME-pushbuttonCreatePrimitive_Callback
% DESC-Executes on button press, creates a rectangle or oval shaped mask
% IN-handles.popupmenuPrimitive: the menu to select the shape, options are Oval and Rectangle
% handles.primitiveHorizontal: the horizontal center of the shape to draw
% handles.primitiveVertical: the vertical center of the shape to draw
% handles.primitiveWidth: the width of the shape
% handles.primitiveHeight: the height of the shape
% handles.primitiveRotationAngle: the angle of the shape
% OUT-handles.bwContour: the mask will be set to the chosen shape
function pushbuttonCreatePrimitive_Callback(hObject, ~, handles)
    if isfield(handles, 'img') 
        switch handles.primitiveShape
            case 'Oval'
                theta = handles.primitiveRotationAngle;
                % Horizontal and vertical axes
                a=handles.primitiveWidth;
                b=handles.primitiveHeight;
                % Ellipse centre coordinates
                xc=handles.primitiveHorizontal; 
                yc=handles.primitiveVertical;
                % Maximum horizontal and vertical distance from center
                xr=ceil(sqrt((a*cos(theta))^2+(b*sin(theta))^2));
                yr=ceil(sqrt((a*sin(theta))^2+(b*cos(theta))^2));

                ct=0;

                %prealocate xq and yq
                xq = zeros(1, (2*xr+1)*(2*yr+1));
                yq = zeros(1, (2*xr+1)*(2*yr+1));
                % Make query set representing the slice in ellipse's bounding rectangle
                for i = xc-xr : xc+xr
                    for j = yc-yr : yc+yr
                        ct=ct+1;
                        xq(ct) = i;
                        yq(ct) = j;
                    end
                end
                % Create the mask if it doesn't exist
                if ~isfield(handles,'bwContour')
                    handles.bwContour = false(handles.abc);
                end
                tmp = false(size(handles.bwContour(:,:,handles.slice)));
                    
                % For each point (xq,yq), if it is inside the ellipse, add it to tmp

                for i = 1:length(xq)
                    if xq(i) >= 1 && xq(i) <= handles.abc(1) && yq(i) >= 1 && yq(i) <= handles.abc(2)
                        if ((xq(i)-xc)*cos(theta)-(yq(i)-yc)*sin(theta)).^2/a^2 + ((xq(i)-xc)*sin(theta)+(yq(i)-yc)*cos(theta)).^2/b^2 <= 1
                            tmp(round(yq(i)),round(xq(i))) = 1;
                        end
                    end
                end
                % Redraw mask for current slice using tmp
                handles.bwContour(:,:,handles.slice) = tmp;
            case 'Rectangle'
                % Create the mask if it doesn't exist
                if ~isfield(handles,'bwContour')
                    handles.bwContour = false(size(handles.img));
                end
                % Retain all plots on current axis
                hold on;
                % TODO-This might need rework to be less dependant on those functions,
                % could reuse ellipse code
                [P,~] = DrawRectangle([handles.primitiveHorizontal,handles.primitiveVertical,...
                    handles.primitiveWidth,handles.primitiveHeight,handles.primitiveRotationAngle]);
                ct=0;
                %prealocate xq and yq
                xq = zeros(1, handles.abc(1).*handles.abc(2));
                yq = zeros(1, handles.abc(1).*handles.abc(2));
                %make query set representing whole slice
                for i = 1:handles.abc(1)
                    for j = 1:handles.abc(2)
                        ct=ct+1;
                        xq(ct) = i;
                        yq(ct) = j;
                    end
                end

                % Identify all points inside the rectangle
                [in] = inpoly([xq',yq'],[P(6:10)',P(1:5)']);
                % Reorient the rectangle
                tmp = reshape(in,[handles.abc(2) handles.abc(1)]);
                tmp = imrotate(tmp,90);
                tmp = flipud(tmp);
                % Set mask to rectangle
                handles.bwContour(:,:,handles.slice) = tmp;
                hold off;
        end
        updateContour(hObject, handles);
    else
        noImgError();
    end

% NAME-pushbuttonTranslateUp
% DESC-Executes on button press, shifts the mask in the desired direction
% IN-handles.translateDown: the distance to travel if translating down
% OUT-handles.bwContour: the mask to be translated% --- Executes on button press in pushbuttonTranslateUp.
function pushbuttonTranslateUp_Callback(hObject, ~, handles)
    Translate(hObject, handles, 'Up');

% NAME-pushbuttonTranslateDown    
% DESC-Executes on button press, shifts the mask in the desired direction
% IN-handles.translateDown: the distance to travel if translating down
% OUT-handles.bwContour: the mask to be translated
function pushbuttonTranslateDown_Callback(hObject, ~, handles)
    Translate(hObject, handles, 'Down');

% NAME-pushbuttonTranslateLeft
% DESC-Executes on button press, shifts the mask in the desired direction
% IN-handles.translateDown: the distance to travel if translating down
% OUT-handles.bwContour: the mask to be translated
function pushbuttonTranslateLeft_Callback(hObject, ~, handles)
    Translate(hObject, handles, 'Left');

% NAME-pushbuttonTranslateRight    
% DESC-Executes on button press, shifts the mask in the desired direction
% IN-handles.translateDown: the distance to travel if translating down
% OUT-handles.bwContour: the mask to be translated
function pushbuttonTranslateRight_Callback(hObject, ~, handles)
    Translate(hObject, handles, 'Right');

% NAME-axesIMG_CreateFcn
% DESC-Executes during object creation, nothing is needed
function axesIMG_CreateFcn(~, ~, ~)

% NAME-pushbuttonZoomtoRegion_Callback
% DESC-Executes on button press, crops the image
function pushbuttonZoomtoRegion_Callback(hObject, ~, handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'img')
            % Create an image with the correct intesity and colormap
            im = imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)]);
            colormap(handles.axesIMG,handles.colormap);
            % Open interactive cropping tool and select a rectangle from the
            % created image
            [~,rect] = imcrop(im);
            if isempty(rect)
                % Handle canceled cropping
                error('ContouringGUI:InputCanceled', 'ROI Deleted');
            end
            % Crop the image and mask to the selected rectangle 
            handles.img = handles.img(round(rect(2)):round(rect(2))+round(rect(4))-1,round(rect(1)):round(rect(1))+round(rect(3))-1,:);
            
            % Update info as well
            handles = abcResize(handles);
            
            if isfield(handles,'bwContour')
                handles.bwContour = handles.bwContour(round(rect(2)):round(rect(2))+round(rect(4))-1,round(rect(1)):round(rect(1))+round(rect(3))-1,:);
                updateContour(hObject,handles);
            else
                updateImage(hObject, handles);
            end
        else
            noImgError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end

% NAME-pushbuttonRotate90_Callback
% DESC-Executes on button press, rotates the image and mask 90 degrees
% IN-handles.rotateAxis:the axis to rotate around
% OUT-handles.img: the rotated image
% handles.bwContour: the rotated mask
function pushbuttonRotate90_Callback(hObject, ~, handles)
    try
        setStatus(handles, 'Busy');
        if isfield(handles, 'img')
            % Rotate image and mask by selected angle
            handles.img = rot90_3D(handles.img, handles.rotateAxis, 1);
            handles = abcResize(handles);
            if isfield(handles,'bwContour')
                handles.bwContour = rot90_3D(handles.bwContour, handles.rotateAxis, 1);
                updateContour(hObject, handles);
            else
                updateImage(hObject, handles);
            end
        else
            noImgError();
        end
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
    end

% NAME-pushbuttonSetLowerThreshold_Callback
% DESC-Toggle button, when on sets the lower threshold to match the slider
% IN-handles.threshold: the value set with the slider or textbox
% OUT-handles.lowerThreshold: the value used for the lower threshold
% textLowerThreshold: the displayed lower threshold value
% handles.moveLower: Whether or not the lower threshold moves with the slider
% handles.moveUpper: Whether or not the upper threshold moves with the slider
function togglebuttonSetLowerThreshold_Callback(hObject, ~, handles)
    handles.moveLower = get(handles.togglebuttonSetLowerThreshold,'Value');
    if handles.moveLower
        handles.moveUpper = false;
        set(handles.togglebuttonSetUpperThreshold,'Value',0);
    end
    updateThreshold(hObject, handles);

% NAME-togglebuttonSetUpperThreshold_Callback    
% DESC-Toggle button, when on sets the upper threshold to match the slider
% IN-handles.threshold: the value set with the slider or textbox
% OUT-handles.upperThreshold: The value used for the upper threshold
% textUpperThreshold: The displayed upper threshold value
% handles.moveLower: Whether or not the lower threshold moves with the slider
% handles.moveUpper: Whether or not the upper threshold moves with the slider
function togglebuttonSetUpperThreshold_Callback(hObject, ~, handles)
    handles.moveUpper = get(handles.togglebuttonSetUpperThreshold,'Value');
    if handles.moveUpper
        handles.moveLower = false;
        set(handles.togglebuttonSetLowerThreshold,'Value',0);        
    end
    updateThreshold(hObject, handles);

% NAME-togglebuttonToggleMask_Callback
% DESC-Executes on button press, toggles whether or not to show the mask
% and image together
% IN-handles.togglebuttonMask: the button to toggle the mask
% OUT-IO: displays the image and mask together
function togglebuttonToggleMask_Callback(hObject, ~, handles)
    handles.toggleMask = get(handles.togglebuttonToggleMask,'Value') == 1;
    updateImage(hObject, handles);

% NAME-pushbuttonLoadTXMFile_Callback
% DESC-Executes on button press in pushbuttonLoadTXMFile.
function pushbuttonLoadTXMFile_Callback(hObject, ~, handles)
    LoadTXM(hObject, handles);

% NAME-pushbuttonExecuteMorphologicalOperation_Callback
% DESC-Executes on button press in pushbuttonExecuteMorphologicalOperation.
function pushbuttonExecuteMorphologicalOperation_Callback(hObject, ~, handles)
    ExecuteMorphologicalOperation(hObject, handles);

% NAME-pushbuttonSetOriginalImage_Callback
% DESC-Executes on button press, saves the current image as the original
% IN-handles.img: The image to be saved
% handles.info.SliceThickness: The slice thickness of the original image
% OUT-handles.imgOrig: The saved copy of the image
% handles.thicknessOrig: The saved slice thickness
function pushbuttonSetOriginalImage_Callback(hObject, ~, handles)
    if isfield(handles, 'img')
        handles = SaveImage(handles);
        setStatus(handles, 'Image saved');
        guidata(hObject, handles);
    else
        noImgError();
    end

% NAME-pushbuttonRevertImage_Callback
% DESC-Executes on button press, reloads the saved image
function pushbuttonRevertImage_Callback(hObject, ~, handles)
    RevertImage(hObject,handles);

% NAME-pushbuttonSetFirstSlice_Callback
% DESC-Executes on button press, crops all slices before the current slice
% IN-handles.slice: the slice to become the new first slice
% OUT-handles.img: the cropped image
% handles.bwCountour: the cropped mask
function pushbuttonSetFirstSlice_Callback(hObject, ~, handles)
    SetFirstSlice(hObject, handles);

% NAME-pushbuttonSetLastSlice_Callback
% DESC-Executes on button press, crops all slices after the current slice
% IN-handles.slice: the slice to become the new last slice
% OUT-handles.img: the cropped image
% handles.bwCountour: the cropped mask 
function pushbuttonSetLastSlice_Callback(hObject, ~, handles)
    SetLastSlice(hObject, handles);

% NAME-pushbuttonInvertMask_Callback
% DESC-Executes on button press, inverts the mask
% OUT-handles.bwContour: the inverted mask
function pushbuttonInvertMask_Callback(hObject, ~, handles)
    if isfield(handles, 'bwContour')
        handles.bwContour = ~handles.bwContour;
        updateContour(hObject, handles);
    else
        noMaskError;
    end

% NAME-pushbuttonCopyMask_Callback
% DESC-Executes on button press, saves a copy of the mask at the current slice
% IN-handles.bwContour: the mask to be saved
% OUT-handles.maskCopy: a copy of the current slice of the mask
function pushbuttonCopyMask_Callback(hObject, ~, handles)
    if isfield(handles, 'bwContour')
        handles.maskCopy = handles.bwContour(:,:,handles.slice);
        guidata(hObject, handles);
    else
        noMaskError;
    end

% NAME-pushbuttonPasteMask_Callback
% DESC-Executes on button press, copies the saved mask to the current slice
% The copied mask is added to the current mask
% IN-handles.maskCopy: the saved mask copy
% OUT-handles.bwContour: the mask to be pasted to
function pushbuttonPasteMask_Callback(hObject, ~, handles)
    if isfield(handles, 'maskCopy')
        % Check that the size of the saved mask matches the size of the image
        if isequal(size(handles.maskCopy), handles.abc(1:2))
            % Create mask if it doesn't exist
            if ~isfield(handles, 'bwContour')
                handles.bwContour =  zeros(size(handles.img), "logical");
            end
            % Paste the copied mask onto the current slice
            handles.bwContour(:,:,handles.slice) = handles.maskCopy;
            updateContour(hObject, handles);
        else
            errorMsg('Saved mask is not the same size as image.');
        end
    else
        errorMsg('This function requires a copied mask to use.');
    end

% NAME-pushbuttonStoreMask_Callback
% DESC-Executes on button press, saves the current mask
% IN-handles.bwContour: the mask to be saved
% handles.maskName: the name to save the mask as
% OUT-handles.savedMasks: a map containing all of the saved masks
function pushbuttonStoreMask_Callback(hObject, ~, handles)
    setStatus(handles, 'Busy');
    if isfield(handles, 'bwContour')
        if isfield(handles, 'savedMasks')
            % Create a new subfield in savedMasks or overwrite one
            handles.savedMasks(handles.maskName) = handles.bwContour;
        else
            % Create the savedMasks field and the first subfield
            handles.savedMasks = containers.Map({handles.maskName}, {handles.bwContour});
        end
        set(handles.popupmenuEditMaskName, 'String', keys(handles.savedMasks));
        guidata(hObject, handles);
    else
        noMaskError;
    end
    setStatus(handles, 'Not Busy')

% NAME-popupmenuEditMaskName_Callback
% DESC-Selects a mask name from the list of saved names
% IN-hObject: The popup menu
% OUT-handles.editMaskName: The mask name textbox
% handles.maskName: The name of the mask to save or load
function popupmenuEditMaskName_Callback(hObject, ~, handles)
    maskName = getPopupSelection(hObject);
    if ~strcmp(maskName, '')
        handles.maskName = maskName;
        set(handles.editMaskName,'String',maskName);
        guidata(hObject, handles);
    end


% NAME-pushbuttonSetColorMap_Callback   
% DESC-Executes on button press, sets the color map to the chosen value
% IN-handles.popupmenuSetColorMap: the color map popup menu
% OUT-handles.colormap: the name of the color map used to display the
% image, default is grey (black to white greyscale)
function pushbuttonSetColorMap_Callback(hObject, ~, handles)
    handles.colormap = getPopupSelection(handles.popupmenuSetColorMap);
    updateImage(hObject, handles);

% NAME-popupmenuSetColorMap_Callback
% DESC-Executes on selection change, does nothing(handled by
% pushbuttonSetColorMap_Callback)
function popupmenuSetColorMap_Callback(~, ~, ~)

% NAME-togglebuttonRobustThickness_Callback
% DESC-Executes on button press, toggles the robust thickness option
% IN-handles.togglebuttonRobustThickness: the robust thickness toggle button
% OUT-handles.robust: the robust thickness option, is used in some analyses
function togglebuttonRobustThickness_Callback(hObject, ~, handles)
    if get(handles.togglebuttonRobustThickness,'Value') == 1
        set(handles.togglebuttonRobustThickness,'BackgroundColor',[1, 0, 0]); % Set the button color to red when on
        handles.robust = 1;
    elseif get(handles.togglebuttonRobustThickness,'Value') == 0
        set(handles.togglebuttonRobustThickness,'BackgroundColor',[.94, .94, .94]); % Set color to dark grey when off
        handles.robust = 0;
    end
    guidata(hObject, handles);

% NAME-pushbuttonSaveWorkspace_Callback
% DESC-Executes on button press, saves the current workspace settings
function pushbuttonSaveWorkspace_Callback(~, ~, handles)
    SaveWorkspace(handles);

% NAME-pushbuttonLoadWorkspace_Callback
% DESC-Executes on button press, loads a previously saved workspace
function pushbuttonLoadWorkspace_Callback(hObject, ~, handles)
    LoadWorkspace(hObject, handles);

% NAME-pushbuttonMakeIsotropic_Callback
% DESC-Adjusts the dataset to make the slice thickness match the pixel size
function pushbuttonMakeIsotropic_Callback(hObject, ~, handles)
    MakeDatasetIsotropic(hObject, handles);

% NAME-pushbuttonLoadMask_Callback  
% DESC-sets the mask to one previous saved with Store Mask
function pushbuttonLoadMask_Callback(hObject, ~, handles)
    LoadMask(hObject,handles);

% NAME-pushbuttonUseForContouring_Callback
% DESC-Saves the current image as the original if none exists, and adjusts
% the image's thresholds
function pushbuttonUseForContouring_Callback(hObject, ~, handles)
    UseForContouring(hObject, handles);

% NAME-pushbuttonExecuteFilter_Callback
% DESC-Applies the chosen filter to the image
% IN-handles.popupmenuFilter: the popup menu for choosing the filter
% handles.sigma: the wieght to use for the filters
% handles,radius: the radius to use for the filters
% OUT-handles.img: the filtered image
function pushbuttonExecuteFilter_Callback(hObject, ~, handles)
    ExecuteFilter(hObject, handles);

% Generic Callbacks
% Parameters for these should be set in the Callback property of the
% appropriate UIControl

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

% NAME-editStringTextBox_Callback
% DESC-Gets the value entered in a textbox
% IN-hObject: The textbox
% model: The name of the field to store the value in
% OUT-handles.(model): The selected value       
function editStringTextBox_Callback(hObject, ~, handles, model)
    handles.(model) = get(hObject, 'String');
    guidata(hObject, handles);
          
% NAME-editPopup_Callback
% DESC-Gets the value seleceted from a popup menu
% IN-hObject: The popup menu
% model: The name of the field to store the value in
% OUT-handles.(model): The selected value   
function editPopup_Callback(hObject, ~, handles, model)
    handles.(model) = getPopupSelection(hObject);
    guidata(hObject, handles);
 
% NAME-editSliderTextBox_Callback
% DESC-Gets a number entered in a text box and automatically corrects
% incorrect values if possible
% IN-hObject: The textbox
% model: The name of the field to store the value in
% slider: The name of the slider connected with the textbox
% update_Fcn: The function to call after the values are updated
% OUT-handles.(model): The selected value 
% handles.(slider) Value: The position of the slider
function editSliderTextBox_Callback(hObject, ~, handles, model, slider, update_Fcn) 
    value = str2double(get(hObject,'String'));    
    if ~isnan(value) && isfield(handles, 'img') % Check that the value is a number, and the image has been initialized
        % Ensure that the value matches all requirements and fix it if it
        % doesn't
        changed = false; 
        if  value ~= round(value)
            value = round(value);
            changed = true;
        end
        min = get(handles.(slider), 'Min');
        max = get(handles.(slider), 'Max');
        if value < min
            value = min;
            changed = true;
        elseif value > max
            value = max;
            changed = true;
        end
        handles.(model) = value;
        % If the value has been fixed, update the textbox
        if changed
            set(hObject, 'String', num2str(value));
        end
        set(handles.(slider),'Value',handles.(model));
        update_Fcn(hObject, handles);
        guidata(hObject, handles);
        return;
    end
    % If the value entered is not a fixable, replace the text with the
    % original value if it exists, or a blank
    if isfield(handles, model)
        set(hObject, 'String', num2str(handles.(model)));
    else
        set(hObject, 'String', '');
    end

% NAME-slider_Callback
% DESC-Gets a value from a slider
% IN-hObject: The slider
% model: The name of the field to store the value in
% textbox: The textbox connected with the slider
% update_Fcn: The function to call after the values are updated
% OUT-handles.(model): The selected value 
% handles.(textbox) String: The value displayed in the textbox       
function slider_Callback(hObject, ~, handles, model, textbox, update_Fcn)
    % Check if the value has changed since the last callback to prevent
    % callback queue buildup
    if isfield(handles, model) && handles.(model) ~= round(get(hObject,'Value'))
        handles.(model) = round(get(hObject,'Value'));
        set(handles.(textbox),'String',num2str(handles.(model)));
        update_Fcn(hObject, handles);       
    end    
    
        
% NAME-editTextBox_CreateFcn  
% DESC-Executes on object creation, sets the backup background color to white     
function editTextBox_CreateFcn(hObject, ~, ~)
    setBackground(hObject, 'white');
    
% NAME-editNumberTextBox_CreateFcn  
% DESC-Executes on object creation, sets the backup background color to white, initialize the model value 
% IN-hObject: The text box
% model: The name of the field to store the value in
% OUT-handles.(model): The selected value   
function editNumberTextBox_CreateFcn(hObject, eventdata, handles, model)
    editTextBox_CreateFcn(hObject, eventdata, handles)
    handles.(model) = str2double(get(hObject,'String'));
    guidata(hObject, handles);
 
% NAME-editStringTextBox_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white, initialize the model value 
% IN-hObject: The text box
% model: The name of the field to store the value in
% OUT-handles.(model): The selected value   
function editStringTextBox_CreateFcn(hObject, eventdata, handles, model)
    editTextBox_CreateFcn(hObject, eventdata, handles);
    editStringTextBox_Callback(hObject, eventdata, handles, model);
 
% NAME-editPopup_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white, initialize the model value 
% IN-hObject: The popup menu
% model: The name of the field to store the value in
% OUT-handles.(model): The selected value      
 function editPopup_CreateFcn(hObject, eventdata, handles, model)
    editTextBox_CreateFcn(hObject, eventdata, handles);
    editPopup_Callback(hObject, eventdata, handles, model);  
    
% NAME-slider_CreateFcn
% DESC-Executes on object creation, sets the backup background color to dark grey 
function slider_CreateFcn(hObject, ~, ~)
    setBackground(hObject, [.9, .9, .9]);
    
