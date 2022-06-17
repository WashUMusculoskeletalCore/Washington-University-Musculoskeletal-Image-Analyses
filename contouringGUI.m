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

% Last Modified by GUIDE v2.5 25-May-2018 09:38:46

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


% --- Executes just before contouringGUI is made visible.
function contouringGUI_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure


% varargin   command line arguments to contouringGUI (see VARARGIN)

% Choose default command line output for contouringGUI
handles.output = hObject;

%set potential filter parameters
handles.pathstr = getenv('USERPROFILE');
% sysLine = ['md "' handles.pathstr '\Documents\contouringGUI"'];
% system(sysLine);
% handles.pathstr = [handles.pathstr '\Documents\contouringGUI'];
% sysLine = ['del "' handles.pathstr '\*.mat'];
% system(sysLine);
handles.sigma = 0.8;
handles.radius = 3;
handles.robust = 0;

%initialize contouring values
handles.contourMethod = 'Chan-Vese';
handles.smoothFactor = 1;
handles.contractionBias = 0.05;
handles.iterations = 100;

%pause flag
handles.startStop = 0;

setStatus(hObject, handles, 'Not Busy');

%initialize morph start and stop
handles.startMorph = 1;
handles.endMorph = 999;

%set a random threshold to initialize
handles.threshold = 6000;
handles.lowerThreshold = 6000;

%set initial image scale
handles.imgScale = 1;

%pick a random size filter for mask
handles.speckleSize = 20;

% handles.peel = 4;

%pick an initial radius for alpha shape
handles.sphereSize = 3;

%pick initial stl file type for output
handles.stlWriteMethod = 'binary';

handles.slice = 1;

handles.DICOMPrefix = 'Prefix';

handles.STLColor = [255 0 0];

handles.rotateDegrees = 90;
handles.rotateAxis = 2;

% Initialize translations
% TODO-evaluate if init from view makes sense or is it too slow?
handles.translateUp = str2double(get(handles.editTranslateUp,'String'));
handles.translateDown = str2double(get(handles.editTranslateDown,'String'));
handles.translateLeft = str2double(get(handles.editTranslateLeft,'String'));
handles.translateRight = str2double(get(handles.editTranslateRight,'String'));
% Initialize primitive settings
handles.primitiveHeight = 10;
handles.primitiveWidth = 10;
handles.primitiveRotationAngle = 0;


handles.analysis = 'VolumeRender';

handles.morphologicalOperation = 'Close';
handles.morphologicalImageMask = 'Mask';
handles.morphologicalRadius = 3;
handles.morphological2D3D = '2D';

handles.colormap = 'gray';

%initialize empty slice matrix
%handles.empty = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes contouringGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% NAME-pushbuttonLoadTifStack_Callback
% DESC-Executes on button press, loads an image from a tif stack
function pushbuttonLoadTifStack_Callback(hObject, eventdata, handles)  %#ok<*DEFNU>
    [hObject, eventdata, handles] = LoadTiffStack(hObject,eventdata,handles); %#ok<*ASGLU>
    
function varargout = contouringGUI_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;

% NAME-sliderIMG_Callback  
% DESC-Executes when image slider is used, updates the current slice
% IN-handles.sliderIMG: The value selected/displayed with the slider
% OUT-handles.slice: The number of the current active slice
% handles.editSliceNumber: The slice number selected/displayed with a
% textbox
function sliderIMG_Callback(hObject, eventdata, handles) 
    % Sets the active slice to the value chosen with the slider
    handles.slice = round(get(handles.sliderIMG,'Value'));
    % And sets the slice number to the same value
    set(handles.editSliceNumber,'String',num2str(handles.slice));
    UpdateImage(hObject, eventdata, handles);
    guidata(hObject, handles);

% NAME-sliderIMG_CreateFcn
% DESC-Executes when the image slider is created, sets the backup background color
% to gray
% OUT-hobject.BackgroundColor: the background color of the sider
function sliderIMG_CreateFcn(hObject, eventdata, handles)  %#ok<*INUSD>
    setBackground(hObject, [.9 .9 .9]);
    
% NAME pushbuttonLoadIMG
% DESC-Executes on button press, loads an image from DICOM stack
function pushbuttonLoadIMG_Callback(hObject, eventdata, handles) 
    [hObject, eventdata, handles] = LoadDICOMStack(hObject,eventdata,handles);
    
% NAME-pushbuttonDrawContour_Callback    
% DESC-Executes on button press, allows the user to draw a black and white
% mask
% IN-UI: Freehand 2d image draw by user
% handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function pushbuttonDrawContour_Callback(hObject, eventdata, handles)% %%encapsulated
    [hObject, eventdata, handles] = DrawContour(hObject, eventdata, handles);
    
% NAME-pushbuttonSubtractContour_Callback
% DESC-Executes on button press, allows the user to draw a black and white
% mask to be removed from the current mask
% IN-UI: Freehand 2d image draw by user
% handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function pushbuttonSubtractContour_Callback(hObject, eventdata, handles)
    [hObject, eventdata, handles] = SubtractContour(hObject, eventdata, handles);
    
% NAME-pushbuttonAddContour_Callback
% DESC-Executes on button press, allows the user to draw a black and white
% mask to be added to the current mask
% IN-UI: Freehand 2d image draw by user
% handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function pushbuttonAddContour_Callback(hObject, eventdata, handles)
    [hObject, eventdata, handles] = AddContour(hObject, eventdata, handles);
    
% NAME-pushbuttonMorphRange_Callback
% DESC-Executes on button press, uses mask at start and end of morph range 
% as template to generate mask in the middle
% IN-handles.endMorph: The slice at the top of the area to be generated
% handles.startMorph: The slice at the bottom of the area to be generated
% handles.bwContour: The 3d mask, must have values at startMorph and 
% endMorph slices
% OUT-handles.bwContour: The 3d mask between startMorph and endMorph slices 
function pushbuttonMorphRange_Callback(hObject, eventdata, handles)
    [hObject, eventdata, handles] = MorphRange(hObject, eventdata, handles);
    
% NAME-pushbuttonAdjustCurrentSlice_Callback
% DESC-Executes on button press, adjusts the mask on the current slice to
% match the image
% IN-handles.img: The 3d image to be matched
% handles.bwContour: The 3d mask, should have a value on the current slice
% close to a object in the image
% handles.slice: The number of the current slice to be adjusted
% OUT-Handles.bwCountor: The 3d mask, with the current slice adjusted
function pushbuttonAdjustCurrentSlice_Callback(hObject, eventdata, handles)
    [hObject, eventdata, handles] = AdjustCurrentSlice(hObject, eventdata, handles);
    
% NAME-popupmenuContourMethod_Callback
% DESC-Executes on selection change in popupmenuContourMethod, sets the
% contour method to match the chosen value
% IN-handles.popupmenuContourMethod: The contour method selected in the
% popup menu
% OUT-handles.contourMethod: The contour method used by the active contour
% algorithm when adjusting
function popupmenuContourMethod_Callback(hObject, eventdata, handles)
    str = get(handles.popupmenuContourMethod,'String');
    val = get(handles.popupmenuContourMethod,'Value');
    switch str{val}
        case 'Chan-Vese'
            handles.contourMethod = 'Chan-Vese';
        case 'Edge'
            handles.contourMethod = 'Edge';
    end
    guidata(hObject, handles);
    
% NAME-popupmenuContourMethod_CreateFcn  
% DESC-Executes on object creation, sets the backup background color to white
function popupmenuContourMethod_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');
    
% NAME-editSmoothFactor_Callback   
% DESC-Executes on text entry, sets the smooth factor to match the
% chosen value
% IN-handles.editSmoothFactor: The smooth factor written in the text box
% OUT-handles.smoothFactor: The smooth factor used by the active contour
% algorithm when adjusting
function editSmoothFactor_Callback(hObject, eventdata, handles)
    handles.smoothFactor = str2double(get(handles.editSmoothFactor,'String'));
    guidata(hObject, handles);

% NAME-editSmoothFactor_CreateFcn  
% DESC-Executes on object creation, sets the backup background color to white
function editSmoothFactor_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-editContractionBias_Callback
% DESC-Executes on text entry, sets the contraction bias to match the
% chosen value
% IN-handles.editContractionBias: The contraction bias written in the text box
% OUT-handles.contractionBias: The contraction bias used by the active
% contour algorithm when adjusting
function editContractionBias_Callback(hObject, eventdata, handles)
    handles.contractionBias = str2double(get(handles.editContractionBias,'String'));
    guidata(hObject, handles);

% NAME-editContractionBias_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white
function editContractionBias_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');
    
% NAME-editIterations_Callback
% DESC-Executes on text entry, sets the number of iterations to match the
% chosen value
% IN-handles.editIterations: The number of iterations written in the text box
% OUT-handles.iterations: The number of iterations used by the active 
% contour algorithm when adjusting 
function editIterations_Callback(hObject, eventdata, handles)
    handles.iterations = str2double(get(handles.editIterations,'String'));
    guidata(hObject, handles);

