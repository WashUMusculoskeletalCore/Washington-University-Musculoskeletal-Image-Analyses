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
> Select Draw Contour and then draw a contour by hand. If there is sufficient difference between the background and the object of interest (such as with a cortical bone scan), you can use the Adjust Current Slice button to automatically attempt to adjust to the object's edges. You may also then try to iterate forwards or backwards to automatically add a contour to the next slice and adjust it. Controls are the Method, Smoothing Factor, Contraction Bias, and Iterations. Fewer iterations are required if the geometry doesn't change much. Details on how these values influence mask shape can be found here: https://www.mathworks.com/help/images/ref/activecontour.html

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
- VolumeRender
> This analysis is currently broken, as The Mathworks broke their own built-in volume visualziation algorithm. It may be fixed in future MATLAB updates.

- Cortical
> Performs a standard cortical bone analysis

> Inputs - A mask which covers the tissue considered to be cortical bone (NOT including medullary area), a lower (and upper) threshold set, and the background image cropped to only slices containing mask.

> Outputs - writes line to a text file in the folder containing the DICOM files loaded.

- Cancellous
> Performs a standard cancellous bone analysis

> Inputs - A mask covering the full medullary volume (not the outer shell), lower and upper threshold, and background image cropped to only slices containing mask.

> Outputs - writes line to a text file in the folder containing the DICOM files loaded.

- LinearMeasure
> Allows the user to to drag the ends of a line where desired to perform a linear measurement on a 2D slice. 

> Inputs - loaded image stack.

> Outputs - values displayed on popup window.

- FractureCallusVascularity
> Generates the same parameters as a cancellous bone analysis, but customized for fracture callus vasculature.

> Inputs - "Football" mask representing complete callus, lower threshold, upper threshold, background image with contrast agent that shows up as different than bone and background

> Outputs - writes line to a text file in the folder containing the DICOM files loaded.

- Arterial
> This is a custom analysis script written for Olga Agapova at Wash U. It isn't meant to be used by others.

> Inputs - single scan of contrast enhanced arterial tissue.

> Outputs - 3D image of tissue and text file containing desired values

- MarrowFat
> This analysis is intended to characterize the contrast-enhanced marrow fat globules present in a given volume, usually the medullary volume of a tiba. It attempts to analyze individual globules, which works well when voxel size is a little below 2um. If using scans with larger voxel sizes, do no interpret values related to individual globules. Globules should be brighter than background.

> Inputs - Mask representing total volume of interest, lower threshold and upper threshold isolating globules

> Outputs - mean results text file, individual spehericity text file, individual volume text file, 3D image of volume and globules

- TangIVDPMA
> This analysis was originally intended as a pilot study script for Simon Tang, but can be used to investigate the morphology of murine intervertebral disks that have been contrast enhanced with PMA. It requires that the user (typically heavily) filters the scan, then creates two masks that are saved: One representing the nucleus pulposis, one representing the complete disc.

> Inputs - NP and Disc masks (when prompted), PMA contrast enhanced disc scan.

> Outputs - Image of disc parts (if desired), volumes in text file.

- TendonFootprint
> Analyzes the surface area representing the footprint of where a tendon inserts into a bone, or, more generally,  the surface area of the "bone" mask contained within the "tendon" mask. 

>Inputs - Mask representing the bone (will prompt for name), mask representing the tendon (will prompt for name).

>Outputs - A figure of the 3D surfaces of the two masks used, STL files of surfaces, text file with surface area.

- MakeGIF
> This function writes out the current image stack as a .gif file to the directory where the current images were loaded from.

> Inputs - image stack.

> Outputs - Animated .gif image

