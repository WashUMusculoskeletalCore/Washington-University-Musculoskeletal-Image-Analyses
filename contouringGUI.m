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

set(handles.textBusy,'String','Not Busy');

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
handles.rotateAxis = 1;

handles.primitive = 'rectangle';
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
handles.empty = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes contouringGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% DESC-Executes on button press, loads an image from a tif stack
function pushbuttonLoadTifStack_Callback(hObject, eventdata, handles)  %#ok<*DEFNU>
    [hObject, eventdata, handles] = LoadTiffStack(hObject,eventdata,handles); %#ok<*ASGLU>
    
function varargout = contouringGUI_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;

% DESC-Executes when image slider is used, updates the current slice
% IN-handles.sliderIMG: The value selected/displayed with the slider
% OUT-handles.slice: The number of the current active slice
%     handles.editSliceNumber: The slice number selected/displayed with a
%     textbox
function sliderIMG_Callback(hObject, eventdata, handles) 
    % Sets the active slice to the value chosen with the slider
    handles.slice = round(get(handles.sliderIMG,'Value'));
    % And sets the slice number to the same value
    set(handles.editSliceNumber,'String',num2str(handles.slice));
    UpdateImage(hObject, eventdata, handles);
    guidata(hObject, handles);

% DESC-Executes when the image slider is created, sets the background color
% to gray
% OUT-hobject.BackgroundColor: the background color of the sider
function sliderIMG_CreateFcn(hObject, eventdata, handles)  %#ok<*INUSD>
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

% DESC-Executes on button press, loads an image from DICOM stack    
function pushbuttonLoadIMG_Callback(hObject, eventdata, handles) 
    [hObject, eventdata, handles] = LoadDICOMStack(hObject,eventdata,handles);
% DESC-Executes on button press, allows the user to draw a black and white
% mask
% IN-Freehand 2d image draw by user
%    handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function pushbuttonDrawContour_Callback(hObject, eventdata, handles)% %%encapsulated
    [hObject, eventdata, handles] = DrawContour(hObject, eventdata, handles);
% DESC-Executes on button press, allows the user to draw a black and white
% mask to be removed from the current mask
% IN-Freehand 2d image draw by user
%    handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function pushbuttonSubtractContour_Callback(hObject, eventdata, handles)
    [hObject, eventdata, handles] = SubtractContour(hObject, eventdata, handles);
% DESC-Executes on button press, allows the user to draw a black and white
% mask to be added to the current mask
% IN-Freehand 2d image draw by user
%    handles.slice: the current active slice
% OUT handles.bwContour: the 3d image mask
function pushbuttonAddContour_Callback(hObject, eventdata, handles)
    [hObject, eventdata, handles] = AddContour(hObject, eventdata, handles);
% DESC-Executes on button press, 
function pushbuttonMorphRange_Callback(hObject, eventdata, handles)
    [hObject, eventdata, handles] = MorphRange(hObject, eventdata, handles);
% DESC-Executes on button press,
function pushbuttonAdjustCurrentSlice_Callback(hObject, eventdata, handles)
    [hObject, eventdata, handles] = AdjustCurrentSlice(hObject, eventdata, handles);

% --- Executes on selection change in popupmenuContourMethod.
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

function popupmenuContourMethod_CreateFcn(hObject, eventdata, handles)
    % TODO- This is reused a lot. Make it into a function.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function editSmoothFactor_Callback(hObject, eventdata, handles)
    handles.smoothFactor = str2num(get(handles.editSmoothFactor,'String'));
    guidata(hObject, handles);

function editSmoothFactor_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function editContractionBias_Callback(hObject, eventdata, handles)
    handles.contractionBias = str2num(get(handles.editContractionBias,'String'));
    guidata(hObject, handles);

function editContractionBias_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function editIterations_Callback(hObject, eventdata, handles)
    handles.iterations = str2num(get(handles.editIterations,'String'));
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editIterations_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pushbuttonExecuteAnalysis_Callback(hObject, eventdata, handles)
%TODO- Change to switch case.
if strcmpi(handles.analysis,'Cortical') == 1
    [hObject,eventdata,handles] = CorticalAnalysis(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'Cancellous') == 1
    [hObject,eventdata,handles] = CancellousAnalysis(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'FractureCallusVascularity') == 1
    [hObject,eventdata,handles] = FractureCallusVascularity(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'Arterial') == 1
    [hObject,eventdata,handles] = HruskaAortaMineralization(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'MarrowFat') == 1
    [hObject,eventdata,handles] = MarrowFat(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'TangIVDPMA') == 1
    [hObject,eventdata,handles] = TangIVDPMAMorphology(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'AlignAboutWideAxis') == 1
    [hObject,eventdata,handles] = AlignAboutWideAxis(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'MakeDatasetIsotropic') == 1
    [hObject,eventdata,handles] = MakeDatasetIsotropic(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'GenerateHistogram') == 1
    [hObject,eventdata,handles] = GenerateHistogram(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'SaveCurrentImage') == 1
    [hObject,eventdata,handles] = SaveCurrentImage(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'WriteToTiff') == 1
    [hObject,eventdata,handles] = WriteToTif(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'TendonFootprint') == 1
    [hObject,eventdata,handles] = TendonFootprint(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'MakeGif') == 1
    [hObject,eventdata,handles] = MakeGif(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'LinearMeasure') == 1
    [hObject,eventdata,handles] = LinearMeasure(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'ObjectAndVoids') == 1
    [hObject,eventdata,handles] = ObjectAndVoidPlot(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'VolumeRender') == 1
%     handles = volumeRender(handles,hObject);
    'Volume rendering currently broken by Mathworks' 
    
elseif strcmpi(handles.analysis,'TangIVDPMANotochord') == 1
    [hObject,eventdata,handles] = TangIVDPMANotocordMorphology(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'NeedlePuncture') == 1
    [hObject,eventdata,handles] = NeedlePunctureImage(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'MaskVolume') == 1
    [hObject,eventdata,handles] = CalculateMaskVolume(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'RegisterVolumes') == 1
    RegisterVolumes;
    
elseif strcmpi(handles.analysis,'2D-Analysis') == 1
    [hObject,eventdata,handles] = TwoDAnalysis(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'FractureCallusFullFracture') == 1
    [hObject,eventdata,handles] = FractureCallus3PtBendBreak(hObject,eventdata,handles);
    
%elseif strcmpi(handles.analysis,'GuilakKneeSurface') == 1
 %   [hObject,eventdata,handles] = = GuilakKneeSurface(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'SkeletonizationAnalysis') == 1
	[hObject,eventdata,handles] = SkeletonizationAnalysis(hObject,eventdata,handles);
	
elseif strcmpi(handles.analysis,'ConvertTo-DistanceMap') == 1
	[hObject,eventdata,handles] = DistanceMap(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'ConvertTo-Hounsfield') == 1
	[hObject,eventdata,handles] = ConvertToHounsfield(hObject,eventdata,handles);
    
elseif strcmpi(handles.analysis,'ConvertTo-mgHAperCCM') == 1
	[hObject,eventdata,handles] = ConvertToDensity(hObject,eventdata,handles);
	
elseif strcmpi(handles.analysis,'WriteToDICOM') == 1
    WriteCurrentImageStackToDICOM(hObject,eventdata,handles);
	
%elseif strcmpi(handles.analysis,'SaveMasksAsLabelMatrix') == 1
%    SaveMasksAsLabelMatrix(hObject,eventdata,handles);
	
elseif strcmpi(handles.analysis,'YMaxForStrain') == 1
    YMaxForStrain(hObject,eventdata,handles);
	
elseif strcmpi(handles.analysis,'ThicknessVisualization') == 1
    ThicknessVisualization(hObject,eventdata,handles);
	
elseif strcmpi(handles.analysis,'HumanCoreTrabecularThickness') == 1
    [hObject,eventdata,handles] = HumanCoreTrabecularThickness(hObject,eventdata,handles);
	
elseif strcmpi(handles.analysis,'StressFractureCallusAnalysis') == 1
    [hObject,eventdata,handles] = ScancoParameterStressFractureCallus(hObject,eventdata,handles);

elseif strcmpi(handles.analysis,'CTHistomorphometry') == 1
    [hObject,eventdata,handles] = CTHistomorphometry(hObject,eventdata,handles);
    
end

function editSigma_Callback(hObject, eventdata, handles)
    handles.sigma = str2num(get(handles.editSigma,'String'));
    guidata(hObject, handles);

function editSigma_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function editRadius_Callback(hObject, eventdata, handles)
    handles.radius = str2num(get(handles.editRadius,'String'));
    guidata(hObject, handles);

function editRadius_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function sliderThreshold_Callback(hObject, eventdata, handles)
    %Get new threshold from sliders and adjust all values based on it
    handles.threshold = get(handles.sliderThreshold,'Value');
    lowThreshTmp = handles.threshold;
    highThreshTmp = handles.upperThreshold;
    set(handles.text9,'String',num2str(handles.threshold));
    set(handles.editThreshold,'String',num2str(handles.threshold));
    % handles.bwContour(:,:,handles.slice) = handles.img(:,:,handles.slice) > handles.lowerThreshold;
    % Create binary image tpm showing everything in current slice between the
    % thresholds as 1 and everything else as 0
    tmp = false(size(handles.img(:,:,handles.slice)));
    tmp(find(handles.img(:,:,handles.slice) > lowThreshTmp)) = 1;
    tmp(find(handles.img(:,:,handles.slice) > highThreshTmp)) = 0;
    % Show a blend of the current slice and the threshold area with axes.
    imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),tmp,'blend','Parent',handles.axesIMG);
    % Display Pixel Information tool
    impixelinfo(handles.axesIMG);
    guidata(hObject, handles);

function sliderThreshold_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        % NOTE-Uses a different color from the others
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

function togglebuttonIterateBackwards_Callback(hObject, eventdata, handles)
    [hObject, eventdata, handles] = IterateBackwards(hObject, eventdata, handles);


% --- Executes on button press in togglebuttonIterateForwards.
function togglebuttonIterateForwards_Callback(hObject, eventdata, handles)
    [hObject, eventdata, handles] = IterateForwards(hObject, eventdata, handles);
    
% Removes all masks between the startMorph and endMorph slices   
function pushbuttonClearMaskRange_Callback(hObject, eventdata, handles)

handles.bwContour(:,:,handles.startMorph:handles.endMorph) = false(size(handles.bwContour(:,:,handles.startMorph:handles.endMorph)));
guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonClearAllMasks.
% Removes bwContour field if it exists, deleting all masks
function pushbuttonClearAllMasks_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearAllMasks (see GCBO)


% handles.bwContour = [];
if isfield(handles,'bwContour') == 1
    handles = rmfield(handles,'bwContour');
end
guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);

function editStartClear_Callback(hObject, eventdata, handles)
% hObject    handle to editStartClear (see GCBO)