% NAME-editIterations_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white
function editIterations_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-pushbuttonExecuteAnalysis_Callback
% DESC-Executes on button press, performs the chosen analysis
% IN-handles.analysis: The analysis option chosen by dropdown menu
% OUT-Calls the chosen function
function pushbuttonExecuteAnalysis_Callback(hObject, eventdata, handles)
%TODO- test every option.
switch handles.analysis
    case 'Cortical'
        [hObject,eventdata,handles] = CorticalAnalysis(hObject,eventdata,handles);   
    case 'Cancellous'
        [hObject,eventdata,handles] = CancellousAnalysis(hObject,eventdata,handles);    
    case 'FractureCallusVascularity'
        [hObject,eventdata,handles] = FractureCallusVascularity(hObject,eventdata,handles);    
    case 'Arterial'
        [hObject,eventdata,handles] = HruskaAortaMineralization(hObject,eventdata,handles);    
    case 'MarrowFat'
        [hObject,eventdata,handles] = MarrowFat(hObject,eventdata,handles);    
    case 'TangIVDPMA'
        [hObject,eventdata,handles] = TangIVDPMAMorphology(hObject,eventdata,handles);   
    case 'AlignAboutWideAxis'
        [hObject,eventdata,handles] = AlignAboutWideAxis(hObject,eventdata,handles);
    case 'MakeDatasetIsotropic'
        [hObject,eventdata,handles] = MakeDatasetIsotropic(hObject,eventdata,handles);
    case 'GenerateHistogram'
        [hObject,eventdata,handles] = GenerateHistogram(hObject,eventdata,handles);
    case 'SaveCurrentImage'
        [hObject,eventdata,handles] = SaveCurrentImage(hObject,eventdata,handles);
    case 'WriteToTiff'
        [hObject,eventdata,handles] = WriteToTif(hObject,eventdata,handles);
    case 'TendonFootprint'
        [hObject,eventdata,handles] = TendonFootprint(hObject,eventdata,handles);   
    case 'MakeGif'
        [hObject,eventdata,handles] = MakeGif(hObject,eventdata,handles);
    case 'LinearMeasure'
        [hObject,eventdata,handles] = LinearMeasure(hObject,eventdata,handles);    
    case 'ObjectAndVoids'
        [hObject,eventdata,handles] = ObjectAndVoidPlot(hObject,eventdata,handles);    
    case 'VolumeRender'
    %     handles = volumeRender(handles,hObject);
        disp('Volume rendering currently broken by Mathworks')    
    case 'TangIVDPMANotochord'
        [hObject,eventdata,handles] = TangIVDPMANotocordMorphology(hObject,eventdata,handles);    
    case 'NeedlePuncture'
        [hObject,eventdata,handles] = NeedlePunctureImage(hObject,eventdata,handles);    
    case 'MaskVolume'
        [hObject,eventdata,handles] = CalculateMaskVolume(hObject,eventdata,handles);    
    case 'RegisterVolumes'
        RegisterVolumes;    
    case '2D-Analysis'
        [hObject,eventdata,handles] = TwoDAnalysis(hObject,eventdata,handles);    
    case 'FractureCallusFullFracture'
        [hObject,eventdata,handles] = FractureCallus3PtBendBreak(hObject,eventdata,handles);    
    % case 'GuilakKneeSurface'
    %   [hObject,eventdata,handles] = = GuilakKneeSurface(hObject,eventdata,handles);    
    case 'SkeletonizationAnalysis'
        [hObject,eventdata,handles] = SkeletonizationAnalysis(hObject,eventdata,handles);	
    case 'ConvertTo-DistanceMap'
        [hObject,eventdata,handles] = DistanceMap(hObject,eventdata,handles);   
    case 'ConvertTo-Hounsfield'
        [hObject,eventdata,handles] = ConvertToHounsfield(hObject,eventdata,handles);    
    case 'ConvertTo-mgHAperCCM'
        [hObject,eventdata,handles] = ConvertToDensity(hObject,eventdata,handles);	
    case 'WriteToDICOM'
        WriteCurrentImageStackToDICOM(hObject,eventdata,handles);	
    % case 'SaveMasksAsLabelMatrix'
    %    SaveMasksAsLabelMatrix(hObject,eventdata,handles);	
    case 'YMaxForStrain'
        YMaxForStrain(hObject,eventdata,handles);	
    case 'ThicknessVisualization'
        ThicknessVisualization(hObject,eventdata,handles);	
    case 'HumanCoreTrabecularThickness'
        [hObject,eventdata,handles] = HumanCoreTrabecularThickness(hObject,eventdata,handles);	
    case 'StressFractureCallusAnalysis'
        [hObject,eventdata,handles] = ScancoParameterStressFractureCallus(hObject,eventdata,handles);
    case 'CTHistomorphometry'
        [hObject,eventdata,handles] = CTHistomorphometry(hObject,eventdata,handles);   
    otherwise
        disp('pushbuttonExecuteAnalysis_Callback: Invalid option chosen');
end

% NAME-editSigma_Callback
% DESC-Executes on text entry, sets the sigma value to match the
% chosen value
% IN-handles.editSigma: The sigma value written in the text box
% OUT-handles.sigma: The standard deviation used by the gaussian filter,
% higher value = more blur
function editSigma_Callback(hObject, eventdata, handles)
    handles.sigma = str2double(get(handles.editSigma,'String'));
    guidata(hObject, handles);

% NAME-editSigma_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white    
function editSigma_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-editRadius_Callback
% DESC-Executes on text entry, sets the radius to match the
% chosen value
% IN-handles.editRadius: The radius written in the text box
% OUT-handles.radius: The radius used by the program 
function editRadius_Callback(hObject, eventdata, handles)
    handles.radius = str2double(get(handles.editRadius,'String'));
    guidata(hObject, handles);

% NAME-editRadius_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function editRadius_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-sliderThreshold_Callback
% DESC-Executes when threshold slider is used, updates the slider info and
% displays the new threshold
% IN-handles.sliderThreshold: the threshold chosen with the slider
% OUT-handles.threshold: The lower threshold, is used to filter the image
% based on whether the brightness falls between the two thresholds
% handles.editThreshold: the threshold in the text box
% UI: Display the threshold
function sliderThreshold_Callback(hObject, eventdata, handles)
    %Get new threshold from sliders and adjust all values based on it
    handles.threshold = get(handles.sliderThreshold,'Value'); % TODO-round to nearest int
    lowThreshTmp = handles.threshold;
    highThreshTmp = handles.upperThreshold;
    set(handles.text9,'String',num2str(handles.threshold)); % Text next to threshold slider 
    set(handles.editThreshold,'String',num2str(handles.threshold)); % The value in the text box
    % handles.bwContour(:,:,handles.slice) = handles.img(:,:,handles.slice) > handles.lowerThreshold;
    % Create binary image tpm showing everything in current slice between the
    % thresholds as 1 and everything else as 0
    tmp = false(size(handles.img(:,:,handles.slice)));
    tmp(handles.img(:,:,handles.slice) > lowThreshTmp) = 1;
    tmp(handles.img(:,:,handles.slice) > highThreshTmp) = 0;
    % Show a blend of the current slice and the threshold area with axes.
    imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),tmp,'blend','Parent',handles.axesIMG);
    % Display Pixel Information tool
    impixelinfo(handles.axesIMG);
    guidata(hObject, handles);

% NAME-sliderThreshold_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to grey     
function sliderThreshold_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, [.9, .9, .9]);

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
function togglebuttonIterateBackwards_Callback(hObject, eventdata, handles)
    set(handles.togglebuttonIterateForwards,'Value', 0);
    IterateContour(handles, hObject);

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
function togglebuttonIterateForwards_Callback(hObject, eventdata, handles)
    set(handles.togglebuttonIterateBackwards,'Value', 0);
    IterateContour(handles, hObject);

% NAME-pushbuttonClearMaskRange_Callback  
% DESC-remove all masks between the startMorph and endMorph slices 
% IN-handles.startMorph: the number of the slice to start clearing
% handles.endMorph: the number of the slice to stop clearing
% OUT-handles.bwContour: all slices in range set to false
% TODO-limit range to existing mask
function pushbuttonClearMaskRange_Callback(hObject, eventdata, handles)
    startRange=max([handles.startMorph, 1]);
    endRange=min([handles.endMorph, size(handles.bwContour, 3)]);
    handles.bwContour(:,:,startRange:endRange) = false(size(handles.bwContour(:,:,startRange:endRange)));
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);

% NAME-pushbuttonClearAllMasks_Callback
% DESC-executes on button press, removes bwContour field if it exists, deleting all masks
% OUT-handles.bwContour, deletes this field
function pushbuttonClearAllMasks_Callback(hObject, eventdata, handles)
    if isfield(handles,'bwContour') == 1
        handles = rmfield(handles,'bwContour');
    end
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);

% NAME-editStartMorph
% DESC-Executes on text entry, sets the starting slice to match the
% chosen value
% IN-handles.editStartMorph: the starting slice written in the textbox
% OUT-handles.startMorph: the start of the slice range for morphological operations
function editStartMorph_Callback(hObject, eventdata, handles)
    handles.startMorph = str2double(get(handles.editStartMorph,'String'));
    if handles.startMorph < 1
        handles.startMorph = 1;
    elseif handles.startMorph > handles.endMorph
        handles.startMorph = handles.endMorph;
    end
    guidata(hObject, handles);

