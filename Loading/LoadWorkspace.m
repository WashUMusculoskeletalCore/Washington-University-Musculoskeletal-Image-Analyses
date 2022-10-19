% NAME-LoadWorkspace
% DESC-Loads a workspace state that was previously saved from a data file
% IN-*.mat: a file containing saved handles fields
% OUT-handles: loads the handles fields from the file
function LoadWorkspace(hObject,handles)
    try
        setStatus(handles, 'Busy');
        displayPercentLoaded(handles, 0);
        % Open a dialog to select the file
        if isfield(handles, 'pathstr')
            [file, pathstr] = uigetfile(handles.pathstr, 'Select the workspace file to load'); % look in folder in pathstring
        else
            [file, pathstr] = uigetfile(pwd, 'Select the workspace file to load'); % pwd=look in current folder
        end
        if isequal(file, 0) && isequal(pathstr, 0)
            error('ContouringGUI:InputCanceled', 'File selection canceled')
        end
        setStatus(handles, 'Clearing Workspace');
        fieldNames = fieldnames(handles);
        fieldNum = numel(fieldnames(handles));
        % Remove all non-graphics fields
        for i = 1:fieldNum
            if ~any(isgraphics(handles.(fieldNames{i})), [1,2]) || isequal(handles.(fieldNames{i}), 0) % 0 is considered a graphics object by isgraphics
                handles = rmfield(handles, fieldNames{i});
            end
            displayPercentLoaded(handles, i/(fieldNum*3));
        end
        % Load the file and copy all loaded fields to handles
        setStatus(handles, 'Loading Workspace Data');
        s = load(fullfile(pathstr,file));
        fieldNames = fieldnames(s);
        fieldNum = numel(fieldnames(s));
        for i = 1:fieldNum
            handles.(fieldNames{i}) = s.(fieldNames{i});
            displayPercentLoaded(handles, 1/3+i/(fieldNum*3));
        end
        
        set(handles.textCurrentDirectory,'String', handles.pathstr);

        % Set all UI components to match the values in the model
        setStatus(handles, 'Preparing Display')
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
        setPopup(handles, 'popupmenuPrimitive', 'primitiveShape');
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
        % Rotation
        setNumberTextbox(handles, 'editRotationDegrees', 'rotateDegrees');
        % Sliders
        if isfield(handles, 'img')
            handles.sliderThreshold = resizeSlider(handles.sliderThreshold, handles.dataMin, handles.dataMax, 1, (handles.dataMax-handles.dataMin)/1000); 
            handles.sliderWindowWidth = resizeSlider(handles.sliderWindowWidth, 1, handles.dataMax-handles.dataMin, 1, (handles.dataMax-handles.dataMin)/1000); 
            handles.sliderWindowLocation = resizeSlider(handles.sliderWindowLocation, handles.dataMin, handles.dataMax, 1, handles.dataMax/1000);
            handles.sliderIMG = resizeSlider(handles.sliderIMG, handles.abc(3));
        else
            handles.sliderThreshold = resizeSlider(handles.sliderThreshold, 0, 1, 0, 0); 
            handles.sliderWindowWidth = resizeSlider(handles.sliderWindowWidth, 0, 1, 0, 0); 
            handles.sliderWindowLocation = resizeSlider(handles.sliderWindowLocation, 0, 1, 0, 0);
            handles.sliderIMG = resizeSlider(handles.sliderIMG, 0, 1, 0, 0);
        end
        setSlider(handles, 'sliderWindowWidth', 'windowWidth');
        setSlider(handles, 'sliderWindowLocation', 'windowLocation');
        setSlider(handles, 'sliderThreshold', 'threshold')
        setSlider(handles, 'sliderIMG', 'slice');
        % Others          
        setNumberTextbox(handles, 'editSpeckleSize', 'speckleSize');
        setNumberTextbox(handles, 'editScaleImageSize', 'imgScale');
        setStringTextbox(handles, 'editMaskName','maskName');
        if isfield(handles, 'savedMasks')
            set(handles.popupmenuEditMaskName, 'String', keys(handles.savedMasks));
            if isKey(handles.savedMasks, handles.maskName)
                setPopup(handles, 'popupmenuEditMaskName', 'maskName');
            end
        end
        setNumberTextbox(handles, 'editSliceNumber', 'slice');
        % Mapped popup menus
        if isfield(handles, 'rotateAxis')
            switch handles.rotateAxis
                case 1 % X
                    set(handles.popupmenuRotationAxis, 'Value', 2);
                case 2 % Y
                    set(handles.popupmenuRotationAxis, 'Value', 1);
                case 3 % Z
                    set(handles.popupmenuRotationAxis, 'Value', 3);
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
        
        if isfield(handles, 'info')   
            set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
        else
            set(handles.textVoxelSize,'String','Voxel Size');
        end
        % Clear the image and mask from the axes
        cla(handles.axesIMG);

        updateImage(hObject,handles);
        displayPercentLoaded(handles, 1);
        setStatus(handles, 'Not Busy');
    catch err
        reportError(err, handles);
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