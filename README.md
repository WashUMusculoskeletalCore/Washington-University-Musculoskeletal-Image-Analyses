# Washington University Musculoskeletal Image Analyses 
medical image processing software

Joseph Szatkowski
szatkowski@wustl.edu

Designed on Matlab 2022a
Using:
Statistics and Machine Learning Toolbox V12.3
Image Processing Toolbox V11.5

This is an in development program. Please post feedback to https://wustl.box.com/v/OthoLabAppFeedback

**General Workflow**

  - Load data
  - Minimize to relevant data
  - Identify region of interest
  - Run Analysis

**Loading data:** 
> Data can be loaded as DICOM format, TIF, or TXRM (from ZEISS XRM). When loading from TIF, an option to read metadata from a DICOM file is presented; if the user selects cancel, length units default to 1 and no density calibration is used.

**Minimizing to relevant data:**
> Everything in this software runs better the smaller the data set is. To minimize things, use the Zoom to Region button, then draw a square and double click it. Data can be further minimized by drawing a mask over the object you're interested in, pressing Crop to Mask, and then Isolate Object of Interest
> Set as First Slice and Set as Last Slice remove all slices before and after the current slice from the image.

**Identify region of interest:**
> To identify a region of interest, create a mask over the object you're interested in. This can be done using the Draw Contour button (and then edited with add and subtract), by using a global threshold method (Set Lower Threshold and then Set Mask to Current Threshold), or by creating primitive circles or rectangles.

**Run analysis:**
> Select the appropriate analysis from the dropdown menu and click Execute Analysis.

**Masking/Contouring**
There are three main options for creating a mask in this software: Directly by drawing, by thresholding, and by creating primitive shapes. 
- Direct drawing 
> Select Draw Contour and then draw a contour by hand. If there is sufficient difference between the background and the object of interest (such as with a cortical bone scan), you can use the Adjust Current Slice button to automatically attempt to adjust to the object's edges. You may also then try to iterate forwards or backwards to automatically add a contour to the next slice and adjust it. Controls are the Method, Smoothing Factor, Contraction Bias, and Iterations. Fewer iterations are required if the geometry doesn't change much. Details on how these values influence mask shape can be found here: https://www.mathworks.com/help/images/ref/activecontour.html
> Existing contour can be modified using Add Contour and Subtract Contour

- Thresholding
> A mask may be created by using a global threshold. Toggle the Set Lower Threshold button, and adjust the slider to identify an appropriate threshold. You can also do the same with the Set Upper Threshold.
> After selecting a threshold click Set Mask to Current Threshold. All pixels in the desired range will now form your mask.

- Primitives
> You may also create masks by using the Create Primitive button with indicated axes sizes and position.

- Common masking tools
> Morph All will perform a linear interpolation between any drawn mask and the next mask it encounters in the stack. As such, when using it, make sure you draw masks on enough key frames to get the shape you want. Morph Range will do the same within a range between two slices.
> Clear All and Clear Range will delete all or part of the mask within the chosen slice range.

> Set Mask by Clicking will allow the user to click on one or more pixels in a mask of interest and then hit enter, removing any parts of masks that aren't attached to the ones clicked on. Useful after setting a global threshold when only one object is desired.
> Set Mask to Component will allow the user to select a number, and then isolate the nth largest component.
> Remove Speckle Noise from Mask removes all components below a chosen number of pixels in size.

> Copy Mask Slice and Paste Mask Slice can copy a mask from one slice to another.

> Translate buttons shift the mask a fixed distance in any dirrection.

> Update Masked Regions displays a list of slices where masked regions start and stop. This can be used to identify masked frames when morphing.

- The Toggle Mask Button can hide or show the mask. Any function that creates or edits the mask will automatically show the mask.

**Saving/Loading**
> Use Set Current Image as Original to save the current image, then use Revert to Original Image to return the image to its saved state. Some functions that alter the image will also save the original image.
> Use Store Mask to save the current mask under the name in the textbox, and Load Mask to reload the named mask. Saved masks can also be selected using the dropdown menu.
> Save Workspace will save the current state of the program as a file, which can be loaded with Load Workspace.

**Image Manipulation**
> Planar rotation: Use the Rotate Image button, which reads from the text field below it.
> Principle plan rotation: Use Rotate 90 Deg, which will rotate about the axis selected in the dropdown below it.
> Rotate Preview: Use this to rotate the image multiple times without data loss. Close the preview then confirm to apply the rotation.
> Brightness: Use the Window Location and Window Width sliders to adjust the brightness. This only changes the image for visualization, it doesn't change the underlying values. Clicking Use Current Visualization for Contouring will apply these changes to the underlying values. 
> Color mapping: You can choose a different color map than grayscale values by pressing Set Color Map after changing the dropdown to what you'd like.
> Invert Image and Invert Mask can be used to reverse black and white on the image and mask respectively.
> Scale Image Size changes the resolution of the image.
> Open, Close, Dilate, Erode, and Fill morphological operations can be performed by selecting an operation from the dropdown menu, and clicking Execute Morphological Operations. Operations can be performed on the image or mask, in 2D slice by slice or 3D, and with a selected radius.
> Make Dataset Isotropic adjusts the image so that all voxels are the same size in all 3 dimensions (Using physical units from DICOM info).

- Filters
> Filters can be used to reduce noise in the image. To use a filter select one from the dropdown menu and click Execute Filter
> Higher radius and weight (in gaussian) can filter more noise, but at the cost of image sharpness.