% NAME-editStartMorph_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white  
function editStartMorph_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-editEndMorph
% DESC-Executes on text entry, sets the stopping slice to match the
% chosen value
% IN-handles.editEndMorph: the stopping slice written in the textbox
% OUT-handles.endMorph: the end of the slice range for morphological operations   
function editEndMorph_Callback(hObject, eventdata, handles)
    handles.endMorph = str2double(get(handles.editEndMorph,'String'));
    if handles.endMorph > handles.abc(3)
        handles.endMorph = handles.abc(3);
    elseif handles.endMorph < handles.startMorph
        handles.endMorph = handles.startMorph;
    end
    guidata(hObject, handles);

% NAME-editEndMorph_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white  
function editEndMorph_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-pushbuttonUpdateEmptyRegions_Callback
% DESC-Executes on button press in pushbuttonUpdateEmptyRegions, identify
% the ranges of all masked slices
% IN-handles.bwContour: the 3d mask
% OUT-handles.maskedRanges: the list of ranges with a mask
function pushbuttonUpdateEmptyRegions_Callback(hObject, eventdata, handles)
    try
        setStatus(hObject, handles, 'Busy');
        %Resets emptyRanges
        %clear handles.empty handles.emptyRanges;
        %handles.emptyRanges = cell(0);
        %guidata(hObject, handles);
    
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
        
        set(handles.text13,'String',el);
        
        handles.maskedRanges = el;
        
        guidata(hObject, handles);
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end

% NAME-editThreshold_Callback
% DESC-Executes on text entry, sets the threshold and the slider to match the
% chosen value
% IN-handles.editThreshold: the threshold entered in the text box
% OUT-handles.threshold: the lower threshold used when filtering images
% handles.sliderThreshold: the position of the threshold slider
function editThreshold_Callback(hObject, eventdata, handles)
    handles.threshold = str2double(get(handles.editThreshold,'String'));
    set(handles.sliderThreshold,'Value',handles.threshold);
    tmp = handles.img(:,:,handles.slice) > handles.threshold;
    imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),tmp,'blend','Parent',handles.axesIMG);
    impixelinfo(handles.axesIMG);
    guidata(hObject, handles);

% NAME-editThreshold_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function editThreshold_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');


% NAME-pushbuttonCreate3DObject_Callback
% DESC-Executes on button press, displays a 3D image of the mask
% IN-handles.bwContour: the black and white mask
% handles.sphereSize: the maximum distance between adjacent points in the
% shape
% OUT-IO: draws a 3D image
function pushbuttonCreate3DObject_Callback(hObject, eventdata, handles)
    setStatus(hObject, handles, 'Busy');
    % Generate 3d shape from masks 
    handles.shp = shpFromBW(handles.bwContour,handles.sphereSize);
    % Create new window and display the shape in it
    figure();
    plot(handles.shp,'FaceColor',handles.STLColor ./ 255,'LineStyle','none');
    camlight();

    guidata(hObject, handles);
    setStatus(hObject, handles, 'Not Busy');

% NAME-pushbuttonWriteSTL_Callback
% DESC-Executes on button press, writes the shape to a stl file
% IN-handles.shp: the shape to be written to the file, contains
% shp.boundaryFacets and shp.points
% handles.imgScale: the scale of the image, to be included in the filename
% handles.stlWriteMethod: the method to be used to write to the file, can
% be ascii or binary(default)
% handles.pathstr: the pathstring of the folder to write to
% handles.DICOMPrefix: the prefix to apply to the filename
% handles.STLColor: the color to use in binary files
% OUT-IO: writes a stl file
function pushbuttonWriteSTL_Callback(hObject, eventdata, handles)
    try
        setStatus(hObject, handles, 'Busy');
        if strcmpi(handles.stlWriteMethod,'ascii') == 1
            % Generate a filename
            fName = ['scaled-' num2str(handles.imgScale) '-' handles.DICOMPrefix '-stl-ascii.stl'];
            % Write shape to an ascii file
            stlwrite(fullfile(handles.pathstr,fName),handles.shp.boundaryFacets,handles.shp.Points,'mode','ascii');
        else 
            % Generate a filename
            fName = ['scaled-' num2str(handles.imgScale) '-' handles.DICOMPrefix '-stl.stl'];
            % Write shape to a binary file
            stlwrite(fullfile(handles.pathstr,fName),handles.shp.boundaryFacets,handles.shp.Points,'FaceColor',handles.STLColor);
        end
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end
    
% NAME-pushbuttonSetMaskThreshold_Callback
% DESC-Executes on button press, sets mask to 1 in all parts of image between
% thresholds and 0 elsewhere
% IN-handles.img: the 3D image
% handles.lowerThreshold, handles.upperThreshold: the lower and upper
% bounds of brightness to examine in the image
% OUT-handles.bwContour: the 3D mask
function pushbuttonSetMaskThreshold_Callback(hObject, eventdata, handles)
    handles.bwContour = handles.img > handles.lowerThreshold;
    handles.bwContour(handles.img > handles.upperThreshold) = 0;
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);

% NAME-pushbuttonRemoveSpeckleNoiseFromMask_Callback
% DESC-Executes on button press, removes small objects from mask
% IN-handles.speckleSize: the maximum size of object to be removed
% OUT-handles.bwContour: the 3D mask
function pushbuttonRemoveSpeckleNoiseFromMask_Callback(hObject, eventdata, handles)
    try
        setStatus(hObject, handles, 'Busy');
        % Remove all areas smaller than speckleSize from BWContour
        handles.bwContour = bwareaopen(handles.bwContour,handles.speckleSize);
        %TODO- I'm not sure this is needed. Check if it does anything
        handles.bwContour(:,:,handles.slice) = handles.bwContour(:,:,handles.slice);
        % Show current slice of img, with contrast adjusted to display values
        % between lOut and hOut, blended with BWContour mask and axes
        imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
        % Display Pixel Information tool
        impixelinfo(handles.axesIMG);

        guidata(hObject, handles);
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end

% NAME-editSpeckleSize_Callback
% DESC-Executes on text entry, sets the speckle size to match the
% chosen value
% IN-handles.editSpeckleSize: the size entered in the text box
% OUT-handles.speckleSize: the maximum size of objects to be removed by
% removeSpeckleNoiseFromMask (by number of pixels)
function editSpeckleSize_Callback(hObject, eventdata, handles)
    handles.speckleSize = str2double(get(handles.editSpeckleSize,'String'));
    guidata(hObject, handles);

% NAME-editSpeckleSize_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white
function editSpeckleSize_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');


function editSliceNumber_Callback(hObject, eventdata, handles)
% NAME-editSLiceNumber_Callback
% DESC-Executes on text entry, sets the slice and slider to match the
% chosen value
% IN-handles.editSliceNumber: the slice number entered in the text box
% OUT-handles.slice: the number of the active slice
% handles.sliderIMG: the position of the image slice slider
handles.slice = str2double(get(handles.editSliceNumber,'String'));
set(handles.sliderIMG,'Value',handles.slice);
guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);

% NAME-editSliceNumber_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function editSliceNumber_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-pushbuttonScaleImageSize_Callback
% DESC-Executes on button press in pushbuttonScaleImageSize, resizes the
% image
% IN-handles.imgScale: the factor to scale the image by
% OUT-handles.img: the image to be rescaled
% handles.bwContour: the mask to also be rescaled
% handles.abc: the height, width, and depth of the image
% handles.sliderIMG: the slider to select the slice
% handles.textVoxelSize: the size of text ovelaid on the image
function pushbuttonScaleImageSize_Callback(hObject, eventdata, handles)
    try
        setStatus(hObject, handles, 'Busy');
        % Resize img in 3 dimensions by imgScale
        handles.img = imresize3(handles.img,handles.imgScale);
        % If bwContour exists, resize it too
        if isfield(handles,'bwContour')
            handles.bwContour = resize3DMatrixBW(handles.bwContour,handles.imgScale);
        end
        % Set abc to new size
        handles.abc = size(handles.img, [1 2 3]);
        % Reset slider to new size
        handles.sliderIMG = resizeSlider(handles.sliderIMG, handles.abc(3));
        %Rescale the text voxels so they still only fill one slice
        set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness / handles.imgScale));
        guidata(hObject, handles);
        UpdateImage(hObject, eventdata, handles);
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end

% NAME-editScaleImageSize_Callback
% DESC-Executes on text entry, sets the image scale to match the
% chosen value
% IN-handles.editScaleImageSize: the size entered in the text box
% OUT-handles.imgScale: the scale factor to use when resizing the image
function editScaleImageSize_Callback(hObject, eventdata, handles)
    handles.imgScale = str2double(get(handles.editScaleImageSize,'String'));
    guidata(hObject, handles);