% Hints: get(hObject,'String') returns contents of editStartClear as text
%        str2double(get(hObject,'String')) returns contents of editStartClear as a double
handles.startClear = str2num(get(handles.editStartMorph,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editStartClear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartClear (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEndClear_Callback(hObject, eventdata, handles)
% hObject    handle to editEndClear (see GCBO)



% Hints: get(hObject,'String') returns contents of editEndClear as text
%        str2double(get(hObject,'String')) returns contents of editEndClear as a double
handles.endClear = str2num(get(handles.editEndMorph,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editEndClear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEndClear (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editStartMorph_Callback(hObject, eventdata, handles)
% hObject    handle to editStartMorph (see GCBO)



% Hints: get(hObject,'String') returns contents of editStartMorph as text
%        str2double(get(hObject,'String')) returns contents of editStartMorph as a double
handles.startMorph = str2num(get(handles.editStartMorph,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editStartMorph_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartMorph (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editEndMorph_Callback(hObject, eventdata, handles)
% hObject    handle to editEndMorph (see GCBO)



% Hints: get(hObject,'String') returns contents of editEndMorph as text
%        str2double(get(hObject,'String')) returns contents of editEndMorph as a double
handles.endMorph = str2num(get(handles.editEndMorph,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editEndMorph_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEndMorph (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonUpdateEmptyRegions.
function pushbuttonUpdateEmptyRegions_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonUpdateEmptyRegions (see GCBO)


try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    %Resets emptyRanges
    clear handles.empty handles.emptyRanges;
    handles.emptyRanges = cell(0);
    guidata(hObject, handles);
    
    [a b c] = size(handles.img);
    %Create an array showing 1 for every slice without a mask
    empties = zeros([1,c]);
    for i = 1:c
        if length(find(handles.bwContour(:,:,i))) == 0
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
    
    if empties(c) ~= 1
        stops = [stops,c];
    end
    
    % Pair every start with its respective stop
    for i = 1:length(starts)
        el{i} = [num2str(starts(i)) ' , ' num2str(stops(i))];
    end
    
    set(handles.text13,'String',el);
    
    handles.maskedRanges = el;
    
    guidata(hObject, handles);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end


function editThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editThreshold (see GCBO)



% Hints: get(hObject,'String') returns contents of editThreshold as text
%        str2double(get(hObject,'String')) returns contents of editThreshold as a double
handles.threshold = str2num(get(handles.editThreshold,'String'));
set(handles.sliderThreshold,'Value',handles.threshold);
tmp = handles.img(:,:,handles.slice) > handles.threshold;
imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),tmp,'blend','Parent',handles.axesIMG);
impixelinfo(handles.axesIMG);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editThreshold (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonCreate3DObject.
function pushbuttonCreate3DObject_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCreate3DObject (see GCBO)


set(handles.textBusy,'String','Busy');
drawnow();
% Generate 3d shape from masks 
handles.shp = shpFromBW(handles.bwContour,handles.sphereSize);
% Create new window and display the shape in it
figure();
plot(handles.shp,'FaceColor',handles.STLColor ./ 255,'LineStyle','none');
camlight();

guidata(hObject, handles);
set(handles.textBusy,'String','Not Busy');
guidata(hObject, handles);
drawnow();

% --- Executes on button press in pushbuttonWriteSTL.
function pushbuttonWriteSTL_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonWriteSTL (see GCBO)


try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    if strcmpi(handles.stlWriteMethod,'ascii') == 1
        % Generate a filename
        fName = ['scaled-' num2str(handles.imgScale) '-' handles.DICOMPrefix '-stl-ascii.stl'];
        % Write boundaryFacets and Points to that filename with mode:ASCII
        stlwrite(fullfile(handles.pathstr,fName),handles.shp.boundaryFacets,handles.shp.Points,'mode','ascii');
    else
        % Generate a filename
        fName = ['scaled-' num2str(handles.imgScale) '-' handles.DICOMPrefix '-stl.stl'];
        % Write boundaryFacets and Points to that filename with specified
        % FaceColor
        stlwrite(fullfile(handles.pathstr,fName),handles.shp.boundaryFacets,handles.shp.Points,'FaceColor',handles.STLColor);
    end
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

% --- Executes on button press in pushbuttonSetMaskThreshold.
% Sets mask to 1 in all parts of img between thresholds and 0 elsewhere
function pushbuttonSetMaskThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetMaskThreshold (see GCBO)


handles.bwContour = handles.img > handles.lowerThreshold;
handles.bwContour(handles.img > handles.upperThreshold) = 0;
guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonRemoveSpeckleNoiseFromMask.
function pushbuttonRemoveSpeckleNoiseFromMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemoveSpeckleNoiseFromMask (see GCBO)


try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
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
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

function editSpeckleSize_Callback(hObject, eventdata, handles)
% hObject    handle to editSpeckleSize (see GCBO)



% Hints: get(hObject,'String') returns contents of editSpeckleSize as text
%        str2double(get(hObject,'String')) returns contents of editSpeckleSize as a double
handles.speckleSize = str2num(get(handles.editSpeckleSize,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editSpeckleSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpeckleSize (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editSliceNumber_Callback(hObject, eventdata, handles)
% hObject    handle to editSliceNumber (see GCBO)



% Hints: get(hObject,'String') returns contents of editSliceNumber as text
%        str2double(get(hObject,'String')) returns contents of editSliceNumber as a double
handles.slice = str2num(get(handles.editSliceNumber,'String'));
set(handles.sliderIMG,'Value',handles.slice);
guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function editSliceNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSliceNumber (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonScaleImageSize.
function pushbuttonScaleImageSize_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonScaleImageSize (see GCBO)


try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    % Resize img in 3 dimensions by imgScale
    handles.img = imresize3(handles.img,handles.imgScale);
    % TODO- Can this be deleted? Use handles.abc instead
    [a b c] = size(handles.img);
    % If bwContour exists, resize it too
    if isfield(handles,'bwContour')
        handles.bwContour = resize3DMatrixBW(handles.bwContour,handles.imgScale);
    end
    % Set abc to new size
    handles.abc = size(handles.img);
    % Reset slider to new size
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    %Rescale the text voxels so they still only fill one slice
    set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness / handles.imgScale));
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

function editScaleImageSize_Callback(hObject, eventdata, handles)
% hObject    handle to editScaleImageSize (see GCBO)



% Hints: get(hObject,'String') returns contents of editScaleImageSize as text
%        str2double(get(hObject,'String')) returns contents of editScaleImageSize as a double
handles.imgScale = str2num(get(handles.editScaleImageSize,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editScaleImageSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editScaleImageSize (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSphereSizeForAlphaShape_Callback(hObject, eventdata, handles)
% hObject    handle to editSphereSizeForAlphaShape (see GCBO)



% Hints: get(hObject,'String') returns contents of editSphereSizeForAlphaShape as text
%        str2double(get(hObject,'String')) returns contents of editSphereSizeForAlphaShape as a double
handles.sphereSize = str2num(get(handles.editSphereSizeForAlphaShape,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editSphereSizeForAlphaShape_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSphereSizeForAlphaShape (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuSTLAsciiBinary.
function popupmenuSTLAsciiBinary_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSTLAsciiBinary (see GCBO)



% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSTLAsciiBinary contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSTLAsciiBinary
str = get(handles.popupmenuSTLAsciiBinary,'String');
val = get(handles.popupmenuSTLAsciiBinary,'Value');
switch str{val}
    case 'ascii'
        handles.stlWriteMethod = 'ascii';
    case 'binary'
        handles.stlWriteMethod = 'binary';
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuSTLAsciiBinary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSTLAsciiBinary (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonIsolateObjectOfInterest.
function pushbuttonIsolateObjectOfInterest_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonIsolateObjectOfInterest (see GCBO)

% Remove everything not in mask from image
handles.img(~handles.bwContour) = 0;
% end
guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);

% --- Executes on button press in pushbuttonCropImageToMask.
function pushbuttonCropImageToMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCropImageToMask (see GCBO)


%Find the minimum and maximum x, y, and z containing a nonzero in bwContour
[x y z] = ind2sub(size(handles.bwContour),find(handles.bwContour));
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
handles.abc = size(handles.img);
% Reset slider to match new size
set(handles.sliderIMG,'Value',1);
set(handles.sliderIMG,'min',1);
set(handles.sliderIMG,'max',handles.abc(3));
set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);



function editDICOMPrefix_Callback(hObject, eventdata, handles)
% hObject    handle to editDICOMPrefix (see GCBO)



% Hints: get(hObject,'String') returns contents of editDICOMPrefix as text
%        str2double(get(hObject,'String')) returns contents of editDICOMPrefix as a double
handles.DICOMPrefix = get(handles.editDICOMPrefix,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editDICOMPrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDICOMPrefix (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSetMaskToComponent.
function pushbuttonSetMaskToComponent_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetMaskToComponent (see GCBO)


try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    
    str = get(handles.popupmenuMaskComponents,'String');
    val = get(handles.popupmenuMaskComponents,'Value');
    str = str{val};
    
    %TODO- Can't find documentation for bwIndex, it seems like this sets
    %the mask based on the selected value
    handles.bwContour = bwIndex(handles.bwContour, str2num(str));
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

% --- Executes on button press in togglebuttonInvertImage.
function togglebuttonInvertImage_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonInvertImage (see GCBO)



% Hint: get(hObject,'Value') returns toggle state of togglebuttonInvertImage
handles.img = 2^(handles.info.BitDepth-1) - handles.img; %change to info bit thing
% end

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);


% --- Executes on selection change in popupmenuSTLColor.
function popupmenuSTLColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSTLColor (see GCBO)



% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSTLColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSTLColor
str = get(handles.popupmenuSTLColor,'String');
val = get(handles.popupmenuSTLColor,'Value');

if strcmpi(str{val},'r') == 1
    %Red
    handles.STLColor = [255 0 0];
elseif strcmpi(str{val},'g') == 1
    %Green
    handles.STLColor = [0 255 0];
elseif strcmpi(str{val},'b') == 1
    %Blue
    handles.STLColor = [0 0 255];
elseif strcmpi(str{val},'y') == 1
    %Yellow
    handles.STLColor = [255 255 0];
elseif strcmpi(str{val},'k') == 1
    %Black
    handles.STLColor = [0 0 0];
elseif strcmpi(str{val},'c') == 1
    %Cyan
    handles.STLColor = [0 255 255];
elseif strcmpi(str{val},'w') == 1
    %White
    handles.STLColor = [255 255 255];
end
%TODO- Magenta? Also change to switch case.
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuSTLColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSTLColor (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function textPercentLoaded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textPercentLoaded (see GCBO)

% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbuttonRotateImage.
function pushbuttonRotateImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRotateImage (see GCBO)


try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    %TODO-Use handlse.abc instead
    [a b c] = size(handles.img);
    
    %TODO- Is this needed? Slider doesn't change. 
    handles.slice = round(get(handles.sliderIMG,'Value'));
    
    %Create temp storage with the same depth as the image
    tmp = cell([1 c]);
    tmp2 = cell([1 c]);
    % For each slice, rotate the image and mask and store the new
    % image/mask slice in tmp and tmp2
    for i = 1:c
        tmp{i} = imrotate(handles.img(:,:,i),handles.rotateDegrees,'crop');
        if isfield(handles,'bwContour') == 1
            tmp2{i} = imrotate(handles.bwContour(:,:,i),handles.rotateDegrees,'crop');
        end
    end
    clear handles.img;
    % Replace the image with the rotated version
    for i = 1:c
        handles.img(:,:,i) = tmp{i};
    end
    % Replace the mask with the rotated version
    if isfield(handles,'bwContour') == 1
        clear handles.bwContour;
        for i = 1:c
            handles.bwContour(:,:,i) = tmp2{i};
        end
    end
    %set to update graphics stuff
    handles.abc = size(handles.img);
    
    %TODO- Might not be needed, c doesn't change
    set(handles.sliderIMG,'Value',handles.slice);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
   
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

function editRotationDegrees_Callback(hObject, eventdata, handles)
% hObject    handle to editRotationDegrees (see GCBO)



% Hints: get(hObject,'String') returns contents of editRotationDegrees as text
%        str2double(get(hObject,'String')) returns contents of editRotationDegrees as a double
handles.rotateDegrees = str2num(get(handles.editRotationDegrees,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editRotationDegrees_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRotationDegrees (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonFlipImage.
function pushbuttonFlipImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFlipImage (see GCBO)


% Flip the image and mask around the axis
handles.img = flip(handles.img,handles.rotateAxis);
if isfield(handles,'bwContour') == 1
    handles.bwContour = flip(handles.bwContour,handles.rotateAxis);
end

handles.abc = size(handles.img);
% handles.bwContour = false(size(handles.img));

%TODO- Might not be needed, Check how flip affects c
set(handles.sliderIMG,'Value',1);
set(handles.sliderIMG,'min',1);
set(handles.sliderIMG,'max',handles.abc(3));
set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));

handles.slice = 1;

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);


% --- Executes on selection change in popupmenuRotationAxis.
function popupmenuRotationAxis_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuRotationAxis (see GCBO)



% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuRotationAxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuRotationAxis
str = get(handles.popupmenuRotationAxis,'String');
val = get(handles.popupmenuRotationAxis,'Value');
% TODO- Check why 1 and 2 are switched
switch str{val}
    case '1'
        handles.rotateAxis = 2;
    case '2'
        handles.rotateAxis = 1;
    case '3'
        handles.rotateAxis = 3;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuRotationAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuRotationAxis (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenuMaskComponents.
function popupmenuMaskComponents_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMaskComponents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMaskComponents contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMaskComponents

% --- Executes on button press in pushbuttonPopulateMaskComponents.
function pushbuttonPopulateMaskComponents_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPopulateMaskComponents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    %Identifies all connected components of mask
    handles.cc = bwconncomp(handles.bwContour);
    %Create a list of all components in string format
    for i = 1:length(handles.cc.PixelIdxList)
        connCompInd{i} = num2str(i);
        %TODO- is this slow enough to need a loading indicator?
        set(handles.textPercentLoaded,'String',num2str(i/length(handles.cc.PixelIdxList)));
        drawnow();
    end
    set(handles.popupmenuMaskComponents,'String',connCompInd);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
catch
    set(handles.textBusy,'String','Failed');
end

% --- Executes on button press in pushbuttonSetMaskByClicking.
function pushbuttonSetMaskByClicking_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetMaskByClicking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    % Interactive point selection
    [x y] = getpts(handles.axesIMG);
    z(1:length(x),1) = handles.slice;
    pt = round([y x z]);%points to use to select mask component
    % Identifies connected components of mask
    cc = bwconncomp(handles.bwContour);
    % Create an array matching components and chosen points
    removeFlag = zeros(length(cc.PixelIdxList),length(pt(:,1)));
    for i = 1:length(cc.PixelIdxList)
        % For each component, get subscripts of pixels in component 
        [idxx idxy idxz] = ind2sub(size(handles.bwContour),cc.PixelIdxList{i});
        idx = [idxx idxy idxz];
        for k = 1:length(pt(:,1))
            % For each point and component, if point is not in component 
            % set removeFlag for component/point combo
            %TODO- once one point in component found, move to next
            %component? Might be more efficient.
            if length(find(ismember(pt(k,:),idx,'rows'))) == 0
                removeFlag(i,k) = 1;
            end
        end
        % Update percentage
        set(handles.textPercentLoaded,'String',num2str(i/length(cc.PixelIdxList)));
        drawnow();
    end
    
    % If all remove flags for a component are set, remove it from the mask
    % All flags = None of the selected points were on the component
    for i = 1:length(removeFlag)
        if sum(removeFlag(i,:)) == length(removeFlag(i,:))
            handles.bwContour(cc.PixelIdxList{i}) = 0;
        end
    end
    
    UpdateImage(hObject,eventdata,handles);
    
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
    
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end




% --- Executes on button press in pushbuttonMorphAll.
function pushbuttonMorphAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMorphAll (see GCBO)


try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    clear handles.maskedRanges;
    guidata(hObject, handles);
    
    %TODO- Use handles.abc
    [a b c] = size(handles.img);
    empties = zeros([1,c]);
    % Identify all slices without mask
    for i = 1:c
        if length(find(handles.bwContour(:,:,i))) == 0
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
        starts = [1,starts];
    end
    
    if empties(c) ~= 1
        stops = [stops,c];
    end
    
    %Match starts and stops as pairs
    for i = 1:length(starts)
        ranges(i,:) = [starts(i),stops(i)];
    end
    
    % For each pair, identify the section of mask between as a 3d shape and
    % flip it around the z axis.
    for i = 1:length(ranges)-1
        start = ranges(i,2);
        stop = ranges(i+1,1);
         
        bwTemp = interp_shape(handles.bwContour(:,:,start),handles.bwContour(:,:,stop),abs(start-stop + 1));
        bwTemp = flip(bwTemp,3);
        handles.bwContour(:,:,start+1:stop-1) = bwTemp;
    end
    
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end


% --- Executes on button press in pushbuttonCreatePrimitive.
function pushbuttonCreatePrimitive_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCreatePrimitive (see GCBO)



str = get(handles.popupmenuPrimitive,'String');
val = get(handles.popupmenuPrimitive,'Value');
switch str{val}
    case 'Oval'
        handles.primitive = 'oval';
    case 'Rectangle'
        handles.primitive = 'rectangle';
end

if strcmpi(handles.primitive,'oval') == 1
    
    a=handles.primitiveWidth; % horizontal radius
    b=handles.primitiveHeight; % vertical radius
    x0=handles.primitiveCenter(1); % x0,y0 ellipse centre coordinates
    y0=handles.primitiveCenter(2);
    t=-pi:0.01:pi;
    x=x0+a*cos(t);
    y=y0+b*sin(t);
    phi = handles.primitiveRotationAngle;
    %     x = (x-x0) * cos(phi) - (y-y0) * sin(phi) + x0;
    %     y = (x-x0) * sin(phi) + (y-y0) * cos(phi) + y0;
    %add rotation matirx
    hold on;
    plot(x,y,'Parent',handles.axesIMG)
    hold off;
    
    
    ct=0;
    % Make query set representing the slice in ellipse's rectangle
    % TODO-prealocate xq and yq
    for i = min(x):max(x)
        for j = floor(min(y)):floor(max(y))
            ct=ct+1;
            xq(ct) = i;
            yq(ct) = j;
        end
    end
    
    
    
    xc = x0;
    yc = y0;
    % Clear the mask for current slice
    if isfield(handles,'bwContour') == 0
        handles.bwContour = false(size(handles.img));
        tmp = false(size(handles.bwContour(:,:,handles.slice)));
    else
        tmp = false(size(handles.bwContour(:,:,handles.slice)));
    end
    % For each point (xq,yq), if it is inside the ellipse, add it to tmp
    for i = 1:length(xq)
        % TODO-Simplify, cos(0)=1, sin(0)=0
        if ((xq(i)-xc)*cos(0)-(yq(i)-yc)*sin(0)).^2/a^2 + ((xq(i)-xc)*sin(0)+(yq(i)-yc)*cos(0)).^2/b^2 <= 1
            tmp(round(yq(i)),round(xq(i))) = 1;
        end
    end
    % Redraw mask for current slice using tmp
    handles.bwContour(:,:,handles.slice) = tmp;
    if handles.primitiveRotationAngle ~= 0
        % Rotate the mask if rotation angle is not 0
        handles.bwContour(:,:,handles.slice) = imrotate(handles.bwContour(:,:,handles.slice),rad2deg(handles.primitiveRotationAngle),'crop');
        % Fill in any small gaps created by rotation
        handles.bwContour(:,:,handles.slice) = imclose(handles.bwContour(:,:,handles.slice),strel('disk',4,0));
    end
    
    guidata(hObject, handles);
    
    
    
elseif strcmpi(handles.primitive,'rectangle') == 1
    %     handles.primitiveCenter = [round(handles.abc(1)/2),round(handles.abc(2)/2)];
    % Clear any existing mask
    if isfield(handles,'bwContour') == 0
        handles.bwContour = false(size(handles.img));
    end
    handles.abc = size(handles.img);
    % Retain all plots on current axis
    hold on;
    % TODO-Find DrawRectangle and inpoly source
    % TODO-This might need rework to be less dependant on those functions,
    % could reuse ellipse code
    [P,R] = DrawRectangle([handles.primitiveCenter(1),handles.primitiveCenter(2),...
        handles.primitiveWidth,handles.primitiveHeight,str2num(get(handles.editRotatePrimitive,'String'))]);
    ct=0;%make query set representing whole slice
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
    %     tmp = imrotate(tmp,rad2deg(str2num(get(handles.editRotatePrimitive,'String'))),'crop');
    % Set mask to rectangle
    handles.bwContour(:,:,handles.slice) = tmp;
    %     handles.bwContour(:,:,handles.slice) = imclose(handles.bwContour(:,:,handles.slice),true(9,9));
    
    hold off;
    
    guidata(hObject, handles);
end

% Reset text center to new mask center
[row col] = find(handles.bwContour(:,:,handles.slice));
cent = [round(mean(row)) round(mean(col))];
set(handles.textCenterLocation,'String',[num2str(cent(1)) ' ' num2str(cent(2))]);

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);

% --- Executes on selection change in popupmenuPrimitive.
function popupmenuPrimitive_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuPrimitive (see GCBO)



% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuPrimitive contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuPrimitive


% --- Executes during object creation, after setting all properties.
function popupmenuPrimitive_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuPrimitive (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPrimitiveHeight_Callback(hObject, eventdata, handles)
% hObject    handle to editPrimitiveHeight (see GCBO)



% Hints: get(hObject,'String') returns contents of editPrimitiveHeight as text
%        str2double(get(hObject,'String')) returns contents of editPrimitiveHeight as a double
handles.primitiveHeight = str2num(get(handles.editPrimitiveHeight,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editPrimitiveHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPrimitiveHeight (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPrimitiveWidth_Callback(hObject, eventdata, handles)
% hObject    handle to editPrimitiveWidth (see GCBO)



% Hints: get(hObject,'String') returns contents of editPrimitiveWidth as text
%        str2double(get(hObject,'String')) returns contents of editPrimitiveWidth as a double
handles.primitiveWidth = str2num(get(handles.editPrimitiveWidth,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editPrimitiveWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPrimitiveWidth (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editRotatePrimitive_Callback(hObject, eventdata, handles)
% hObject    handle to editRotatePrimitive (see GCBO)



% Hints: get(hObject,'String') returns contents of editRotatePrimitive as text
%        str2double(get(hObject,'String')) returns contents of editRotatePrimitive as a double
handles.primitiveRotationAngle = str2num(get(handles.editRotatePrimitive,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editRotatePrimitive_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRotatePrimitive (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% TODO-Are these unused/unneeded? Either delete or implement them.
function editTranslateUp_Callback(hObject, eventdata, handles)
% hObject    handle to editTranslateUp (see GCBO)



% Hints: get(hObject,'String') returns contents of editTranslateUp as text
%        str2double(get(hObject,'String')) returns contents of editTranslateUp as a double


% --- Executes during object creation, after setting all properties.
function editTranslateUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTranslateUp (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTranslateDown_Callback(hObject, eventdata, handles)
% hObject    handle to editTranslateDown (see GCBO)



% Hints: get(hObject,'String') returns contents of editTranslateDown as text
%        str2double(get(hObject,'String')) returns contents of editTranslateDown as a double


% --- Executes during object creation, after setting all properties.
function editTranslateDown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTranslateDown (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTranslateLeft_Callback(hObject, eventdata, handles)
% hObject    handle to editTranslateLeft (see GCBO)



% Hints: get(hObject,'String') returns contents of editTranslateLeft as text
%        str2double(get(hObject,'String')) returns contents of editTranslateLeft as a double


% --- Executes during object creation, after setting all properties.
function editTranslateLeft_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTranslateLeft (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTranslateRight_Callback(hObject, eventdata, handles)
% hObject    handle to editTranslateRight (see GCBO)



% Hints: get(hObject,'String') returns contents of editTranslateRight as text
%        str2double(get(hObject,'String')) returns contents of editTranslateRight as a double


% --- Executes during object creation, after setting all properties.
function editTranslateRight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTranslateRight (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonTranslateUp.
% Get the location of all points in mask, shift them in desired direction, 
% and replace mask
% TODO-Combine all 4 directions into 1 function with switch case
function pushbuttonTranslateUp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTranslateUp (see GCBO)


% xy = zeros(handles.abc(1),handles.abc(2));

[row col] = find(handles.bwContour(:,:,handles.slice));
row = row - str2num(get(handles.editTranslateUp,'String'));
tmp = false(size(handles.bwContour(:,:,handles.slice)));
for i = 1:length(row)
    tmp(row(i),col(i)) = 1;
end

cent = [round(mean(row)) round(mean(col))];
set(handles.textCenterLocation,'String',[num2str(cent(1)) ' ' num2str(cent(2))]);

handles.bwContour(:,:,handles.slice) = tmp;

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);

% --- Executes on button press in pushbuttonTranslateDown.
function pushbuttonTranslateDown_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTranslateDown (see GCBO)


[row col] = find(handles.bwContour(:,:,handles.slice));
row = row + str2num(get(handles.editTranslateDown,'String'));
tmp = false(size(handles.bwContour(:,:,handles.slice)));
for i = 1:length(row)
    tmp(row(i),col(i)) = 1;
end

cent = [round(mean(row)) round(mean(col))];
set(handles.textCenterLocation,'String',[num2str(cent(1)) ' ' num2str(cent(2))]);

handles.bwContour(:,:,handles.slice) = tmp;

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);

% --- Executes on button press in pushbuttonTranslateLeft.
function pushbuttonTranslateLeft_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTranslateLeft (see GCBO)


[row col] = find(handles.bwContour(:,:,handles.slice));
col = col - str2num(get(handles.editTranslateLeft,'String'));
tmp = false(size(handles.bwContour(:,:,handles.slice)));
for i = 1:length(row)
    tmp(row(i),col(i)) = 1;
end

cent = [round(mean(row)) round(mean(col))];
set(handles.textCenterLocation,'String',[num2str(cent(1)) ' ' num2str(cent(2))]);

handles.bwContour(:,:,handles.slice) = tmp;

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);

% --- Executes on button press in pushbuttonTranslateRight.
function pushbuttonTranslateRight_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTranslateRight (see GCBO)


[row col] = find(handles.bwContour(:,:,handles.slice));
col = col + str2num(get(handles.editTranslateRight,'String'));
tmp = false(size(handles.bwContour(:,:,handles.slice)));
for i = 1:length(row)
    tmp(row(i),col(i)) = 1;
end

cent = [round(mean(row)) round(mean(col))];
set(handles.textCenterLocation,'String',[num2str(cent(1)) ' ' num2str(cent(2))]);

handles.bwContour(:,:,handles.slice) = tmp;

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function axesIMG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesIMG (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesIMG


% --- Executes on button press in pushbuttonZoomtoRegion.
function pushbuttonZoomtoRegion_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonZoomtoRegion (see GCBO)


try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
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
    handles.abc = size(handles.img);
    
    handles.info.Height = handles.abc(1);
    handles.info.Width = handles.abc(2);
    handles.info.Rows = handles.abc(1);
    handles.info.Columns = handles.abc(2);
    
    handles.slice = 1;
    handles.abc = size(handles.img);
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    
    % end
    hold off;
    
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end
% --- Executes on button press in pushbuttonDiskMorphological.
function pushbuttonDiskMorphological_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDiskMorphological (see GCBO)


% Perform the selected morphological operation on the image. Erode expands
% darker and shrinks/removes lighter features, dilate does the opposite
if strcmpi(handles.morphological,'Erode') == 1
    handles.img = imerode(handles.img,strel('disk',str2num(get(handles.editDiskSize,'String')),0));
elseif strcmpi(handles.morphological,'Dilate') == 1
    handles.img = imdilate(handles.img,strel('disk',str2num(get(handles.editDiskSize,'String')),0));
end

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);

function editDiskSize_Callback(hObject, eventdata, handles)
% hObject    handle to editDiskSize (see GCBO)



% Hints: get(hObject,'String') returns contents of editDiskSize as text
%        str2double(get(hObject,'String')) returns contents of editDiskSize as a double

% --- Executes during object creation, after setting all properties.
function editDiskSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDiskSize (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuCorticalCancellous.
function popupmenuCorticalCancellous_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuCorticalCancellous (see GCBO)



% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuCorticalCancellous contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuCorticalCancellous
str = get(handles.popupmenuCorticalCancellous,'String');
val = get(handles.popupmenuCorticalCancellous,'Value');
% Set handles.analysis based on option from popup menu.
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

% --- Executes during object creation, after setting all properties.
function popupmenuCorticalCancellous_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuCorticalCancellous (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonRotate90.
function pushbuttonRotate90_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRotate90 (see GCBO)


try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    % Rotate image and mask by selected angle
    handles.img = rot90_3D(handles.img,get(handles.popupmenuRotationAxis,'Value'),1);
    if isfield(handles,'bwContour') == 1
        handles.bwContour = rot90_3D(handles.bwContour,get(handles.popupmenuRotationAxis,'Value'),1);
    end
    
    % Adjust abc and slider based around new size
    handles.abc = size(handles.img);
    handles.primitiveCenter(1) = round(handles.abc(1)/2);
    handles.primitiveCenter(2) = round(handles.abc(2)/2);
    
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    % TODO- check if sliderThreshold and theMax are used elsewhere
    handles.theMax = double(max(max(max(handles.img))));
    set(handles.sliderThreshold,'Value',1);
    set(handles.sliderThreshold,'min',1);
    set(handles.sliderThreshold,'max',handles.theMax);
    set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    guidata(hObject, handles);
    UpdateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

% --- Executes on button press in pushbuttonSetLowerThreshold.
function pushbuttonSetLowerThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetLowerThreshold (see GCBO)


handles.lowerThreshold = handles.threshold;
set(handles.textLowerThreshold,'String',num2str(handles.lowerThreshold));
guidata(hObject, handles);

% --- Executes on button press in pushbuttonSetUpperThreshold.
function pushbuttonSetUpperThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetUpperThreshold (see GCBO)


handles.upperThreshold = handles.threshold;
set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
guidata(hObject, handles);


% --- Executes on button press in togglebuttonToggleMask
function togglebuttonToggleMask_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonToggleMask (see GCBO)



% Hint: get(hObject,'Value') returns toggle state of togglebuttonToggleMask
if get(handles.togglebuttonToggleMask,'Value') == 1
    % Show the mask and adjusted image blended together
    imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
    impixelinfo(handles.axesIMG);
else
    % Or show just he adjusted image
    imshow(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),'Parent',handles.axesIMG);
    impixelinfo(handles.axesIMG);
end

guidata(hObject, handles);


function editPrimitiveVertical_Callback(hObject, eventdata, handles)
% hObject    handle to editPrimitiveVertical (see GCBO)



% Hints: get(hObject,'String') returns contents of editPrimitiveVertical as text
%        str2double(get(hObject,'String')) returns contents of editPrimitiveVertical as a double
handles.primitiveCenter(2) = str2num(cell2mat(get(handles.editPrimitiveVertical,'String')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editPrimitiveVertical_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPrimitiveVertical (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPrimitiveHorizontal_Callback(hObject, eventdata, handles)
% hObject    handle to editPrimitiveHorizontal (see GCBO)



% Hints: get(hObject,'String') returns contents of editPrimitiveHorizontal as text
%        str2double(get(hObject,'String')) returns contents of editPrimitiveHorizontal as a double
handles.primitiveCenter(1) = str2num(cell2mat(get(handles.editPrimitiveHorizontal,'String')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editPrimitiveHorizontal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPrimitiveHorizontal (see GCBO)

% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonLoadTXMFile.
function pushbuttonLoadTXMFile_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = LoadTXM(hObject,eventdata,handles);


% --- Executes on button press in pushbuttonExecuteMorphologicalOperation.
function pushbuttonExecuteMorphologicalOperation_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = ExecuteMorphologicalOperation(hObject,eventdata,handles);

% --- Executes on selection change in popupmenuImageMask.
function popupmenuImageMask_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuImageMask (see GCBO)

handles.morphologicalImageMask = cellstr(get(handles.popupmenuImageMask,'String'));
handles.morphologicalImageMask = handles.morphologicalImageMask{get(handles.popupmenuImageMask,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuImageMask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuImageMask (see GCBO)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuMorphologicalOperation.
function popupmenuMorphologicalOperation_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMorphologicalOperation (see GCBO)

handles.morphologicalOperation = cellstr(get(handles.popupmenuMorphologicalOperation,'String'));
handles.morphologicalOperation = handles.morphologicalOperation{get(handles.popupmenuMorphologicalOperation,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuMorphologicalOperation_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2D3D.
function popupmenu2D3D_Callback(hObject, eventdata, handles)

handles.morphological2D3D = cellstr(get(handles.popupmenu2D3D,'String'));
handles.morphological2D3D = handles.morphological2D3D{get(handles.popupmenu2D3D,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu2D3D_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMorpholgicalRadius_Callback(hObject, eventdata, handles)

handles.morphologicalRadius = str2num(get(handles.editMorpholgicalRadius,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editMorpholgicalRadius_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderWindowWidth_Callback(hObject, eventdata, handles)

set(handles.editWindowWidth,'String',num2str(get(handles.sliderWindowWidth,'Value')))
handles.windowWidth = get(handles.sliderWindowWidth,'Value');

% TODO-Remove unused
tmp = handles.img(:,:,handles.slice);
% Set lOut and hOut to the location of left and right side of window
% divided by dataMax
handles.lOut = (handles.windowLocation-0.5*handles.windowWidth) / double(handles.dataMax);
handles.hOut = (handles.windowLocation+0.5*handles.windowWidth)  / double(handles.dataMax);

% Ensure that lOut and hOut do not go past minimum/maximum
if handles.lOut < 0
    handles.lOut = 0;
end

if handles.hOut > 1
    handles.hOut = 1;
end

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function sliderWindowWidth_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderWindowLocation_Callback(hObject, eventdata, handles)

set(handles.editWindowLocation,'String',num2str(get(handles.sliderWindowLocation,'Value')));
handles.windowLocation = get(handles.sliderWindowLocation,'Value');
% TODO- Combine identical code
tmp = handles.img(:,:,handles.slice);

handles.lOut = (handles.windowLocation-0.5*handles.windowWidth) / double(handles.dataMax);
handles.hOut = (handles.windowLocation+0.5*handles.windowWidth)  / double(handles.dataMax);

if handles.lOut < 0
    handles.lOut = 0;
end

if handles.hOut > 1
    handles.hOut = 1;
end

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function sliderWindowLocation_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editWindowWidth_Callback(hObject, eventdata, handles)

handles.windowWidth = str2num(get(handles.editWindowWidth,'String'));

tmp = handles.img(:,:,handles.slice);
handles.lOut = (handles.windowLocation-0.5*handles.windowWidth) / double(handles.dataMax);
handles.hOut = (handles.windowLocation+0.5*handles.windowWidth)  / double(handles.dataMax);

if handles.lOut < 0
    handles.lOut =0;
end

if handles.hOut > 1
    handles.hOut = 1;
end

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function editWindowWidth_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editWindowLocation_Callback(hObject, eventdata, handles)

handles.windowLocation = str2num(get(handles.editWindowLocation,'String'));
tmp = handles.img(:,:,handles.slice);
handles.lOut = (handles.windowLocation-0.5*handles.windowWidth) / double(handles.dataMax);
handles.hOut = (handles.windowLocation+0.5*handles.windowWidth)  / double(handles.dataMax);

if handles.lOut < 0
    handles.lOut = 0;
end

if handles.hOut > 1
    handles.hOut = 1;
end

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function editWindowLocation_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSetOriginalImage.
function pushbuttonSetOriginalImage_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = SetOriginalImage(hObject,eventdata,handles);




% --- Executes on button press in pushbuttonRevertImage.
function pushbuttonRevertImage_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = RevertImage(hObject,eventdata,handles);


% --- Executes on button press in pushbuttonSetFirstSlice.
function pushbuttonSetFirstSlice_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = SetFirstSlice(hObject,eventdata,handles);


% --- Executes on button press in pushbuttonSetLastSlice.
function pushbuttonSetLastSlice_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = SetLastSlice(hObject,eventdata,handles);

% --- Executes on button press in pushbuttonInvertMask.
function pushbuttonInvertMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonInvertMask (see GCBO)


handles.bwContour = ~handles.bwContour;

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonCopyMask.
function pushbuttonCopyMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCopyMask (see GCBO)

handles.maskCopy = handles.bwContour(:,:,handles.slice);
guidata(hObject, handles);


% --- Executes on button press in pushbuttonPasteMask.
function pushbuttonPasteMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPasteMask (see GCBO)

% Create temp mask from maskCopy
tmp = handles.bwContour(:,:,handles.slice);
tmp(find(handles.maskCopy)) = 1;
% Replace mask at current slice with temp mask
handles.bwContour(:,:,handles.slice) = tmp;

guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonStoreMask.
function pushbuttonStoreMask_Callback(hObject, eventdata, handles)
% Allows saving mask as chosen variable
% TODO- Potential code injection
eval(['handles.' get(handles.editMaskName,'String') ' = handles.bwContour;']);
guidata(hObject, handles);


function editMaskName_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function editMaskName_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbuttonSetColorMap.
function pushbuttonSetColorMap_Callback(hObject, eventdata, handles)

str = get(handles.popupmenuSetColorMap,'String');
handles.colormap = str{get(handles.popupmenuSetColorMap,'Value')};
guidata(hObject, handles);
UpdateImage(hObject, eventdata, handles);


% --- Executes on selection change in popupmenuSetColorMap.
function popupmenuSetColorMap_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSetColorMap (see GCBO)

% --- Executes during object creation, after setting all properties.
function popupmenuSetColorMap_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebuttonRobustThickness.
function togglebuttonRobustThickness_Callback(hObject, eventdata, handles)
    if get(handles.togglebuttonRobustThickness,'Value') == 1
        set(handles.togglebuttonRobustThickness,'BackgroundColor',[1 0 0]);
        handles.robust = 1;
    elseif get(handles.togglebuttonRobustThickness,'Value') == 0
        set(handles.togglebuttonRobustThickness,'BackgroundColor',[.94 .94 .94]);
        handles.robust = 0;
    end
    guidata(hObject, handles);


% --- Executes on button press in pushbuttonSaveWorkspace.
function pushbuttonSaveWorkspace_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = SaveWorkspace(hObject,eventdata,handles)

function pushbuttonLoadWorkspace_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = LoadWorkspace(hObject,eventdata,handles);


function pushbuttonMakeIsotropic_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = MakeDatasetIsotropic(hObject,eventdata,handles);

function pushbuttonLoadMask_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = LoadMask(hObject,eventdata,handles);

function pushbuttonUseForContouring_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = UseForContouring(hObject,eventdata,handles);

function popupmenuFilter_Callback(hObject, eventdata, handles)
%%nothing needed

function popupmenuFilter_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pushbuttonExecuteFilter_Callback(hObject, eventdata, handles)
    [hObject,eventdata,handles] = ExecuteFilter(hObject,eventdata,handles);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%Execute Analysis function block
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% function [handles] = registerVolumes(handles,hObject)
% try
%     set(handles.textBusy,'String','Busy');
%     guidata(hObject, handles);
%     drawnow();
%     RegisterVolumes();
%     set(handles.textBusy,'String','Not Busy');
% catch
%     set(handles.textBusy,'String','Failed');
% end
% 
% 
% 
% function [handles] = fractureCallus3PtBendBreak(handles,hObject)
% try
%     set(handles.textBusy,'String','Busy');
%     drawnow()
%     
%     
%     
%     handles.img(~handles.bwContour) = 0;
%     
%     %convert pixels to physical units when writing out
%     %do callus math
%     handles.bwTmp = false(size(handles.img));
%     handles.bwTmp(handles.img > handles.lowerThreshold) = 1;
%     [handles.imgDensity ~] = calculateDensityFromDICOM(handles.info,handles.img);
%     handles.imgDensity(~handles.bwTmp) = 0;
%     handles.callusMeanVolumetricDensity = mean(handles.imgDensity(handles.bwTmp));
%     handles.callusBoneVolume = length(find(handles.bwTmp));
%     handles.callusVolume = length(find(handles.bwContour));
%     handles.callusBoneVolumeFraction = length(find(handles.bwTmp)) / length(find(handles.bwContour));
%     
%     %get areas
%     handles.bwTmp = imclose(handles.bwTmp,true(15,15,15));
%     [a b c] = size(handles.bwTmp);
%     for i = 1:c
%         handles.bwTmp(:,:,i) = imfill(handles.bwTmp(:,:,i),'holes');
%         bwArea(i) = length(find(handles.bwTmp(:,:,i)));
%     end
%     minArea = min(bwArea);
%     maxArea = max(bwArea);
%     meanArea = mean(bwArea);
%     
%     %do cortical math
%     handles.imgDensity = calculateDensityFromDICOM(handles.info,handles.img);
%     handles.bwTmp = false(size(handles.img));
%     handles.bwTmp(handles.img > handles.upperThreshold) = 1;
%     handles.corticalTissueMineralDensity = mean(handles.imgDensity(handles.bwTmp));
%     handles.corticalBoneVolume = length(find(handles.bwTmp));
%     handles.corticalBoneVolumeFractionOfCallus = length(find(handles.bwTmp)) / length(find(handles.bwContour));
%     
%     handles.bwTrab = handles.bwContour;
%     handles.bwTrab(handles.bwTmp) = 0;
%     
%     imgTmp = handles.img;
%     imgTmp(handles.bwTmp) = 0;
%     [out,outHeader] = scancoParameterCalculatorCancellous(imgTmp > handles.lowerThreshold,handles.bwTrab,handles.img,handles.info,0);
%     
%     fid = fopen(fullfile(handles.pathstr,'FractureCallus3PtBendBreakResults.txt'),'a');
%     fprintf(fid,'%s\t','Date Analyzed');
%     fprintf(fid,'%s\t','Measurement');
%     fprintf(fid,'%s\t','Number of Slices');
%     fprintf(fid,'%s\t','Voxel Size');
%     
%     fprintf(fid,'%s\t','Callus Volume');
%     fprintf(fid,'%s\t','Callus Bone Volume');
%     fprintf(fid,'%s\t','Callus Bone Volume Fraction');
%     fprintf(fid,'%s\t','Callus Volumetric Bone Mineral Density');
%     fprintf(fid,'%s\t','Cortical Bone Volume');
%     fprintf(fid,'%s\t','Cortical Bone Volume Fraction of Callus');
%     fprintf(fid,'%s\t','Cortical Tissue Mineral Density');
%     fprintf(fid,'%s\t','Mean Callus Area');
%     fprintf(fid,'%s\t','Max Callus Area');
%     fprintf(fid,'%s\t','Min Callus Area');
%     for i = 2:length(outHeader)
%         if i ~= length(outHeader)
%             fprintf(fid,'%s\t',outHeader{i});
%         else
%             fprintf(fid,'%s\n',outHeader{i});
%         end
%     end
%     
%     
%     fprintf(fid,'%s\t',datestr(now));
%     fprintf(fid,'%s\t',handles.pathstr);
%     [a b c] = size(handles.img);
%     fprintf(fid,'%s\t',num2str((c)));
%     
%     fprintf(fid,'%s\t',num2str(handles.info.SliceThickness));
%     fprintf(fid,'%s\t',num2str(handles.callusVolume * handles.info.SliceThickness^3));
%     fprintf(fid,'%s\t',num2str(handles.callusBoneVolume * handles.info.SliceThickness^3));
%     fprintf(fid,'%s\t',num2str(handles.callusBoneVolumeFraction));
%     fprintf(fid,'%s\t',num2str(handles.callusMeanVolumetricDensity));
%     fprintf(fid,'%s\t',num2str(handles.corticalBoneVolume * handles.info.SliceThickness^3));
%     fprintf(fid,'%s\t',num2str(handles.corticalBoneVolumeFractionOfCallus));
%     fprintf(fid,'%s\t',num2str(handles.corticalTissueMineralDensity));
%     fprintf(fid,'%s\t',num2str(meanArea * handles.info.SliceThickness^2));
%     fprintf(fid,'%s\t',num2str(maxArea * handles.info.SliceThickness^2));
%     fprintf(fid,'%s\t',num2str(minArea * handles.info.SliceThickness^2));
%     for i = 2:length(out)
%         if i ~= length(out)
%             fprintf(fid,'%s\t',num2str(out{i}));
%         else
%             fprintf(fid,'%s\n',num2str(out{i}));
%         end
%     end
%     
%     fclose(fid);
%     
%     set(handles.textBusy,'String','Not Busy');
% catch
%     set(handles.textBusy,'String','Failed');
% end
% 
% function handles = loadTifStack(handles,hObject)
% try
%     set(handles.textBusy,'String','Busy');
%     drawnow();
%     pathstr = uigetdir(pwd,'Please select the folder containing your stack of TIF (or TIFF) images');
%     files = dir(fullfile(pathstr,'*.tif*'));
%     [file pth] = uigetfile('*.*', 'Select a DICOM file to use as a template or cancel to continue with dummy metadata');
%     if file ~= 0
%         info = dicominfo(fullfile(pth,file));
%     else
%         info.SliceThickness = 1;
%     end
%     handles.info = info;
%     
%     
%     if length(files) > 1
%         iminfo = imfinfo(fullfile(pathstr,files(1).name));
%         for i = 1:length(files)
%             handles.img(:,:,i) = imread(fullfile(pathstr,files(i).name));
%             set(handles.textPercentLoaded,'String',num2str(i/length(files)));
%             drawnow();
%         end
%     elseif length(files) == 1
%         iminfo = imfinfo(fullfile(pathstr,files(1).name));
%         numImages = numel(iminfo);
%         for i = 1:numImages
%             handles.img(:,:,i) = imread(fullfile(pathstr,files(1).name),i);
%             set(handles.textPercentLoaded,'String',num2str(i/numImages));
%             drawnow();
%         end
%     end
%     handles.img = uint16(handles.img);
%     handles.img = handles.img .* (((2^16) - 1)/((2^iminfo(1).BitDepth) - 1 ));
%     
%     handles.pathstr = pathstr;
%     
%     
%     
%     cameratoolbar('Show');
%     
%     handles.dataMax = max(max(max(handles.img)));
%     
%     handles.windowWidth = max(max(max(handles.img))) - min(min(min(handles.img)));
%     set(handles.editWindowWidth,'String',num2str(handles.windowWidth));
%     
%     handles.abc = size(handles.img);
%     
%     handles.windowLocation = round(handles.windowWidth / 2);
%     set(handles.editWindowLocation,'String',num2str(handles.windowLocation));
%     
%     set(handles.editScaleImageSize,'String',num2str(handles.imgScale));
%     
%     handles.primitiveCenter(1) = round(handles.abc(2)/2);
%     handles.primitiveCenter(2) = round(handles.abc(1)/2);
%     
%     set(handles.textCurrentDirectory,'String',handles.pathstr);
%     
%     handles.upperThreshold = max(max(max(handles.img)));
%     set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
%     
%     set(handles.sliderIMG,'Value',1);
%     set(handles.sliderIMG,'min',1);
%     set(handles.sliderIMG,'max',handles.abc(3));
%     set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
%     
%     handles.theMax = double(max(max(max(handles.img))));
%     handles.hOut = 1;%handles.theMax / 2^15;
%     handles.lOut = 0;
%     set(handles.sliderThreshold,'Value',1);
%     set(handles.sliderThreshold,'min',1);
%     set(handles.sliderThreshold,'max',handles.theMax);
%     set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
%     
%     set(handles.sliderWindowWidth,'Value',1);
%     set(handles.sliderWindowWidth,'min',1);
%     set(handles.sliderWindowWidth,'max',handles.theMax);
%     set(handles.sliderWindowWidth,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
%     
%     set(handles.sliderWindowLocation,'Value',1);
%     set(handles.sliderWindowLocation,'min',1);
%     set(handles.sliderWindowLocation,'max',handles.theMax);
%     set(handles.sliderWindowLocation,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
%     
%     % imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
%     set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
%     
%     set(gcf,'menubar','figure');
%     set(gcf,'toolbar','figure');
%     
%     set(handles.textBusy,'String','Not Busy');
%     
%     %         guidata(hObject, handles);
%     
% catch
%     set(handles.textBusy,'String','Failed');
% end
% 
% function [handles] = skeletonizationAnalysis(handles,hObject)
% try
%     set(handles.textBusy,'String','Busy');
%     drawnow();
%     
%     %generates uncorrected skeleton
%     handles.bwSkeleton = Skeleton3D(handles.bwContour);
%     [handles.A handles.node handles.link] = Skel2Graph3D(handles.bwSkeleton,str2num(get(handles.editRadius,'String')));
%     [w l h] = size(handles.bwSkeleton);
%     handles.bwSkeleton = Graph2Skel3D(handles.node,handles.link,w,l,h);
%     
%     hfig = figure;
%     set(hfig,'Visible','off')
%     shp = shpFromBW(handles.bwContour,2);
%     plot(shp,'FaceColor','w','FaceAlpha',0.3,'LineStyle','none');
%     camlight();
%     hold on;
%     handles.bwDist = bwdist(~handles.bwContour);
%     handles.bwDist(~handles.bwSkeleton) = 0;
%     handles = reduceDistanceMap(handles,hObject);
%     [r c v] = ind2sub(size(handles.bwDist),find(handles.bwDist));
%     xyzUlt = [r c v];
%     for i = 1:length(xyzUlt)
%         rads(i) = handles.bwDist(xyzUlt(i,1),xyzUlt(i,2),xyzUlt(i,3));%find xyz coords of the local maxima
%     end
%     [rads I] = sort(rads,'ascend');
%     xyzUlt = xyzUlt(I,:);
%     [x y z] = sphere();
%     Y = discretize(rads,64);
%     cmap = jet(64);
%     for i = 1:length(rads)
%         set(handles.textPercentLoaded,'String',num2str(i/length(rads)));
%         drawnow();
%         surf((x*rads(i)+xyzUlt(i,1)),(y*rads(i)+xyzUlt(i,2)),(z*rads(i)+xyzUlt(i,3)),'LineStyle','none','FaceColor',cmap(Y(i),:));
%         axis tight;
%         drawnow();
%     end
%     hold off;
%     saveas(hfig,fullfile(handles.pathstr,'SkeletonizedFigure.fig'));
%     
%     for i = 1:length(handles.link)
%         clear px py pz;
%         out(i).nodes = [handles.link(i).n1,handles.link(i).n2];
%         out(i).nodeLocs(1,:) = [handles.node(handles.link(i).n1).comx,handles.node(handles.link(i).n1).comy,handles.node(handles.link(i).n1).comz];
%         out(i).nodeLocs(2,:) = [handles.node(handles.link(i).n2).comx,handles.node(handles.link(i).n2).comy,handles.node(handles.link(i).n2).comz];
%         for k = 1:length(handles.link(i).point)
%             [px(k) py(k) pz(k)] = ind2sub(size(handles.bwSkeleton),handles.link(i).point(k));
%         end
%         out(i).points = [px' py' pz'];
%         for k = 1:length(out(i).points(:,1))
%             out(i).rads(k) = double(handles.bwDist(out(i).points(k,1),out(i).points(k,2),out(i).points(k,3)));
%         end
%         out(i).rads = out(i).rads(find(out(i).rads));
%         %convert to physical units
%         out(i).nodeLocs = out(i).nodeLocs .* handles.info.SliceThickness;
%         px = px  .* handles.info.SliceThickness;
%         py = py  .* handles.info.SliceThickness;
%         pz = pz  .* handles.info.SliceThickness;
%         out(i).points = out(i).points  .* handles.info.SliceThickness;
%         out(i).rads = out(i).rads  .* handles.info.SliceThickness;
%         %           %calculate length of snake
%         for k = 1:length(px)
%             if k == 1
%                 out(i).length = 0;
%             else
%                 out(i).length = out(i).length + sqrt((px(k) - px(k-1))^2 + (py(k) - py(k-1))^2 + (pz(k) - pz(k-1))^2);
%             end
%         end
%     end
%     
%     
%     
%     outHeader = {'File','Date','Nodes','Node Locations','Link Length','Mean Link Radius','STD Link Radius','Link Points'};
%     fid = fopen(fullfile(handles.pathstr,'SkeletonizationResults.txt'),'w');
%     for i = 1:length(outHeader)
%         if i ~= length(outHeader)
%             fprintf(fid,'%s\t',outHeader{i});
%         else
%             fprintf(fid,'%s\n',outHeader{i});
%         end
%     end
%     
%     for i = 1:length(out)
%         if ~isempty(out(i).rads)
%             fprintf(fid,'%s\t',handles.pathstr);
%             fprintf(fid,'%s\t',datestr(now));
%             fprintf(fid,'%s\t',[num2str(out(i).nodes(1)) ',' num2str(out(i).nodes(2))]);
%             for k = 1:length(out(i).nodeLocs(:,1))
%                 if k ~= length(out(i).nodeLocs(:,1))
%                     fprintf(fid,'%s',[num2str(out(i).nodeLocs(k,:)) ';']);
%                 else
%                     fprintf(fid,'%s\t',num2str(out(i).nodeLocs(k,:)));
%                 end
%             end
%             fprintf(fid,'%s\t',num2str(out(i).length));
%             fprintf(fid,'%s\t',num2str(mean(out(i).rads)));
%             fprintf(fid,'%s\t',num2str(std(out(i).rads)));
%             for k = 1:length(out(i).points)
%                 if k ~= length(out(i).points)
%                     fprintf(fid,'%s',[num2str(out(i).points(k,:)) ';']);
%                 else
%                     fprintf(fid,'%s\n',num2str(out(i).points(k,:)));
%                 end
%             end
%             
%         end
%     end
%     fclose(fid);
%     
%     
%     %         %corrects skeleton to join sections within a user-specified
%     %         %distance
%     %         handles.bwDist = bwdist(handles.bwContour);
%     %         handles.bwDist(handles.bwContour) = max(max(max(handles.bwDist)));
%     
%     
%     set(handles.textBusy,'String','Not Busy');
% catch
%     set(handles.textBusy,'String','Failed');
% end
% 
% function [handles] = distanceMap(handles,hObject)
% try
%     set(handles.textBusy,'String','Busy');
%     drawnow();
%     
%     handles.bwDist = bwdist(handles.bwContour);
%     handles.imgOrig = handles.img;
%     handles.img = uint16(handles.bwDist);
%     
%     set(handles.textBusy,'String','Not Busy');
% catch
%     set(handles.textBusy,'String','Failed');
% end
% 
% function writeToTiff(handles,hObject)
% try
%     set(handles.textBusy,'String','Busy');
%     drawnow();
%     mkdir(fullfile(handles.pathstr,[handles.DICOMPrefix 'TIF']));
%     zers = '000000';
%     [a b c] = size(handles.img);
%     for i = 1:c
%         slice = num2str(i);
%         len = length(slice);
%         set(handles.textPercentLoaded,'String',num2str(i/c));
%         drawnow();
%         pathTmp = fullfile(handles.pathstr,[handles.DICOMPrefix 'TIF']);
%         fName = [handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.tif'];
%         imwrite(handles.img(:,:,i),fullfile(pathTmp,fName));
%     end
%     set(handles.textBusy,'String','Not Busy');
% catch
%     set(handles.textBusy,'String','Failed');
% end
% 
% 
% function [handles] = reduceDistanceMap(handles,hObject)
% try
%     set(handles.textBusy,'String','Busy');
%     drawnow();
%     maxRad = max(max(max(handles.bwDist)));
%     
%     %pad array to account for radius
%     handles.bwDist = padarray(handles.bwDist,[double(2*ceil(maxRad)+2) double(2*ceil(maxRad)+2) double(2*ceil(maxRad)+2)]);
%     
%     initLen = length(find(handles.bwDist));
%     [x y z] = ind2sub(size(handles.bwDist),find(handles.bwDist));
%     [aa bb cc] = size(handles.bwDist);
%     handles.bwDistReshaped = reshape(handles.bwDist,[aa*bb*cc,1]);
%     [handles.bwDistSorted I]= sort(handles.bwDistReshaped,'descend');
%     [handles.bwDistSorted] = handles.bwDistSorted(find(handles.bwDistSorted));
%     [x2 y2 z2] = ind2sub(size(handles.bwDist),I(1:length(handles.bwDistSorted)));
%     
%     
%     for i = 1:length(x2)
%         if mod(i,50) == 0 || i == length(x2)
%             set(handles.textPercentLoaded,'String',num2str(i/length(x2)));
%             drawnow();
%         end
%         if handles.bwDist(x2(i),y2(i),z2(i)) > 0
%             
%             radToTest = handles.bwDist(x2(i),y2(i),z2(i));
%             
%             bw3 = false(size(handles.bwDist));
%             %                 bw3(x2(i),y2(i),z2(i)) = 1;
%             %                  bw3 = imdilate(bw3,true([2*ceil(maxRad)+1,2*ceil(maxRad)+1,2*ceil(maxRad)+1]));
%             bw3(((x2(i)-(2*ceil(maxRad)+1)):(x2(i)+(2*ceil(maxRad)+1))),...
%                 ((y2(i)-(2*ceil(maxRad)+1)):(y2(i)+(2*ceil(maxRad)+1))),...
%                 ((z2(i)-(2*ceil(maxRad)+1)):(z2(i)+(2*ceil(maxRad)+1)))) = 1;
%             [a1 b1 c1] = ind2sub(size(bw3),find(bw3));
%             
%             radsTesting = handles.bwDist(bw3);
%             
%             ds = sqrt((a1-x2(i)).^2 + (b1-y2(i)).^2 + (c1-z2(i)).^2);%location of cube - location of radius
%             rirj = radToTest + radsTesting;
%             
%             inds = rirj >= ds;% find spheres that intersect
%             [thisMax I] = max(radsTesting(inds));
%             inds = [a1(inds),b1(inds),c1(inds)];
%             if radToTest >= thisMax
%                 inds2 = inds == [x2(i),y2(i),z2(i)];
%                 for j = 1:length(inds2)
%                     if inds2(j,1) == 1 && inds2(j,2) == 1 && inds2(j,3) == 1
%                         inds(j,:) = [];
%                     end
%                 end
%             else
%                 inds(I,:) = [];
%             end
%             for j = 1:length(inds)
%                 handles.bwDist(inds(j,1),inds(j,2),inds(j,3)) = 0;
%             end
%             
%         end
%         
%     end
%     
%     %remove padding
%     handles.bwDist = handles.bwDist((2*ceil(maxRad)+2):end-(2*ceil(maxRad)+2),...
%         (2*ceil(maxRad)+2):end-(2*ceil(maxRad)+2),...
%         (2*ceil(maxRad)+2):end-(2*ceil(maxRad)+2));
%     
%     set(handles.textBusy,'String','Not Busy');
% catch
%     set(handles.textBusy,'String','Failed');
% end
% 
% 
% % --- Executes on selection change in popupmenuMaskComponents.
% function popupmenuMaskComponents_Callback(hObject, eventdata, handles)
% % hObject    handle to popupmenuMaskComponents (see GCBO)
% 
% 
% 
% % Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMaskComponents contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from popupmenuMaskComponents
% 
% 
% % --- Executes during object creation, after setting all properties.
% function popupmenuMaskComponents_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to popupmenuMaskComponents (see GCBO)
% 
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: popupmenu controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 
% 
% % --- Executes on button press in pushbuttonPopulateMaskComponents.
% function pushbuttonPopulateMaskComponents_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbuttonPopulateMaskComponents (see GCBO)
% 
% 
% try
%     set(handles.textBusy,'String','Busy');
%     handles.cc = bwconncomp(handles.bwContour);
%     for i = 1:length(handles.cc.PixelIdxList)
%         connCompInd{i} = num2str(i);
%         set(handles.textPercentLoaded,'String',num2str(i/length(handles.cc.PixelIdxList)));
%         drawnow();
%     end
%     set(handles.popupmenuMaskComponents,'String',connCompInd);
%     set(handles.textBusy,'String','Not Busy');
%     guidata(hObject, handles);
% catch
%     set(handles.textBusy,'String','Failed');
% end
% 
% function writeCurrentImageStackToDICOM(handles,hObject)
% 
% try
%     set(handles.textBusy,'String','Busy');
%     guidata(hObject, handles);
%     drawnow();
%     [a b c] = size(handles.img);
%     
%     zers = '00000';
%     handles.info.Rows = a;
%     handles.info.Columns = b;
%     handles.info.InstitutionName = 'Washington University in St. Louis';
%     handles.info.SliceThickness = handles.info.SliceThickness / handles.imgScale;
%     handles.info.Height = a;
%     handles.info.Width = b;
%     handles.info.PixelSpacing = [handles.info.SliceThickness;handles.info.SliceThickness];
%     handles.info.PixelSpacing = handles.info.PixelSpacing .* handles.imgScale;
%     handles.info.StudyDescription = handles.DICOMPrefix;
%     
%     
%     %for ZEISS scans
%     if ~isempty(strfind(handles.info.Manufacturer,'Zeiss'))
%         mkdir(fullfile(handles.pathstr, handles.DICOMPrefix));
%         tmpDir = fullfile(handles.pathstr,handles.DICOMPrefix);
%         tmp = dicominfo(fullfile(pwd,'ZeissDICOMTemplate.dcm'));%read info from a known working Zeiss DICOM
%         tmp2 = tmp;
%         for i = 1:c
%             tmp2.FileName = [handles.DICOMPrefix zers(1:end - length(num2str(i))) num2str(i) '.dcm'];
%             tmp2.Rows = handles.info.Rows;
%             tmp2.Columns = handles.info.Columns;
%             tmp2.InstitutionName = handles.info.InstitutionName;
%             tmp2.SliceThickness = handles.info.SliceThickness;
%             tmp2.Height = handles.info.Height;
%             tmp2.Width = handles.info.Width;
%             tmp2.PixelSpacing = handles.info.PixelSpacing;
%             tmp2.StudyDescription = handles.info.StudyDescription;
%             tmp2.KVP = handles.info.KVP;
%             zers2 = '000000';
%             slice = num2str(i);
%             len = length(slice);
%             tmp2.MediaStorageSOPInstanceUID = ['1.2.826.0.1.3680043.8.435.3015486693.35541.' zers(1:end-len) num2str(i)];
%             tmp2.SOPInstanceUID = tmp2.MediaStorageSOPInstanceUID;
%             tmp2.PatientName.FamilyName = handles.DICOMPrefix;
%             tmp2.ImagePositionPatient(3) = tmp2.ImagePositionPatient(3) + tmp2.SliceThickness;
%             set(handles.textPercentLoaded,'String',num2str(i/c));
%             drawnow();
%             fName = [handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.dcm'];
%             dicomwrite(handles.img(:,:,i),fullfile(tmpDir,fName),tmp2);
%         end
%     elseif ~isempty(strfind(handles.info.Manufacturer,'SCANCO'))
%         mkdir(fullfile(handles.pathstr,handles.DICOMPrefix));
%         tmpDir = fullfile(handles.pathstr,handles.DICOMPrefix);
%         %sort out info struct for writing; dicomwrite won't write private fields
%         tmp = handles.info;
%         if isfield(tmp,'Private_0029_1000')%identifies as Scanco original DICOM file
%             handles.info.ReferringPhysicianName.FamilyName = num2str(tmp.Private_0029_1004);%will be slope for density conversion
%             handles.info.ReferringPhysicianName.GivenName = num2str(tmp.Private_0029_1005);%intercept
%             handles.info.ReferringPhysicianName.MiddleName = num2str(tmp.Private_0029_1000);%scaling
%             handles.info.ReferringPhysicianName.NamePrefix = num2str(tmp.Private_0029_1006);%u of water
%         end
%         for i = 1:c
%             if i == 1
%                 info = handles.info;
%                 info.FileName = fullfile(handles.pathstr,[handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i) '.dcm']);
%             else
%                 info.SliceLocation = info.SliceLocation + info.SliceThickness;
%                 info.ImagePositionPatient = info.ImagePositionPatient + info.SliceThickness;
%                 info.FileName = fullfile(handles.pathstr,[handles.DICOMPrefix zers(1:end-length(num2str(i))) num2str(i)  '.dcm']);
%                 %         info.MediaStorageSOPInstanceUID = num2str(str2num(info.MediaStorageSOPInstanceUID) + 1);
%                 %         info.SOPInstanceUID = num2str(str2num(info.SOPInstanceUID) + 1);
%                 
%             end
%             set(handles.textPercentLoaded,'String',num2str(i/c));
%             drawnow();
%             fName = [handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.dcm'];
%             dicomwrite(handles.img(:,:,i),fullfile(tmpDir,fName),info);
%         end
%     else
%         mkdir(fullfile(handles.pathstr,handles.DICOMPrefix))
%         tmpDir = fullfile(handles.pathstr,handles.DICOMPrefix);
%         %sort out info struct for writing; dicomwrite won't write private fields
%         tmp = handles.info;
%         for i = 1:c
%             if i == 1
%                 info = handles.info;
%                 info.SliceLocation = 1;
%                 info.FileName = fullfile(handles.pathstr,[handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i) '.dcm']);
%             else
%                 info.SliceLocation = info.SliceLocation + info.SliceThickness;
%                 info.ImagePositionPatient = info.ImagePositionPatient + info.SliceThickness;
%                 info.FileName = fullfile(handles.pathstr,[handles.DICOMPrefix zers(1:end-length(num2str(i))) num2str(i)  '.dcm']);
%                 %         info.MediaStorageSOPInstanceUID = num2str(str2num(info.MediaStorageSOPInstanceUID) + 1);
%                 %         info.SOPInstanceUID = num2str(str2num(info.SOPInstanceUID) + 1);
%                 
%             end
%             set(handles.textPercentLoaded,'String',num2str(i/c));
%             drawnow();
%             fName = [handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.dcm'];
%             dicomwrite(handles.img(:,:,i),fullfile(tmpDir,fName),info);
%         end
%         
%     end
%     set(handles.textBusy,'String','Not Busy');
%     guidata(hObject, handles);
%     drawnow();
% catch
%     set(handles.textBusy,'String','Failed');
%     guidata(hObject, handles);
%     drawnow();
% end
% 
% 
% function saveCurrentImage(handles,hObject)
% 
% try
%     set(handles.textBusy,'String','Busy');
%     guidata(hObject, handles);
%     drawnow();
%     outFile = fullfile(handles.pathstr,[get(handles.editDICOMPrefix,'String') '.tif']);
%     imwrite(getimage(handles.axesIMG),outFile);
%     set(handles.textBusy,'String','Not Busy');
%     guidata(hObject, handles);
%     drawnow();
% catch
%     set(handles.textBusy,'String','Failed');
%     guidata(hObject, handles);
%     drawnow();
% end
% 
% function generateHistogram(handles,hObject)
% 
% try
%     set(handles.textBusy,'String','Busy');
%     guidata(hObject, handles);
%     drawnow();
%     [a b c] = size(handles.img);
%     img = reshape(handles.img,[1,a*b*c]);
%     figure;
%     histogram(img(find(img > 0)),320);
%     set(handles.textBusy,'String','Not Busy');
%     guidata(hObject, handles);
%     drawnow();
% catch
%     set(handles.textBusy,'String','Failed');
%     guidata(hObject, handles);
%     drawnow();
% end
% 
% 
% % --- Executes on button press in pushbuttonSetMaskByClicking.
% function pushbuttonSetMaskByClicking_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbuttonSetMaskByClicking (see GCBO)
% 
% 
% try
%     set(handles.textBusy,'String','Busy');
%     guidata(hObject, handles);
%     drawnow();
%     [x y] = getpts(handles.axesIMG);
%     z(1:length(x),1) = handles.slice;
%     pt = round([y x z]);%points to use to select mask component
%     cc = bwconncomp(handles.bwContour);
%     removeFlag = zeros(length(cc.PixelIdxList),length(pt(:,1)));
%     for i = 1:length(cc.PixelIdxList)
%         [idxx idxy idxz] = ind2sub(size(handles.bwContour),cc.PixelIdxList{i});
%         idx = [idxx idxy idxz];
%         for k = 1:length(pt(:,1))
%             if length(find(ismember(pt(k,:),idx,'rows'))) == 0
%                 removeFlag(i,k) = 1;
%             end
%         end
%         set(handles.textPercentLoaded,'String',num2str(i/length(cc.PixelIdxList)));
%         drawnow();
%     end
%     
%     for i = 1:length(removeFlag)
%         if sum(removeFlag(i,:)) == length(removeFlag(i,:))
%             handles.bwContour(cc.PixelIdxList{i}) = 0;
%         end
%     end
%     
%     UpdateImage(hObject,eventdata,handles);
%     
%     set(handles.textBusy,'String','Not Busy');
%     guidata(hObject, handles);
%     drawnow();
%     
% catch
%     set(handles.textBusy,'String','Failed');
%     guidata(hObject, handles);
%     drawnow();
% end
% 
% 
% % --- Executes on button press in pushbuttonLoadISQ.
% function pushbuttonLoadISQ_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbuttonLoadISQ (see GCBO)
% 
% 
% try
%     set(handles.textBusy,'String','Busy');
%     if isfield(handles,'img') == 1
%         clear handles.img;
%     end
%     if isfield(handles,'bwContour') == 1
%         clear handles.bwContour;handles=rmfield(handles,'bwContour');
%     end
%     
%     isqName = copyIsqToWorkingDirectory();
%     [handles.img,handles.info] = readScancoISQ(fullfile(pwd,isqName));
%     
%     cameratoolbar('Show');
%     handles.dataMax = max(max(max(handles.img)));
%     
%     handles.windowWidth = max(max(max(handles.img))) - min(min(min(handles.img)));
%     set(handles.editWindowWidth,'String',num2str(handles.windowWidth));
%     
%     handles.abc = size(handles.img);
%     
%     handles.windowLocation = round(handles.windowWidth / 2);
%     set(handles.editWindowLocation,'String',num2str(handles.windowLocation));
%     
%     set(handles.editScaleImageSize,'String',num2str(handles.imgScale));
%     
%     handles.primitiveCenter(1) = round(handles.abc(2)/2);
%     handles.primitiveCenter(2) = round(handles.abc(1)/2);
%     % handles.bwContour = false(size(handles.img));
%     % handles.bwContourOrig = handles.bwContour;
%     try
%         set(handles.textCurrentDirectory,'String',handles.pathstr);
%     catch
%         handles.pathstr = pwd;
%         set(handles.textCurrentDirectory,'String',handles.pathstr);
%     end
%     
%     handles.upperThreshold = max(max(max(handles.img)));
%     set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
%     
%     set(handles.sliderIMG,'Value',1);
%     set(handles.sliderIMG,'min',1);
%     set(handles.sliderIMG,'max',handles.abc(3));
%     set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
%     
%     handles.theMax = double(max(max(max(handles.img))));
%     handles.hOut = 1;%handles.theMax / 2^15;
%     handles.lOut = 0;
%     set(handles.sliderThreshold,'Value',1);
%     set(handles.sliderThreshold,'min',1);
%     set(handles.sliderThreshold,'max',handles.theMax);
%     set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
%     
%     set(handles.sliderWindowWidth,'Value',1);
%     set(handles.sliderWindowWidth,'min',1);
%     set(handles.sliderWindowWidth,'max',handles.theMax);
%     set(handles.sliderWindowWidth,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
%     
%     set(handles.sliderWindowLocation,'Value',1);
%     set(handles.sliderWindowLocation,'min',1);
%     set(handles.sliderWindowLocation,'max',handles.theMax);
%     set(handles.sliderWindowLocation,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
%     
%     % imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
%     set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
%     UpdateImage(hObject,eventdata,handles);
%     
%     set(gcf,'menubar','figure');
%     set(gcf,'toolbar','figure');
%     set(handles.textBusy,'String','Not Busy');
%     
%     guidata(hObject, handles);
% catch
%     set(handles.textBusy,'String','Failed');
% end
% 
% guidata(hObject, handles);
% 
% function [isqName] = copyIsqToWorkingDirectory()
% 
% pat = pwd;
% answer = inputdlg('Please input the IP address for your Scanco server (ex. 10.21.24.204)');
% ip = answer{1};
% answer = inputdlg('Please input the user name for your Scanco server');
% user = answer{1};
% answer = inputdlg('Please input the password for your Scanco server');
% password = answer{1};
% answer = inputdlg('Please input the sample number you are interested in');
% sample = answer{1};
% answer = inputdlg('Please input the measurement number you are interested in');
% measurement = answer{1};
% 
% f = ftp(ip,user,password);
% cd(f,'dk0');
% cd(f,'data');
% zers = '00000000';
% samp = [zers(1:length(zers)-length(sample)) sample];
% cd(f,samp);
% meas = [zers(1:length(zers)-length(measurement)) measurement];
% cd(f,meas);
% 
% isq = dir(f,'*.isq*');
% isqPath = ['dk0:[microct.data.' samp '.' meas ']' isq.name];
% 
% binary(f);
% try
%     mget(f,isq.name,pat);
% catch
% end
% isqName = isq.name;
% close(f);
% 
% function saveMasksAsLabelMatrix(handles,hObject)
% names = fieldnames(handles);
% pathstr = fullfile(handles.pathstr,'labelImage.tif');
% [a b c] = size(handles.img);
% labels = zeros(a,b,c,'uint8');
% for i = 1:length(names)
%     if strcmp(names(i),'one') == 1
%         labels(handles.one) = 1;
%     elseif strcmp(names(i),'two') == 1
%         labels(handles.two) = 2;
%     elseif strcmp(names(i),'three') == 1
%         labels(handles.three) = 3;
%     elseif strcmp(names(i),'four') == 1
%         labels(handles.four) = 4;
%     elseif strcmp(names(i),'five') == 1
%         labels(handles.five) = 5;
%     end
% end
% % imwrite(labels,pathstr);
% saveastiff(labels,pathstr);
% 
% function yMaxForStrain(handles,hObject)
% 
% [a b c] = size(handles.bwContour);    
% for i = 1:c
%     % Find position of Centroid
%     [I J] = find(handles.bwContour(:,:,i) > 0);
%     % I = I .* pixelwidth; %mm (pixels * mm/pixels)
%     % J = J .* pixelwidth; %mm
%     ycent = mean(I(:));
%     xcent = mean(J(:));
% 
%     tmp = zeros(size(handles.bwContour(:,:,i)));
%     tmp(handles.bwContour(:,:,i)) = 2;
%     tmp(~handles.bwContour(:,:,i)) = 1;
%     h = figure; imagesc(tmp);
%     [x,y] = ginput(2);
% 
%     d1 = abs(y(1)-ycent);
%     d2 = abs(y(2)-ycent);
% 
%     d1 = d1 * handles.info.SliceThickness;
%     d2 = d2 * handles.info.SliceThickness;
% 
%     msgbox(['D1 for slice ' num2str(i) ' is ' num2str(d1)]);
%     msgbox(['D2 for slice ' num2str(i) ' is ' num2str(d2)]);
%     
%     close(h);
%     
% end
% 
% function craftHumanCorticalAnalysis(handles,hObject)
%     try
%         set(handles.textBusy,'String','Busy');
%         guidata(hObject, handles);
%         drawnow();
%         [handles.outCortical,handles.outHeaderCortical] = scancoParameterCalculatorCortical(handles.img,handles.bwContour,handles.info,handles.threshold,get(handles.togglebuttonRobustThickness,'Value'));
% %         [twoDHeader twoDData] = twoDAnalysisSub(handles.img,handles.info,handles.lowerThreshold);
%         if exist(fullfile(handles.pathstr,'CorticalResults.txt'),'file') ~= 2
%             fid = fopen(fullfile(handles.pathstr,'CorticalResults.txt'),'a');
%             for i = 1:length(handles.outHeaderCortical)
%                 if i == length(handles.outHeaderCortical)
%                     fprintf(fid,'%s\t',handles.outHeaderCortical{i});
%                     fprintf(fid,'%s\n','pMOI (mm)');
%                 else
%                     fprintf(fid,'%s\t',handles.outHeaderCortical{i});
%                 end
%             end
%             %             fprintf(fid,'%s\n','Lower Threshold');
%         end
%         fid = fopen(fullfile(handles.pathstr,'CorticalResults.txt'),'a');
%         for i = 1:length(handles.outCortical)
%             if ~ischar(handles.outCortical{i})
%                 if i == length(handles.outCortical)
%                     fprintf(fid,'%s\t',num2str(handles.outCortical{i}));
% %                     fprintf(fid,'%s\n',num2str(twoDData(2) + twoDData(3)));
%                 else
%                     fprintf(fid,'%s\t',num2str(handles.outCortical{i}));
%                 end
%             else
%                 if i == length(handles.outCortical)
%                     fprintf(fid,'%s\t',handles.outCortical{i});
% %                     fprintf(fid,'%s\n',num2str(twoDData(2) + twoDData(3)));
%                 else
%                     fprintf(fid,'%s\t',handles.outCortical{i});
%                 end
%             end
%         end
%         fclose(fid);
%         guidata(hObject, handles);
%         set(handles.textBusy,'String','Not Busy');
%     catch
%         set(handles.textBusy,'String','Failed');
%     end
% 
% function thicknessVisualization(handles,hObject)
% 
% bw = handles.bwContour;
% D1 = bwdist(~bw);%does what I want for thickness of spacing
% bwUlt = bwulterode(bw);
% D1(~bwUlt) = 0;
% 
% maxRad = ceil(max(max(max(double(D1)))));
% D1 = padarray(D1,[ceil(maxRad)+1 ceil(maxRad)+1 ceil(maxRad)+1]);
% 
% [aa bb cc] = size(D1);
% [a b c] = size(bw);
% 
% initLen = length(find(D1));
% [x y z] = ind2sub(size(D1),find(D1));
% D1Reshaped = reshape(D1,[aa*bb*cc,1]);
% [D1Sorted I]= sort(D1Reshaped,'descend');
% [D1Sorted] = find(D1Sorted);
% [x2 y2 z2] = ind2sub(size(D1),I(1:length(D1Sorted)));
% 
% tic
% for i = 1:length(x2)
%     if mod(i,500) == 0
% %         clc
%         set(handles.textPercentLoaded,'String',num2str(i/initLen));
%         drawnow()
%     end
%     if D1(x2(i),y2(i),z2(i)) > 0
% 
%         radToTest = D1(x2(i),y2(i),z2(i));
% 
%         bw3 = false(size(D1));
%         bw3(x2(i),y2(i),z2(i)) = 1;
%         bw3 = imdilate(bw3,true([2*ceil(maxRad)+1,2*ceil(maxRad)+1,2*ceil(maxRad)+1]));
%         [a1 b1 c1] = ind2sub(size(bw3),find(bw3));
%         
%         radsTesting = D1(bw3);
% 
%         ds = sqrt((a1-x2(i)).^2 + (b1-y2(i)).^2 + (c1-z2(i)).^2);%location of cube - location of radius
%         rirj = radToTest + radsTesting;
% 
%         inds = rirj >= ds;% find spheres that intersect
%         [thisMax I] = max(radsTesting(inds));
%         inds = [a1(inds),b1(inds),c1(inds)];
%         if radToTest >= thisMax
%             inds2 = inds == [x2(i),y2(i),z2(i)];
%             for j = 1:length(inds2)
%                 if inds2(j,1) == 1 && inds2(j,2) == 1 && inds2(j,3) == 1
%                     inds(j,:) = [];
%                 end
%             end
%         else
%             inds(I,:) = [];
%         end
%         for j = 1:length(inds)
%             D1(inds(j,1),inds(j,2),inds(j,3)) = 0;
%         end
%     end
%     
% end
% toc 
% 
% shp = shpFromBW(bw,3);
% figure;
% plot(shp,'FaceColor','w','LineStyle','none');
% alpha(gca,0.4);
% camlight;
% hold on;
% [x y z] = sphere;
% [x2 y2 z2] = ind2sub(size(D1),find(D1));
% rads = D1(find(D1));
% rangeRads = max(rads) - min(rads);
% binRads = rangeRads / 256;
% if rangeRads == 0
%     bin(1) = 0;
%     bin(2) = max(rads);
%     trans = [1 1];
% else
%     for i = 1:255
%         bin(i) = binRads * i;
%         trans(i) = i/255;
%     end
% end
% if length(bin) > 256
%     map = colormap(jet(256));
% else
%     map = colormap(jet(length(bin)));
% end
% for i = 1:length(find(D1))
%     for j = 2:length(bin)
%         if rads(i) > bin(j-1) && rads(i) <= bin(j)
%             surf(x*rads(i)+x2(i)-maxRad,y*rads(i)+y2(i)-maxRad,z*rads(i)+z2(i)-maxRad,'FaceColor',map(j-1,:),'FaceAlpha',trans(j),'LineStyle','none');
%             axis tight;
%             drawnow();
%         end
%     end
% end
% saveas(gcf,fullfile(handles.pathstr,[get(handles.editDICOMPrefix,'String') '.fig']));
% 
% function [handles] = humanCoreTrabecularThickness(handles,hObject)
% 
% try
%     set(handles.textBusy,'String','Busy');
%     guidata(hObject, handles);
%     drawnow();
%     bw = false(size(handles.img));
%     bw(find(handles.img > handles.lowerThreshold)) = 1;
%     bw(find(handles.img > handles.upperThreshold)) = 0;
%     bw = bwareaopen(bw,150);
% 
%     [handles.outCancellous,handles.outHeaderCancellous] = scancoParameterCalculatorCancellous(bw,handles.bwContour,handles.img,handles.info,get(handles.togglebuttonRobustThickness,'Value'));
%     if exist(fullfile(handles.pathstr,'CancellousResults.txt'),'file') ~= 2
%         fid = fopen(fullfile(handles.pathstr,'CancellousResults.txt'),'w');
%         for i = 1:length(handles.outCancellous)
%             if i == length(handles.outCancellous)
%                 fprintf(fid,'%s\t',handles.outHeaderCancellous{i});
% 
%             else
%                 fprintf(fid,'%s\t',handles.outHeaderCancellous{i});
%             end
%         end
%         fprintf(fid,'%s\n','Threshold');
%         fclose(fid);
%     end
%     for i = 1:length(handles.outCancellous)
%         fid = fopen(fullfile(handles.pathstr,'CancellousResults.txt'),'a');
%         if i == length(handles.outCancellous)
%             fprintf(fid,'%s\t',num2str(handles.outCancellous{i}));
%             fprintf(fid,'%s\n',num2str(handles.lowerThreshold));
%         else
%             fprintf(fid,'%s\t',num2str(handles.outCancellous{i}));
%         end
%     end
%     fclose(fid);
%     guidata(hObject, handles);
%     set(handles.textBusy,'String','Not Busy');
% catch
%     set(handles.textBusy,'String','Failed');
% end
% 
% function [handles] = scancoParameterStressFractureCallus(handles,hObject)
% 
% try
%     set(handles.textBusy,'String','Busy');
%     guidata(hObject, handles);
%     drawnow();
%     [out, outHeader] = scancoParameterCalculatorStressFractureCallus(handles.bwContour,handles.lowerThreshold,handles.img,handles.info);
%     if exist(fullfile(handles.pathstr,'StressFractureCallusResults.txt'),'file') ~= 2
%         fid = fopen(fullfile(handles.pathstr,'StressFractureCallusResults.txt'),'a');
%         for i = 1:length(outHeader)
%             if i == length(outHeader)
%                 fprintf(fid,'%s\n',outHeader{i});
%             else
%                 fprintf(fid,'%s\t',outHeader{i});
%             end
%         end
%     end
%     fid = fopen(fullfile(handles.pathstr,'StressFractureCallusResults.txt'),'a');
%     fprintf(fid,'%s\t',handles.pathstr);
%     fprintf(fid,'%s\t',datestr(now));
%     for i = 1:length(out)
%         if i == length(out)
%             fprintf(fid,'%s\n',num2str(out{i}));
%         else
%             fprintf(fid,'%s\t',num2str(out{i}));
%         end
%     end
%     for i = 1:5
%         try
%             fclose(fid);
%         catch
%         end
%     end
%     guidata(hObject, handles);
%     set(handles.textBusy,'String','Not Busy')
% catch
%     set(handles.textBusy,'String','Failed');
% end
%     
% function [handles] = alignAboutWideAxis(handles,hObject)
% 
% try
%     set(handles.textBusy,'String','Busy')
%     guidata(hObject, handles);
%     drawnow();
%     answer = inputdlg("Would you like to use only a portion of the images for determining the rotation? y/n");
%     if strcmpi(answer{1},'y') == 1
%         answer = inputdlg("Please enter the first slice to use");
%         first = str2num(answer{1});
%         answer = inputdlg("Please enter the last slice to use");
%         last = str2num(answer{1});
%         img = handles.img(:,:,first:last);
%         degree = rotateWidestHorizontal(img, handles.bwContour);    
%         clear img;
%     else
%         degree = rotateWidestHorizontal(handles.img, handles.bwContour);    
%     end
%     [a b c] = size(handles.img);
%     for i = 1:c
%         imgTmp(:,:,i) = imrotate(handles.img(:,:,i),degree);
%         bwContourTmp(:,:,i) = imrotate(handles.bwContour(:,:,i),degree);
%     end
%     handles.img = imgTmp;
%     handles.bwContour = bwContourTmp;
%     guidata(hObject, handles);
%     set(handles.textBusy,'String','Not Busy')
% catch
%     set(handles.textBusy,'String','Failed');
% end
% 
% 
% 
%     
%     