**3D Images**
> Create 3D Image will generate a 3D model of the current mask using the selected alpha radius.
> After a 3D image is created, it can be saved as an STL file using either binary or ASCII encoding.

**Analyzing Data**

- Cortical
> Performs a standard cortical bone analysis. Use the mask to denote the area to analyze, including pores, but not the medullary area, and the thresholds to denote the bone.

> Inputs - A mask which covers the tissue considered to be cortical bone (NOT including medullary area), a lower (and upper) threshold set, and the background image.
> Toggle Robust Thickness to use a more advanced, but more time consuming algorithm to calculate thickness.

> Outputs - writes line to a text file in the folder containing the DICOM files loaded.

- Cancellous
> Performs a standard cancellous bone analysis. Use the mask to denote the area to analyze and the thresholds to denote the trabecular structure.

> Inputs - A mask covering the full medullary volume (not the outer shell), lower and upper threshold, and background image cropped to only slices containing mask.
> Toggle Robust Thickness to use a more advanced, but more time consuming algorithm to calculate thickness.

> Outputs - Writes line to a text file in the folder containing the DICOM files loaded.

- LinearMeasure
> Allows the user to to drag the ends of a line where desired to perform a linear measurement on a 2D slice. Right click the line and select delete to remove it. 

> Inputs - loaded image stack.

> Outputs - Length of the line is displayed as a label.

- TangIVDPMA
> This analysis was originally intended as a pilot study script for Simon Tang, but can be used to investigate the morphology of murine intervertebral disks that have been contrast enhanced with PMA. It requires that the user (typically heavily) filters the scan, then creates two masks that are saved: One representing the nucleus pulposis, one representing the complete disc.

> Inputs - NP and Disc masks (when prompted), PMA contrast enhanced disc scan.

> Outputs - Image of disc parts (if desired), volumes in text file.

- MakeGIF
> This function writes out the current image stack as a .gif file to the directory where the current images were loaded from.

> Inputs - The image stack.

> Outputs - Animated .gif image.

- TangIVDPMANotochord
> This analysis is a refinement of TangIVDPMA, intended to be used on PMA contrast enhanced murine discs that have been scanned at very high resolution, such as at 2um on a ZEISS XRM.

> Inputs - Mask representing the nucleus pulposis (when prompted), mask representing the full disk (when prompted), lower threshold representing cutoff for notochord remnant cells.

> Outputs - Volumes of whole disc, AP, NF, and notochord remnant cells, image of disk if required.

- NeedlePuncture
> Generates an image showing where a needle has punctured a bone/other structure.

> Inputs - Mask representing bone (when prompted), Mask representing puncture volume (when prompted).

> Outputs - 3D image of bone with puncture.

- MaskVolume
> Calculates the volume of the current mask.

> Inputs - The mask.

> Outputs - Popup with mask volume displayed.

- RegisterVolumes
> This part of the software may be run as a separate program if needed, but is usually launched from ContouringGUI as part of a more complex workflow. It is intended to register a "moving" dataset to a "fixed" dataset, wherein the newly registered dataset can then be written out as a new DICOM stack. The user may also perform some basic movement operations to improve the initial conditions of the registration. The number of iterations required will increase as the disparity between original image sets increases.

> Inputs - Fixed DICOM stack, Moving DICOM stack.

> Outputs - Registered DICOM stack, set of overlayed images for quality check.

- DensityAnalysis
> Analyzes the density of the image.

> Inputs: The image stack.

> Outputs: A file containing the density information.

- WriteToTiff
> Writes the current image stack to a new set of TIFF files in a sub-folder of the current data set's folder, taking its name from the text field below the Execute Analysis button. Recommended for use with external 3D Visualization programs.

> Inputs - The image stack.

> Outputs - A stack of tiff files of the image.

- WriteToDICOM
> Writes the current image stack to a new set of DICOM files in a sub-folder of the current data set's folder, taking its name from the text field below the Execute Analysis button

> Inputs - The image stack.

> Outputs - A DICOM stack of the image.

- SaveCurrentImage
> Saves the displayed image(including the mask) as a tif file.

> Inputs - The current image slice, the current mask slice .

> Outputs - A tif file of the current image.

- GenerateHistogram
> Generates a Histogram graph of the image.

> Inputs - The image stack.

> Outputs - A histogram showing the frequency of all values in the image.

- ThicknessVisualization
> Generates an image of the spheres retained when calculating thickness in the volume of interest.

> Inputs - The image stack, the mask.

> Outputs - Image of spheres retained in thickness calculations within object defined by mask.

- CTHistomorphometry
> Calculates differences between bone formation in 2 image stacks. Generally, the workflow is to register two stacks using RegisterVolumes, then load the fixed stack into the main GUI, then run CTHistomorphometry. When prompted, load the moving stack. Both stacks should be trimmed down to only the objects of interest prior to running.

> Inputs - Fixed image stack containing only object of interest, lower threshold, upper threshold, moving stack with only object of interest when prompted.

> Text file containing the different volumes that can be calculated, images of overlayed volumes.

- ConvertTo-Houndfield
> Transforms the current image stack with mask into a density map.

> Inputs - image stack, mask.

> Outputs - density in Hounsfield units as new image stack.

- ConvertTo-MgHAperCCM
> Transforms the current image stack with mask into a density map.

> Inputs - image stack, mask.

> Outputs - density in miligrams of HA/cubic cm as new image stack.

- ConvertTo-DistanceMap
> Transforms the current image stack with mask into a distance map.

> Inputs - The image stack, the mask.

> Outputs - distance transformation as new image stack.