% NAME-editScaleImageSize_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function editScaleImageSize_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-editSphereSizeForAlphaShape_Callback
% DESC-Executes on text entry, sets the sphere size used by alphaShape to match the
% chosen value
% IN-handles.editSphereSizeForAlphaShape: the size entered in the text box
% OUT-handles.sphereSize: the radius used by the alphaShape algorithm
function editSphereSizeForAlphaShape_Callback(hObject, eventdata, handles)
    handles.sphereSize = str2double(get(handles.editSphereSizeForAlphaShape,'String'));
    guidata(hObject, handles);

% NAME-editSphereSizeForAlphaShape_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function editSphereSizeForAlphaShape_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');


% NAME-popupmenuSTLAsciiBinary_Callback
% DESC-Executes on selection change, sets the stl write format to match the
% chosen value
% IN-handles.popupmenuSTLAsciiBinary: the value selected in the popup menu
% OUT-handles.stlWriteMethod: the format used to write stl files, can be
% ascii or binary
function popupmenuSTLAsciiBinary_Callback(hObject, eventdata, handles)
    str = get(handles.popupmenuSTLAsciiBinary,'String');
    val = get(handles.popupmenuSTLAsciiBinary,'Value');
    switch str{val}
        case 'ascii'
            handles.stlWriteMethod = 'ascii';
        case 'binary'
            handles.stlWriteMethod = 'binary';
    end
    guidata(hObject, handles);

% NAME-popupmemuSTLAsciiBinary_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function popupmenuSTLAsciiBinary_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-pushbuttonIsolateObjectOfInterest_Callback
% DESC-Executes on button press, isolates the region selected by the mask
% IN-handles.bwContour: the 3D mask
% OUT-handles.img: the 3D image
function pushbuttonIsolateObjectOfInterest_Callback(hObject, eventdata, handles)
    % Remove everything not in mask from image
    handles.img(~handles.bwContour) = 0;
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);

% NAME-pushbuttonCropImageToMask_Callback    
% DESC-Executes on button press, crops the image around the box containing
% the mask
% IN-handles.bwContour: the 3D mask
% OUT-handles.img: the 3D image
function pushbuttonCropImageToMask_Callback(hObject, eventdata, handles)

    % Find the range of the box containing the mask
    [x, y, z] = ind2sub(size(handles.bwContour),find(handles.bwContour));
    xMin = min(x);
    xMax = max(x);
    yMin = min(y);
    yMax = max(y);
    zMin = min(z);
    zMax = max(z);


    % Crop out everything outside of that range 
    handles.img = handles.img(xMin:xMax,yMin:yMax,zMin:zMax);
    handles.bwContour = handles.bwContour(xMin:xMax,yMin:yMax,zMin:zMax);

    % Reset slice to 1
    handles.slice = 1;
    % Set abc to new size 
    handles.abc = size(handles.img, [1 2 3]);
    % Reset slider to match new size
    handles.sliderIMG = resizeSlider(handles.sliderIMG, handles.abc(3));

    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);


% NAME-editDICOMPrefix_Callback
% DESC-Executes on text entry, sets the prefix for DICOM files to match the
% chosen value
% IN-handles.editDICOMPrefix: the value entered in the text box
% OUT-handles.DICOMPrefix: the prefix to apply to DICOM files
function editDICOMPrefix_Callback(hObject, eventdata, handles)
    handles.DICOMPrefix = get(handles.editDICOMPrefix,'String');
    guidata(hObject, handles);

% NAME-editDICOMPrefix_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function editDICOMPrefix_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-pushbuttonSetMaskToComponent_Callback
% DESC-Executes on button press, select one mask component and remove all
% others
% IN-handles.maskComponent: the component selected by dropdown menu
% OUT-handles.bwContour-the 3D mask, reduced to one component
% TODO-Add more to ensure this is only called after populating
function pushbuttonSetMaskToComponent_Callback(hObject, eventdata, handles)
    try
        setStatus(hObject, handles, 'Busy');
        if handles.maskComponent == 0
            error('Mask Component not selected');
        end
        % Gets an object from the list of mask components based on the
        % number (Ordered by size descending)
        handles.bwContour = bwIndex(handles.bwContour, handles.maskComponent);
        guidata(hObject, handles);
        UpdateImage(hObject, eventdata, handles);
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end

% NAME-togglebuttonInvertImage_Callback  
% DESC-Inverts the image, replacing light with dark and vice versa
% IN-handles.info.BitDepth: The number of bits in one pixel of
% the image(0=black, (2^BitDepth)-1=white)
% OUT-handles.img: the image with black and white reversed
function togglebuttonInvertImage_Callback(hObject, eventdata, handles)
    handles.img = (2^handles.info.BitDepth)-1 - handles.img;

    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);

% NAME-popupmenuSTLColor_Callback
% DESC-Executes on selection change, sets the STL color to match the
% selected option
% IN-handles.popupmenuSTLColor-the color chosen in the popup memu
% OUT-handle.STLColor-the color used in STL files, in rgb format
function popupmenuSTLColor_Callback(hObject, eventdata, handles)
    str = get(handles.popupmenuSTLColor,'String');
    val = get(handles.popupmenuSTLColor,'Value');
    switch(str{val})
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

% NAME-popupmenuSTLColor_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function popupmenuSTLColor_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-textPercentLoaded_CreateFcn    
% DESC-Executes on object creation, nothing is needed
function textPercentLoaded_CreateFcn(hObject, eventdata, handles)

% NAME-pushbuttonRotateImage_Callback
% DESC-Executes on button press, rotates the image and mask a selected 
% number of degrees
% IN-handles.rotateDegrees: the number of degrees to rotate
% OUT-handles.img: the rotated image
% handles.bwContour: the rotated mask
function pushbuttonRotateImage_Callback(hObject, eventdata, handles)
    try
        setStatus(hObject, handles, 'Busy');

        %Create temp storage with the same depth as the image
        tmp = cell([1, handles.abc(3)]);
        tmp2 = cell([1, handles.abc(3)]);
        % For each slice, rotate the image and mask and store the new
        % image/mask slice in tmp and tmp2
        for i = 1:handles.abc(3)
            tmp{i} = imrotate(handles.img(:,:,i),handles.rotateDegrees,'crop');
            if isfield(handles,'bwContour') == 1
                tmp2{i} = imrotate(handles.bwContour(:,:,i),handles.rotateDegrees,'crop');
            end
        end
        clear handles.img;
        % Replace the image with the rotated version
        for i = 1:handles.abc(3)
            handles.img(:,:,i) = tmp{i};
        end
        % Replace the mask with the rotated version
        if isfield(handles,'bwContour') == 1
            clear handles.bwContour;
            for i = 1:handles.abc(3)
                handles.bwContour(:,:,i) = tmp2{i};
            end
        end
        %set to update graphics stuff
        handles.abc = size(handles.img, [1 2 3]);

        guidata(hObject, handles);
        UpdateImage(hObject, eventdata, handles);
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end

% NAME-editRotationDegrees_Callback
% DESC-Executes on text entry, sets the rotation degrees to match the
% chosen value
% IN-handles.editRotationDegrees: the value entered in the text box
% OUT-handles.rotateDegrees: the number of degrees to rotate
function editRotationDegrees_Callback(hObject, eventdata, handles)
    handles.rotateDegrees = str2double(get(handles.editRotationDegrees,'String'));
    guidata(hObject, handles);

% NAME-editRotationDegrees_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function editRotationDegrees_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-pushbuttonFlipImage_Callback
% DESC-Executes on button press, flips the image along the chosen axis
% IN-handles.rotateAxis: the axis to flip along
% OUT-handles.img: the flipped image
% handles.bwContour: the flipped mask
function pushbuttonFlipImage_Callback(hObject, eventdata, handles)

    % Flip the image and mask around the axis
    handles.img = flip(handles.img,handles.rotateAxis);
    if isfield(handles,'bwContour') == 1
        handles.bwContour = flip(handles.bwContour,handles.rotateAxis);
    end

    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);

% NAME-popupmenuRotationAxis_Callback
% DESC-Executes on selection change, sets the rotation and flip axis based 
% on the selection
% IN-handles.popupmenuRotationAxis: the axis (xyz) selected in the popup menu
% OUT-handles.rotateAxis: the matrix dimension coresponding to the axis
function popupmenuRotationAxis_Callback(hObject, eventdata, handles)
    str = get(handles.popupmenuRotationAxis,'String');
    val = get(handles.popupmenuRotationAxis,'Value');
    switch str{val}
        case 'X'
            handles.rotateAxis = 2;
        case 'Y'
            handles.rotateAxis = 1;
        case 'Z'
            handles.rotateAxis = 3;
    end
    guidata(hObject, handles);

% NAME-popupmenuRotationAxis_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function popupmenuRotationAxis_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-popupmenuMaskComponents_Callback
% DESC-Executes on selection change,
function popupmenuMaskComponents_Callback(hObject, eventdata, handles)
    str = get(handles.popupmenuMaskComponents,'String');
    val = get(handles.popupmenuMaskComponents,'Value');
    num=str2double(str{val});
    % Ensure selection is a number, default to 0;
    if isnan(num) 
        handles.maskComponent = 0;
    else
        handles.maskComponent = num;
    end
    guidata(hObject, handles);
   


