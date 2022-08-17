% NAME-LoadWorkspace
% DESC-Loads a workspace state that was previously saved from a data file
% IN-*.mat: a file containing saved handles fields
% OUT-handles: loads the handles fields from the file
function [hObject,eventdata,handles] = LoadWorkspace(hObject,eventdata,handles)
    try
        setStatus(hObject, handles, 'Busy');
        % Open a dialog to select the file
        if isfield(handles, 'pathstr')
            [file, pathstr] = uigetfile(handles.pathstr, 'Select the workspace file to load'); % look in folder in pathstring
        else
            [file, pathstr] = uigetfile(pwd, 'Select the workspace file to load'); % pwd=look in current folder
        end
        fieldNames = fieldnames(handles);
        fieldNum = numel(fieldnames(handles));
        % Remove all non-graphics fields
        for i = 1:fieldNum
            if ~any(isgraphics(handles.(fieldNames{i}))) | isequal(handles.(fieldNames{i}), 0) %#ok<OR2> % 0 is considered a graphics object by isgraphics
                handles = rmfield(handles, fieldNames{i});
            end
            displayPercentLoaded(hObject, handles, i/fieldNum);
        end
        % Load the file and copy all loaded fields to handles
        s = load(fullfile(pathstr,file));
        fieldNames = fieldnames(s);
        fieldNum = numel(fieldnames(s));
        for i = 1:fieldNum
            handles.(fieldNames{i}) = s.(fieldNames{i});
            displayPercentLoaded(hObject, handles, i/fieldNum);
        end
        
        set(handles.textCurrentDirectory,'String', handles.pathstr);

        % Set all UI components to match the values in the model
        % Translation
        setNumberTextbox(handles,'editTranslateUp', 'translateUp');
        setNumberTextbox(handles,'editTranslateDown', 'translateDown');
        setNumberTextbox(handles,'editTranslateLeft', 'translateLeft');
        setNumberTextbox(handles,'editTranslateRight', 'translateRight');
        % Threshold
        setNumberTextbox(handles,'textLowerThreshold', 'lowerThreshold');
        setNumberTextbox(handles,'textUpperThreshold', 'upperThreshold');
        setNumberTextbox(handles,'editThreshold', 'threshold');
        % Primitive Creation
        setNumberTextbox(handles, 'editPrimitiveHeight', 'primitiveHeight');
        setNumberTextbox(handles, 'editPrimitiveWidth', 'primitiveWidth');
        setNumberTextbox(handles, 'editRotatePrimitive', 'primitiveRotationAngle');
        setNumberTextbox(handles, 'editPrimitiveHorizontal', 'primitiveHorizontal');
        setNumberTextbox(handles, 'editPrimitiveVertical', 'primitiveVertical');
        setPopup(handles, 'popupMenuPrimitive', 'primitiveShape');
        % Morphological Filters
        setNumberTextbox(handles, 'editSigma', 'sigma');
        setNumberTextbox(handles, 'editRadius', 'radius');
        setPopup(handles, 'popupmenuFilter', 'filter');
        % Analysis
        setPopup(handles, 'popupmenuAnalysis', 'analysis')
        setStringTextbox(handles, 'editDICOMPrefix', 'DICOMPrefix');
        % STL Files
        setNumberTextbox(handles, 'editSphereSizeForAlphaShape', 'sphereSize');
        setPopup(handles, 'popupmenuSTLAsciiBinary', 'stlWriteMethod');
        setPopup(handles, 'popupmenuSetColorMap', 'colormap');
        % Morph range
        setNumberTextbox(handles, 'editStartMorph', 'startMorph');
        setNumberTextbox(handles, 'editEndMorph', 'endMorph');
        % Morphological Operations
        setNumberTextbox(handles, 'editMorphologicalRadius', 'morphologicalRadius');
        setPopup(handles, 'popupmenuMorphologicalOperation', 'morphologicalOperation');
        setPopup(handles, 'popupmenu2D3D', 'morphological2D3D');
        setPopup(handles, 'popupmenuImageMask', 'morphologicalImageMask');
        % Contouring
        setNumberTextbox(handles, 'editSmoothFactor', 'smoothFactor');
        setNumberTextbox(handles, 'editContractionBias', 'contractionBias');
        setNumberTextbox(handles, 'editIterations', 'iterations');
        setPopup(handles, 'popupmenuContourMethod', 'contourMethod');
        % Window
        setNumberTextbox(handles, 'editWindowWidth', 'windowWidth');
        setNumberTextbox(handles, 'editWindowLocation', 'windowLocation');
        % Sliders
        if isfield(handles, 'img')
            handles.sliderThreshold = resizeSlider(handles.sliderThreshold, 1, handles.theMax, 1, handles.theMax/1000); 
            handles.sliderWindowWidth = resizeSlider(handles.sliderWindowWidth, 1, handles.theMax, 1, handles.theMax/1000); 
            handles.sliderWindowLocation = resizeSlider(handles.sliderWindowLocation, 1, handles.theMax, 1, handles.theMax/1000);
            handles.sliderIMG = resizeSlider(handles.sliderIMG, handles.abc(3));
        else
            handles.sliderThreshold = resizeSlider(handles.SliderThreshold, 0, 1, 0, 0); 
            handles.aliderWindowWidth = resizeSlider(handles.sliderWindowWidth, 0, 1, 0, 0); 
            handles.aliderWindowLocation = resizeSlider(handles.sliderWindowLocation, 0, 1, 0, 0);
            handles.sliderIMG = resizeSlider(handles.sliderIMG, 0, 1, 0, 0);
        end
        setSlider(handles, 'sliderWindowWidth', 'windowWidth');
        setSlider(handles, 'sliderWindowLocation', 'windowLocation');
        setSlider(handles, 'sliderThreshold', 'threshold')
        setSlider(handles, 'sliderIMG', 'slice');
        % Others        
        setNumberTextbox(handles, 'editRotationDegrees', 'rotateDegrees');
        setNumberTextbox(handles, 'editSpeckleSize', 'speckleSize');
        setNumberTextbox(handles, 'editScaleImageSize', 'imgScale');
        setStringTextbox(handles, 'editMaskName','maskName');
        setNumberTextbox(handles, 'editSliceNumber', 'slice');
        % Mapped popup menus
        if isfield(handles, 'rotateAxis')
            switch handles.rotateAxis
                case 1 % X
                    set(handles.popupmenuContourMethod, 'Value', 2);
                case 2 % Y
                    set(handles.popupmenuContourMethod, 'Value', 1);
                case 3 % Z
                    set(handles.popupmenuContourMethod, 'Value', 3);
            end
        end
        if isfield(handles, 'STLColor')
            if isequal(handles.STLColor, [255 0 0]) % Red
                set(handles.popupmenuSTLColor, 'Value', 1);
            elseif isequal(handles.STLColor, [0 255 0]) % Green
                set(handles.popupmenuSTLColor, 'Value', 2);
            elseif isequal(handles.STLColor, [0 0 255]) % Blue
                set(handles.popupmenuSTLColor, 'Value', 3);
            elseif isequal(handles.STLColor, [0 255 255]) % Cyan
                set(handles.popupmenuSTLColor, 'Value', 4);
            elseif isequal(handles.STLColor, [255 0 255]) % Magenta
                set(handles.popupmenuSTLColor, 'Value', 5);
            elseif isequal(handles.STLColor, [255 255 0]) % Yellow
                set(handles.popupmenuSTLColor, 'Value', 6);
            elseif isequal(handles.STLColor, [0 0 0]) % Black
                set(handles.popupmenuSTLColor, 'Value', 7);
            elseif isequal(handles.STLColor, [255 255 255]) % White
                set(handles.popupmenuSTLColor, 'Value', 8);
            end
        end
        % TODO-Rework mask components
        if isfield(handles, 'maskComponent')
            handles.maskComponent = 0;
        end
        
        if isfield(handles, 'info')   
            set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
        else
            set(handles.textVoxelSize,'String','Voxel Size');
        end
        % Clear the image and mask from the axes
        cla(handles.axesIMG);
        updateImage(hObject,eventdata,handles);

        set(gcf,'menubar','none');
        set(gcf,'toolbar','none');

        guidata(hObject, handles);
        updateImage(hObject,eventdata,handles);
        setStatus(hObject, handles, 'Not Busy');
    catch err
        setStatus(hObject, handles, 'Failed');
        reportError(err);
    end 
