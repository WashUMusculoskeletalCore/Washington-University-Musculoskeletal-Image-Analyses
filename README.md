# ContouringGUI
medical image processing software

**General Workflow**

  - Load data
  - Minimize to relevant data
  - Identify region of interest
  - Run Analysis

**Loading data:** 
> Data can be loaded as DICOM format, TIF, or TXRM (from ZEISS XRM). When loading from TIF, an option to read metadata from a DICOM file is presented; if the user selects cancel, length units default to 1 and no density calibration is used.

**Minimizing to relevant data:**
> Everything in this software runs better the smaller the data set is. To minimize things, use the Zoom to Region button, then draw a square and double click it. Data can be further minimized by drawing a mask over the object you're interested in, pressing Crop to Mask, and then Isolate Object of Interest

**Identify region of interest:**
> To identify a region of interest, create a mask over the object you're interested in. This can be done using the Draw Contour button (and then edited with add and subtract), by using a global threshold method (Set Lower Threshold and then Set Mask to Current Threshold), or by creating primitive circles or rectangles.

**Run analysis:**
> Select the appropriate analysis from the dropdown menu and click Execute Analysis.

**Masking/Contouring**
There are three main options for creating a mask in this software: Directly by drawing, by thresholding, and by creating primitive shapes. 
- Direct drawing 
> Select Draw Contour and then draw a contour by hand. If there is sufficient difference between the background and the object of interest (such as with a cortical bone scan), you can use the Adjust Current Slice button to automatically attempt to adjust to the object's edges. You may also then try to iterate forwards or backwards to automatically add a contour to the next slice and adjust it. Controls are the Method, Smoothing Factor, Contraction Bias, and Iterations. Fewer iterations are required if the geometry doesn't change much.
- Thresholding
> A mask may be created by using a global threshold. Adjust the slider to identify an appropriate threshold, then click Set Lower Threshold (and find an upper threshold if needed), then click Set Mask to Current Threshold. All pixels in the desired range will now form your mask.
-Primitives
> You may also create masks by using the Create Primitive button with indicated axes sizes and position.

Common masking tools
- Morph All will perform a linear interpolation between any drawn mask and the next mask it encounters in the stack. As such, when using it, make sure you draw masks on enough key frames to get the shape you want.
- Set Mask by Clicking will allow the user to click on a pixel in a mask of interest and then hit enter, removing any parts of masks that aren't attached to the one clicked on. Useful after setting a global threshold when only one object is desired.

**Image Manipulation**
- Planar rotation: Use the Rotate Image button, which reads from the text field below it.
- Principle plan rotation: Use Rotate 90 Deg, which will rotate about the axis selected in the dropdown below it.
- Brightness: Use the Window Location and Window Width sliders to adjust the brightness. This only changes the image for visualization, it doesn't change the underlying values.
- Color mapping: You can choose a different color map than grayscale values by pressing Set Color Map after changing the dropdown to what you'd like.

**Analyzing Data**
- Volume Render
> This analysis is currently broken, as The Mathworks broke their own built-in volume visualziation algorithm. It may be fixed in future MATLAB updates.

- Cortical
> Performs a standard cortical bone analysis

> Inputs - A mask which covers the tissue considered to be cortical bone (NOT including medullary area), a lower (and upper) threshold set, and the background image cropped to only slices containing mask.

> Outputs - writes line to a text file in the folder containing the DICOM files loaded.

- Cancellous
> Performs a standard cancellous bone analysis

> Inputs - A mask covering the full medullary volume (not the outer shell), lower and upper threshold, and background image cropped to only slices containing mask.

> Outputs - writes line to a text file in the folder containing the DICOM files loaded.

-Linear Measure
> Allows the user to to drag the ends of a line where desired to perform a linear measurement on a 2D slice. 

> Inputs - loaded image stack.

> Outputs - values displayed on popup window.