% NAME-popupmenuMaskComponents_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function popupmenuMaskComponents_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-pushbuttonPopulateMaskComponents_Callback    
% DESC-Executes on button press, identifies all components of the mask and
% fills the dropdown menu
% IN-handles.bwContour: the 3D mask
% OUT-handles.cc: all the components of the mask
% handles.popupMaskComponents: the list of components in the popup menu
function pushbuttonPopulateMaskComponents_Callback(hObject, eventdata, handles)
    try
        setStatus(hObject, handles, 'Busy');
        %Identifies all connected components of mask
        handles.cc = bwconncomp(handles.bwContour);
        %Create a list of all components in string format
        connCompInd=compose('%u', 1:length(handles.cc.PixelIdxList));
        set(handles.popupmenuMaskComponents, 'Value', 1); % Set the default component to the largest, ensures the value is in range
        set(handles.popupmenuMaskComponents, 'String',connCompInd); % Sets the list of components
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end

% NAME-pushbuttonSetMaskByClicking    
% DESC-Executes on button press, allows user to select which mask
% components to keep by clicking on them
% IN-IO: opens a getpts tool to let the user click on the mask
% handles.axesIMG: the axis for the image, used as a reference for point
% selection
% OUT-handles.bwContour: the selected components of the mask
function pushbuttonSetMaskByClicking_Callback(hObject, eventdata, handles)
    try
        setStatus(hObject, handles, 'Busy');
        % Interactive point selection
        % TODO-matlab recomends drawpoint
        [x, y] = getpts(handles.axesIMG);
        z(1:length(x), 1) = handles.slice;
        pt = round([y, x, z]);% points to use to select mask component
        % Labels connected components of mask
        cc = bwlabeln(handles.bwContour);
        handles.bwContour=zeros(size(handles.bwContour));
        % Get the label at each point, and add all points with that label
        % to mask
        for i = 1:length(pt(:,1))
            label=cc(pt(i,1), pt(i,2), pt(i,3));
            if label ~= 0
                handles.bwContour(cc==label)=1;
            end
        end

        UpdateImage(hObject,eventdata,handles);
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end


% NAME-pushbuttonMorphAll_Callback
% DESC-Executes on button press, extrapolates a shape for the mask
% TODO-explicit handling when mask is empty
function pushbuttonMorphAll_Callback(hObject, eventdata, handles)
    try
        setStatus(hObject, handles, 'Busy');
        clear handles.maskedRanges;
        guidata(hObject, handles);

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

        if empties(handles.abc(3)) ~= 1
            stops = [stops, handles.abc(3)];
        end

        % Identify the range of each mask section
        ranges = zeros(length(starts), 2);
        for i = 1:length(starts)
            ranges(i,:) = [starts(i), stops(i)];
        end

        % Identify the start and stop of each unmasked section
        % TODO-better handling when there is no gap 
        for i = 1:length(ranges)-1
            start = ranges(i,2);
            stop = ranges(i+1,1);
            % Attempts to fill gaps by extrapolating from starting and
            % stopping slice of mask
            bwTemp = interp_shape(handles.bwContour(:,:,start),handles.bwContour(:,:,stop),abs(start-stop + 1));
            bwTemp = flip(bwTemp,3);
            handles.bwContour(:,:,start+1:stop-1) = bwTemp;
        end

        guidata(hObject, handles);
        UpdateImage(hObject, eventdata, handles);
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end

% NAME-pushbuttonCreatePrimitive_Callback
% DESC-Executes on button press, creates a rectangle or oval shaped mask
% IN-handles.primitive: the shape to draw, options are Oval and Rectangle
% handles
function pushbuttonCreatePrimitive_Callback(hObject, eventdata, handles)
    str = get(handles.popupmenuPrimitive,'String');
    val = get(handles.popupmenuPrimitive,'Value');
    switch str{val}
        case 'Oval'
            theta = handles.primitiveRotationAngle;
            % Horizontal and vertical axes
            a=handles.primitiveWidth;
            b=handles.primitiveHeight;
            % Ellipse centre coordinates
            xc=handles.primitiveCenter(1); 
            yc=handles.primitiveCenter(2);
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
            % Clear the mask for current slice
            if isfield(handles,'bwContour') == 0
                handles.bwContour = false(size(handles.img));
                tmp = false(size(handles.bwContour(:,:,handles.slice)));
            else
                tmp = false(size(handles.bwContour(:,:,handles.slice)));
            end
            % For each point (xq,yq), if it is inside the ellipse, add it to tmp
        
            for i = 1:length(xq)
                if ((xq(i)-xc)*cos(theta)-(yq(i)-yc)*sin(theta)).^2/a^2 + ((xq(i)-xc)*sin(theta)+(yq(i)-yc)*cos(theta)).^2/b^2 <= 1
                %if (xq(i)-xc).^2/a^2 + (yq(i)-yc).^2/b^2 <= 1
                    tmp(round(yq(i)),round(xq(i))) = 1;
                end
            end
            % Redraw mask for current slice using tmp
            handles.bwContour(:,:,handles.slice) = tmp;

            guidata(hObject, handles);
        case 'Rectangle'
            %     handles.primitiveCenter = [round(handles.abc(1)/2),round(handles.abc(2)/2)];
            % Clear any existing mask
            if isfield(handles,'bwContour') == 0
                handles.bwContour = false(size(handles.img));
            end
            handles.abc = size(handles.img, [1 2 3]);
            % Retain all plots on current axis
            hold on;
            % TODO-Find DrawRectangle and inpoly source
            % TODO-This might need rework to be less dependant on those functions,
            % could reuse ellipse code
            [P,R] = DrawRectangle([handles.primitiveCenter(1),handles.primitiveCenter(2),...
                handles.primitiveWidth,handles.primitiveHeight,str2double(get(handles.editRotatePrimitive,'String'))]);
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

            %     [P,R] = DrawRectangle([handles.primitiveCenter(1),handles.primitiveCenter(2),...
            %         handles.primitiveWidth,handles.primitiveHeight,0]);
            % Identify all points inside the rectangle
            [in] = inpoly([xq',yq'],[P(6:10)',P(1:5)']);
            % Reorient the rectangle
            tmp = reshape(in,[handles.abc(2) handles.abc(1)]);
            tmp = imrotate(tmp,90);
            tmp = flipud(tmp);
            %     in(on) = 1;
            %     tmp = false(size(handles.bwContour(:,:,handles.slice)));
            %     tmp(in) = 1;
            %     tmp = imrotate(tmp,rad2deg(str2double(get(handles.editRotatePrimitive,'String'))),'crop');
            % Set mask to rectangle
            handles.bwContour(:,:,handles.slice) = tmp;
            %     handles.bwContour(:,:,handles.slice) = imclose(handles.bwContour(:,:,handles.slice),true(9,9));

            hold off;

            guidata(hObject, handles);
    end

    % Reset text center to new mask center
    [row, col] = find(handles.bwContour(:,:,handles.slice));
    cent = [round(mean(row)) round(mean(col))];
    set(handles.textCenterLocation,'String',[num2str(cent(1)) ' ' num2str(cent(2))]);

    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);

% NAME-popupmenuPrimitive_Callback   
% DESC-Executes on selection change, does nothing
function popupmenuPrimitive_Callback(hObject, eventdata, handles)

% NAME-popupMenuPrimitive_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function popupmenuPrimitive_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-editPrimitiveHeight_Callback
% DESC-Executes on text entry, sets the primitive shape height to match the
% chosen value
% IN-handles.editPrimitiveHeight: the height entered in the text box
% OUT-handles.primitiveHeight: the height used when creating primitive shapes
function editPrimitiveHeight_Callback(hObject, eventdata, handles)
    handles.primitiveHeight = str2double(get(handles.editPrimitiveHeight,'String'));
    guidata(hObject, handles);

% NAME-editPrimitiveHeight_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function editPrimitiveHeight_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-editPrimitiveWidth_Callback
% DESC-Executes on text entry, sets the primitive width to match the
% chosen value
% IN-handles.editPrimitiveWidth: the width entered in the text box
% OUT-handles.primitiveWidth: the width used when creating primitive shapes
function editPrimitiveWidth_Callback(hObject, eventdata, handles)
    handles.primitiveWidth = str2double(get(handles.editPrimitiveWidth,'String'));
    guidata(hObject, handles);

% NAME-editPrimitiveWidth_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function editPrimitiveWidth_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-editRotatePrimitive_Callback
% DESC-Executes on text entry, sets the primitive angle to match the
% chosen value
% IN-handles.editRotatePrimitive: the angle entered in the text box
% OUT-handles.primitiveRotationAngle: the angle used when creating
% primitive shapes
% TODO-this may be better as degrees instead of radians
function editRotatePrimitive_Callback(hObject, eventdata, handles)
    handles.primitiveRotationAngle = str2double(get(handles.editRotatePrimitive,'String'));
    guidata(hObject, handles);