end

% NAME-setPopup
% DESC-Sets a popup menu UI to match the backing value
% IN-handles: The handles data struct
% popup: The name of the popup menu in handles
% value: The name of the backing value in handles
% OUT-handles.(popup): Sets the Value attribute
function setPopup(handles, popup, value)
    if isfield(handles, value)
        % Get all the cells for the popup menu
        str = get(handles.(popup),'String');
        % Find the index of the cell containing the string
        val = find(contains(str, handles.(value)));
        % Set the value of the UI component to the correct index
        set(handles.(popup), 'Value', val);
    end
end

% NAME-setNumberTextbox
% DESC-Sets a texbox UI to match the numeric backing value
% IN-handles: The handles data struct
% textbox: The name of the textbox in handles
% value: The name of the backing value in handles
% OUT-handles.(textbox): Sets the String attribute
function setNumberTextbox(handles, textbox, value)
    if isfield(handles, value)
        set(handles.(textbox), 'String', num2str(handles.(value)));
    else
        set(handles.(textbox), 'String', '');
    end
end

% NAME-setStringTextbox
% DESC-Sets a texbox UI to match the string backing value
% IN-handles: The handles data struct
% textbox: The name of the textbox in handles
% value: The name of the backing value in handles
% OUT-handles.(textbox): Sets the String attribute
function setStringTextbox(handles, textbox, value)
    if isfield(handles, value)
        set(handles.(textbox), 'String', handles.(value));
    else
        set(handles.(textbox), 'String', '');
    end
end

% NAME-setSlider
% DESC-Sets a slider UI to match the backing value
% IN-handles: The handles data struct
% popup: The name of the slider in handles
% value: The name of the backing value in handles
% OUT-handles.(slider): Sets the Value attribute
function setSlider(handles, slider, value)
    if isfield(handles, value)
        set(handles.(slider), 'Value', handles.(value));
    else
        set(handles.(slider), 'Value', get(handles.(slider), 'Min'));
    end
end