% NAME-editRotatePrimitive_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function editRotatePrimitive_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-editTranslateUp_Callback
% DESC-Executes on text entry, sets the translation value to match the
% chosen value
% IN-handles.editTranslateUp: the value entered in the text box
% OUT-handles.translateUp: the distance moved when translating up
function editTranslateUp_Callback(hObject, eventdata, handles)
    handles.translateUp = str2double(get(handles.editTranslateUp,'String'));
    guidata(hObject, handles);  

% NAME-editTranslateUp_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function editTranslateUp_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white')

% NAME-editTranslateDown_Callback
% DESC-Executes on text entry, sets the translation value to match the
% chosen value
% IN-handles.editTranslateDown: the value entered in the text box
% OUT-handles.translateDown: the distance moved when translating down
function editTranslateDown_Callback(hObject, eventdata, handles)
    handles.translateDown = str2double(get(handles.editTranslateDown,'String'));
    guidata(hObject, handles); 

% NAME-editTranslateDown_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function editTranslateDown_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-editTranslateLeft_Callback
% DESC-Executes on text entry, sets the translation value to match the
% chosen value
% IN-handles.editTranslateLeft: the value entered in the text box
% OUT-handles.translateLeft: the distance moved when translating left  
function editTranslateLeft_Callback(hObject, eventdata, handles)
    handles.translateLeft = str2double(get(handles.editTranslateLeft,'String'));
    guidata(hObject, handles); 
    
% NAME-editTranslateLeft_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white   
function editTranslateLeft_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');


% NAME-editTranslateRight_Callback
% DESC-Executes on text entry, sets the translation value to match the
% chosen value
% IN-handles.editTranslateRight: the value entered in the text box
% OUT-handles.translateRight: the distance moved when translating right
function editTranslateRight_Callback(hObject, eventdata, handles)
    handles.translateRight = str2double(get(handles.editTranslateRight,'String'));
    guidata(hObject, handles); 


% NAME-editTranslateRight_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white  
function editTranslateRight_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-pushbuttonTranslateUp
% DESC-Executes on button press, shifts the mask in the desired direction
% IN-handles.translateDown: the distance to travel if translating down
% OUT-handles.bwContour: the mask to be translated% --- Executes on button press in pushbuttonTranslateUp.
function pushbuttonTranslateUp_Callback(hObject, eventdata, handles)
    Translate(hObject, eventdata, handles, 'Up');

% NAME-pushbuttonTranslateDown    
% DESC-Executes on button press, shifts the mask in the desired direction
% IN-handles.translateDown: the distance to travel if translating down
% OUT-handles.bwContour: the mask to be translated
function pushbuttonTranslateDown_Callback(hObject, eventdata, handles)
    Translate(hObject, eventdata, handles, 'Down');

% NAME-pushbuttonTranslateLeft
% DESC-Executes on button press, shifts the mask in the desired direction
% IN-handles.translateDown: the distance to travel if translating down
% OUT-handles.bwContour: the mask to be translated
function pushbuttonTranslateLeft_Callback(hObject, eventdata, handles)
    Translate(hObject, eventdata, handles, 'Left');

% NAME-pushbuttonTranslateRight    
% DESC-Executes on button press, shifts the mask in the desired direction
% IN-handles.translateDown: the distance to travel if translating down
% OUT-handles.bwContour: the mask to be translated
function pushbuttonTranslateRight_Callback(hObject, eventdata, handles)
    Translate(hObject, eventdata, handles, 'Right');

% NAME-axesIMG_CreateFcn
% DESC-Executes during object creation, nothing is needed
function axesIMG_CreateFcn(hObject, eventdata, handles)

% NAME-pushbuttonZoomtoRegion_Callback
% DESC-Executes on button press, crops the image
function pushbuttonZoomtoRegion_Callback(hObject, eventdata, handles)
    try
        setStatus(hObject, handles, 'Busy');
        % Create an image with the correct intesity and colormap
        im = imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[]);
        colormap(handles.axesIMG,handles.colormap);
        % Open interactive cropping tool and select a rectangle from the
        % created image
        [~,rect] = imcrop(im);

        % Crop the image and mask to the selected rectangle 
        handles.img = handles.img(round(rect(2)):round(rect(2))+round(rect(4))-1,round(rect(1)):round(rect(1))+round(rect(3))-1,:);
        if isfield(handles,'bwContour')
            handles.bwContour = handles.bwContour(round(rect(2)):round(rect(2))+round(rect(4))-1,round(rect(1)):round(rect(1))+round(rect(3))-1,:);
        end
        %update info as well
        handles.abc = size(handles.img, [1 2 3]);

        handles.info.Height = handles.abc(1);
        handles.info.Width = handles.abc(2);
        handles.info.Rows = handles.abc(1);
        handles.info.Columns = handles.abc(2);

        handles.slice = 1;
        handles.abc = size(handles.img, [1 2 3]);
        handles.sliderIMG = resizeSlider(handles.slider.IMG, handles.abc(3));

        hold off;

        guidata(hObject, handles);
        UpdateImage(hObject, eventdata, handles);
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end
    
% NAME-pushbuttonDiskMorphological_Callback 
% DESC-Executes on button press, performs a dilation or erosion operation
% on the image
% IN-handles.morphological: the chosen morphological operation, options are
% Erode and Dilate
% handles.editDiskSize: the size of the dilation or erosion
% OUT-handles.img: the altered image
function pushbuttonDiskMorphological_Callback(hObject, eventdata, handles)
    switch handles.morphological
        case 'Erode'
            handles.img = imerode(handles.img,strel('disk',str2double(get(handles.editDiskSize,'String')),0));
        case 'Dilate'
            handles.img = imdilate(handles.img,strel('disk',str2double(get(handles.editDiskSize,'String')),0));
    end

    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);

% NAME-editDiskSize_Callback
% DESC-Executes on button press, does nothing
% TODO-add backing value and initialization
function editDiskSize_Callback(hObject, eventdata, handles)

% NAME-editDiskSize_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white 
function editDiskSize_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-popupmenuAnalysis_Callback
% DESC-Executes on selection change, selects the analysis to perform with
% the Execute Analysis button
% IN-handles.popupmenuAnalysis: the option seleted in the menu
% OUT-handles.analysis: the analysis to perform
function popupmenuAnalysis_Callback(hObject, eventdata, handles)
    str = get(handles.popupmenuAnalysis,'String');
    val = get(handles.popupmenuAnalysis,'Value');
    % Set handles.analysis based on option from popup menu.
    % TODO-change UI versions to more human friendly text or get rid of
    % switch case
    switch str{val}
        case 'Cortical'
            handles.analysis = 'Cortical';
        case 'Cancellous'
            handles.analysis = 'Cancellous';
        case 'FractureCallusVascularity'
            handles.analysis = 'FractureCallusVascularity';
        case 'Arterial'
            handles.analysis = 'Arterial';
        case 'MarrowFat'
            handles.analysis = 'MarrowFat';
        case 'TangIVDPMA'
            handles.analysis = 'TangIVDPMA';
        case 'AlignAboutWideAxis'
            handles.analysis = 'AlignAboutWideAxis';
        case 'TendonFootprint'
            handles.analysis = 'TendonFootprint';
        case 'MakeGif'
            handles.analysis = 'MakeGif';
        case 'ObjectAndVoids'
            handles.analysis = 'ObjectAndVoids';
        case 'VolumeRender'
            handles.analysis = 'VolumeRender';
        case 'TangIVDPMANotochord'
            handles.analysis = 'TangIVDPMANotochord';
        case 'NeedlePuncture'
            handles.analysis = 'NeedlePuncture';
        case 'DisplacementMap'
            handles.analysis = 'DisplacementMap';
        case 'ShapeAnaylsis'
            handles.analysis = 'ShapeAnalysis';
        case 'NonLocalMeansFilter'
            handles.analysis = 'NonLocalMeansFilter';
        case 'MaskVolume'
            handles.analysis = 'MaskVolume';
        case 'LinearMeasure'
            handles.analysis = 'LinearMeasure';
        case 'RegisterVolumes'
            handles.analysis = 'RegisterVolumes';
        case '2D-Analysis'
            handles.analysis = '2D-Analysis';
        case 'FractureCallusFullFracture'
            handles.analysis = 'FractureCallusFullFracture';
        %case 'GuilakKneeSurface'
       %     handles.analysis = 'GuilakKneeSurface';
        case 'SkeletonizationAnalysis'
            handles.analysis = 'SkeletonizationAnalysis';
        case 'ConvertTo-DistanceMap'
            handles.analysis = 'ConvertTo-DistanceMap';
        case 'ConvertTo-Hounsfield'
            handles.analysis = 'ConvertTo-Hounsfield';
        case 'ConvertTo-mgHAperCCM'
            handles.analysis = 'ConvertTo-mgHAperCCM';
        case 'WriteToTiff'
            handles.analysis = 'WriteToTiff';
        case 'WriteToDICOM'
            handles.analysis = 'WriteToDICOM';
        case 'SaveCurrentImage'
            handles.analysis = 'SaveCurrentImage';
        case 'GenerateHistogram'
            handles.analysis = 'GenerateHistogram';
        case 'MakeDatasetIsotropic'
            handles.analysis = 'MakeDatasetIsotropic';
        case 'SaveMasksAsLabelMatrix'
            handles.analysis = 'SaveMasksAsLabelMatrix';
        case 'YMaxForStrain'
            handles.analysis = 'YMaxForStrain';
        case 'ThicknessVisualization'
            handles.analysis = 'ThicknessVisualization';
        case 'HumanCoreTrabecularThickness'
            handles.analysis = 'HumanCoreTrabecularThickness';
        case 'StressFractureCallusAnalysis'
            handles.analysis = 'StressFractureCallusAnalysis';
        case 'CTHistomorphometry'
            handles.analysis = 'CTHistomorphometry';
    end
    guidata(hObject, handles);

% NAME-popupmenuAnalysis_CreateFcn  
% DESC-Executes on object creation, sets the backup background color to white 
function popupmenuAnalysis_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-pushbuttonRotate90_Callback
% DESC-Executes on button press, rotates the image and mask 90 degrees
% IN-handles.rotateAxis:the axis to rotate around
% OUT-handles.img: the rotated image
% handles.bwContour: the rotated mask
function pushbuttonRotate90_Callback(hObject, eventdata, handles)
    try
        setStatus(hObject, handles, 'Busy');
        % Rotate image and mask by selected angle
        handles.img = rot90_3D(handles.img, handles.rotateAxis, 1);
        if isfield(handles,'bwContour') == 1
            handles.bwContour = rot90_3D(handles.bwContour, handles.rotateAxis, 1);
        end
        abcResize(handles, hObject);

        % TODO- check if sliderThreshold and theMax are used elsewhere
        
        handles.theMax = double(max(max(max(handles.img))));
        handles.SliderThreshold = resizeSlider(handles.sliderThreshold, 1, handles.theMax, 1, round(handles.theMax/1000));

        guidata(hObject, handles);
        UpdateImage(hObject, eventdata, handles);
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end

% NAME-pushbuttonSetLowerThreshold_Callback
% DESC-Executes on button press, sets the lower threshold to the value
% chosen
% IN-handles.threshold: the value set with the slider or textbox
% OUT-handles.lowerThreshold: the value used for the lower threshold
% textLowerThreshold: the displayed lower threshold value
% TODO-inconsistant behavior when setting after using slider, concurency lag
function pushbuttonSetLowerThreshold_Callback(hObject, eventdata, handles)
    handles.lowerThreshold = handles.threshold;
    set(handles.textLowerThreshold,'String',num2str(handles.lowerThreshold));
    guidata(hObject, handles);

% NAME-pushbuttonSetUpperThreshold_Callback    
% DESC-Executes on button press, sets the upper threshold to the value
% chosen
% IN-handles.threshold: the value set with the slider or textbox
% OUT-handles.upperThreshold: the value used for the upper threshold
% textUpperThreshold: the displayed upper threshold value
function pushbuttonSetUpperThreshold_Callback(hObject, eventdata, handles)
    handles.upperThreshold = handles.threshold;
    set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
    guidata(hObject, handles);

% NAME-togglebuttonToggleMask_Callback
% DESC-Executes on button press, toggles whether or not to show the mask
% and image together
% IN-handles.togglebuttonMask: the button to toggle the mask
% OUT-IO: displays the image and mask together
% TODO-make it so that any fuction that shows the mask also toggles this
function togglebuttonToggleMask_Callback(hObject, eventdata, handles)
    if get(handles.togglebuttonToggleMask,'Value') == 1
        % Show the mask and image blended together
        imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
        impixelinfo(handles.axesIMG);
    else
        % Or show just the image
        imshow(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),'Parent',handles.axesIMG);
        impixelinfo(handles.axesIMG);
    end

    guidata(hObject, handles);

% NAME-editPrimitiveVertical_Callback
% DESC-Executes on text change, sets the vertical center for primitives
% IN-handles.editPrimitiveVertical: the vertical position listed in the
% text box
% OUT-handles.primitiveCenter: the center for new primitive shapes
% TODO-would making the center relative to the image center be more
% convinient?
function editPrimitiveVertical_Callback(hObject, eventdata, handles)
    handles.primitiveCenter(2) = str2double(cell2mat(get(handles.editPrimitiveVertical,'String')));
    guidata(hObject, handles);

% NAME-editPrimitiveVertical_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white 
function editPrimitiveVertical_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-editPrimitiveHorizontal_Callback
% DESC-Executes on text change, sets the horizontal center for primitives
% IN-handles.editPrimitiveHorizontal: the horizontal position listed in the
% text box
% OUT-handles.primitiveCenter: the center for new primitive shapes
function editPrimitiveHorizontal_Callback(hObject, eventdata, handles)
    handles.primitiveCenter(1) = str2double(cell2mat(get(handles.editPrimitiveHorizontal,'String')));
    guidata(hObject, handles);

% NAME-editPrimitiveHorizontal_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white 
function editPrimitiveHorizontal_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-pushbuttonLoadTXMFile_Callback
% DESC-Executes on button press in pushbuttonLoadTXMFile.
function pushbuttonLoadTXMFile_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = LoadTXM(hObject,eventdata,handles);

% NAME-pushbuttonExecuteMorphologicalOperation_Callback
% DESC-Executes on button press in pushbuttonExecuteMorphologicalOperation.
function pushbuttonExecuteMorphologicalOperation_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = ExecuteMorphologicalOperation(hObject,eventdata,handles);

% NAME-popupmenuImageMask_Callback   
% DESC-Executes on selection change, determines whether to perform
% morphological operations on image or mask
% IN-handles.popupmenuImageMask: the value chosen from the menu
% OUT-handles.morphologicalImageMask: the object to perorm operations on,
% options are Image and Mask
function popupmenuImageMask_Callback(hObject, eventdata, handles)
    str = get(handles.popupmenuImageMask,'String');
    val = get(handles.popupmenuImageMask,'Value');
    handles.morphologicalImageMask = str{val};
    % TODO-trying to make this more simple/consistant, check if this breaks anything
    %handles.morphologicalImageMask = cellstr(get(handles.popupmenuImageMask,'String'));
    %handles.morphologicalImageMask = handles.morphologicalImageMask{get(handles.popupmenuImageMask,'Value')};
    guidata(hObject, handles);

% NAME-popupmenuImageMask_CreateFcn    
% DESC-Executes on object creation, sets the backup background color to white .
function popupmenuImageMask_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-popupmenuMorphologicalOperation_Callback
% DESC-Executes on selection change, determines which operation to perform
% IN-handles.popupmenuMorphologicalOperation: the operation chosen from the menu
% OUT-handles.morphologicalOperation: the operation to perform, options are
% Open, Close, Erode, Dilate, Fill
function popupmenuMorphologicalOperation_Callback(hObject, eventdata, handles)
    str = get(handles.popupmenuMorphologicalOperation,'String');
    val = get(handles.popupmenuMorphologicalOperation,'Value');
    handles.morphologicalOperation = str{val};
    %handles.morphologicalOperation = cellstr(get(handles.popupmenuMorphologicalOperation,'String'));
    %handles.morphologicalOperation = handles.morphologicalOperation{get(handles.popupmenuMorphologicalOperation,'Value')};
    guidata(hObject, handles);

% NAME-popupmenuMorphologicalOperation_CreateFcn  
% DESC-Executes on object creation, sets the backup background color to white 
function popupmenuMorphologicalOperation_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-popupmenu2D3D_Callback
% DESC-Executes on selection change, determines whether to perform
% morphological operation in 2D or 3D
% IN-handles.popupmenu2D3D: the option chosen in the menu
% OUT-handles.morphological2D3D: the option used when performing operation,
% choices are 2D and 3D
function popupmenu2D3D_Callback(hObject, eventdata, handles)
    str = get(handles.popupmenu2D3D,'String');
    val = get(handles.popupmenu2D3D,'Value');
    handles.morphological2D3D = str{val};
    %handles.morphological2D3D = cellstr(get(handles.popupmenu2D3D,'String'));
    %handles.morphological2D3D = handles.morphological2D3D{get(handles.popupmenu2D3D,'Value')};
    guidata(hObject, handles);

% NAME-popupmenu2D3D_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white 
function popupmenu2D3D_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-editMorpholgicalRadius_Callback
% DESC-Executes on text change, sets the radius for morphological operations to the chosen value
% IN-handles.editMorpholgicalRadius, the value chosen in the text box
% OUT-handles.morphologicalRadius: the radius used by morphological
% operations
function editMorpholgicalRadius_Callback(hObject, eventdata, handles)
    handles.morphologicalRadius = str2double(get(handles.editMorpholgicalRadius,'String'));
    guidata(hObject, handles);

% NAME-editMorpholgicalRadius_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white 
function editMorpholgicalRadius_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-sliderWindowWidth_Callback
% DESC-Executes on slider movement, sets the range of the brightness window
% IN-handles.sliderWindowWidth: the window width slider
% OUT-handles.editWindowWidth: the window width textbox
% handles.windowWidth: the range of brightness values to show
function sliderWindowWidth_Callback(hObject, eventdata, handles)
    set(handles.editWindowWidth,'String',num2str(get(handles.sliderWindowWidth,'Value')))
    handles.windowWidth = get(handles.sliderWindowWidth,'Value');
    guidata(hObject, handles);
    updateWindow(hObject, eventdata, handles);

% NAME-sliderWindowWidth_CreateFcn
% DESC-Executes on object creation, sets the backup background color to dark grey
function sliderWindowWidth_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, [.9, .9, .9]);

% NAME-sliderWindowLocation_Callback
% DESC-Executes on slider movement, sets the center of the brightness window
% IN-handles.sliderWindowLocation: the window location slider
% OUT-handles.editWindowLocation: the window location textbox
% handles.windowLocation: the center value for the brightness window
function sliderWindowLocation_Callback(hObject, eventdata, handles)
    set(handles.editWindowLocation,'String',num2str(get(handles.sliderWindowLocation,'Value')));
    handles.windowLocation = get(handles.sliderWindowLocation,'Value');
    updateWindow(hObject, eventdata, handles);

% NAME-sliderWindowLocation_CreateFcn
% DESC-Executes on object creation, sets the backup background color to dark grey 
function sliderWindowLocation_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, [.9, .9, .9]);

% NAME-editWindowWidth_Callback
% DESC-Executes on text entry, sets the range of the brightness window
% IN-handles.editWindowWidth: the window width slider
% OUT-handles.sliderWindowWidth: the window width textbox
% handles.windowWidth: the range of brightness values to show
function editWindowWidth_Callback(hObject, eventdata, handles)
    set(handles.sliderWindowWidth,'Value',str2double(get(handles.editWindowWidth,'String')))
    handles.windowWidth = str2double(get(handles.editWindowWidth,'String'));
    updateWindow(hObject, eventdata, handles);

% NAME-editWindowWidth_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white 
function editWindowWidth_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');


% NAME-editWindowLocation_Callback
% DESC-Executes on text entry, sets the center of the brightness window
% IN-handles.editWindowLocation: the window location textbox
% OUT-handles.sliderWindowLocation: the window location slider
% handles.windowLocation: the center value for the brightness window
% TODO-limit size to slider range
function editWindowLocation_Callback(hObject, eventdata, handles)
    set(handles.sliderWindowLocation,'Value',str2double(get(handles.editWindowLocation,'String')))
    handles.windowLocation = str2double(get(handles.editWindowLocation,'String'));
    updateWindow(hObject, eventdata, handles);

% NAME-editWindowLocation_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white 
function editWindowLocation_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-pushbuttonSetOriginalImage_Callback
% DESC-Executes on button press, saves the current image as the original
function pushbuttonSetOriginalImage_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = SetOriginalImage(hObject,eventdata,handles);

% NAME-pushbuttonRevertImage_Callback
% DESC-Executes on button press, reloads the saved image
function pushbuttonRevertImage_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = RevertImage(hObject,eventdata,handles);

% NAME-pushbuttonSetFirstSlice_Callback
% DESC-Executes on button press, crops all slices before the current slice
% IN-handles.slice: the slice to become the new first slice
% OUT-handles.img: the cropped image
% handles.bwCountour: the cropped mask
function pushbuttonSetFirstSlice_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = SetFirstSlice(hObject,eventdata,handles);

% NAME-pushbuttonSetLastSlice_Callback
% DESC-Executes on button press, crops all slices after the current slice
% IN-handles.slice: the slice to become the new last slice
% OUT-handles.img: the cropped image
% handles.bwCountour: the cropped mask 
function pushbuttonSetLastSlice_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = SetLastSlice(hObject,eventdata,handles);

% NAME-pushbuttonInvertMask_Callback
% DESC-Executes on button press, inverts the mask
% OUT-handles.bwContour: the inverted mask
function pushbuttonInvertMask_Callback(hObject, eventdata, handles)
    handles.bwContour = ~handles.bwContour;

    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);

% NAME-pushbuttonCopyMask_Callback
% DESC-Executes on button press, saves a copy of the mask at the current slice
% IN-handles.bwContour: the mask to be saved
% OUT-handles.maskCopy: a copy of the current slice of the mask
function pushbuttonCopyMask_Callback(hObject, eventdata, handles)
    handles.maskCopy = handles.bwContour(:,:,handles.slice);
    guidata(hObject, handles);

% NAME-pushbuttonPasteMask_Callback
% DESC-Executes on button press, copies the saved mask to the current slice
% IN-handles.maskCopy: the saved mask copy
% OUT-handles.bwContour: the mask to be pasted to
function pushbuttonPasteMask_Callback(hObject, eventdata, handles)
    % Create temp mask from maskCopy
    tmp = handles.bwContour(:,:,handles.slice);
    tmp(handles.maskCopy) = 1;
    % Replace mask at current slice with temp mask
    handles.bwContour(:,:,handles.slice) = tmp;

    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);

% NAME-pushbuttonStoreMask_Callback
% DESC-Executes on button press, saves the current mask
% IN-handles.bwContour: the mask to be saved
% handles.editMaskName: the name to save the mask as
% OUT-handles: adds a new handle containing the saved mask
function pushbuttonStoreMask_Callback(hObject, eventdata, handles)
% Allows saving mask as chosen variable
% TODO- Potential code injection, try creating a list of names instead
    eval(['handles.' get(handles.editMaskName,'String') ' = handles.bwContour;']);
    guidata(hObject, handles);

% NAME-editMaskName_Callback
% DESC-Executes on text entry, does nothing
function editMaskName_Callback(hObject, eventdata, handles)

% NAME-editMaskName_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white .
function editMaskName_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-pushbuttonSetColorMap_Callback   
% DESC-Executes on button press, sets the color map to the chosen value
% IN-handles.popupmenuSetColorMap: the color map popup menu
% OUT-handles.colormap: the name of the color map used to display the
% image, default is grey (black to white greyscale)
function pushbuttonSetColorMap_Callback(hObject, eventdata, handles)
    str = get(handles.popupmenuSetColorMap,'String');
    handles.colormap = str{get(handles.popupmenuSetColorMap,'Value')};
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);

% NAME-popupmenuSetColorMap_Callback
% DESC-Executes on selection change, does nothing(handled by
% pushbuttonSetColorMap_Callback)
function popupmenuSetColorMap_Callback(hObject, eventdata, handles)

% NAME-popupmenuSetColorMap_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white 
function popupmenuSetColorMap_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-togglebuttonRobustThickness_Callback
% DESC-Executes on button press, toggles the robust thickness option
% IN-handles.togglebuttonRobustThickness: the robust thickness toggle button
% OUT-handles.robust: the robust thickness option, is used in some analyses
function togglebuttonRobustThickness_Callback(hObject, eventdata, handles)
    if get(handles.togglebuttonRobustThickness,'Value') == 1
        set(handles.togglebuttonRobustThickness,'BackgroundColor',[1, 0, 0]); % Set the button color to red when on
        handles.robust = 1;
    elseif get(handles.togglebuttonRobustThickness,'Value') == 0
        set(handles.togglebuttonRobustThickness,'BackgroundColor',[.94, .94, .94]);
        handles.robust = 0;
    end
    guidata(hObject, handles);

% NAME-pushbuttonSaveWorkspace_Callback
% DESC-Executes on button press, saves the current workspace settings
function pushbuttonSaveWorkspace_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = SaveWorkspace(hObject,eventdata,handles);

% NAME-pushbuttonLoadWorkspace_Callback
% DESC-Executes on button press, loads a previously saved workspace
function pushbuttonLoadWorkspace_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = LoadWorkspace(hObject,eventdata,handles);

% NAME-pushbuttonMakeIsotropic_Callback
% DESC-Adjusts the dataset to make the slice thickness match the pixel size
function pushbuttonMakeIsotropic_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = MakeDatasetIsotropic(hObject,eventdata,handles);

% NAME-pushbuttonLoadMask_Callback  
% DESC-sets the mask to one previous saved with Store Mask
function pushbuttonLoadMask_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = LoadMask(hObject,eventdata,handles);

% NAME-pushbuttonUseForContouring_Callback
% DESC-Saves the current image as the original if none exists, and adjusts
% the image's thresholds
function pushbuttonUseForContouring_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = UseForContouring(hObject,eventdata,handles);

% NAME-popupmenuFilter_Callback  
% DESC-Executes during object creation, does nothing
function popupmenuFilter_Callback(hObject, eventdata, handles)

% NAME-popupmenuFilter_CreateFcn
% DESC-Executes on object creation, sets the backup background color to white 
function popupmenuFilter_CreateFcn(hObject, eventdata, handles)
    setBackground(hObject, 'white');

% NAME-pushbuttonExecuteFilter_Callback
% DESC-Applies the chosen filter to the image
% IN-handles.popupmenuFilter: the popup menu for choosing the filter
% handles.sigma: the wieght to use for the filters
% handles,radius: the radius to use for the filters
% OUT-handles.img: the filtered image
function pushbuttonExecuteFilter_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = ExecuteFilter(hObject,eventdata,handles);