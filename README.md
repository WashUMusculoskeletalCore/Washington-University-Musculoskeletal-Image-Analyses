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

> Inputs - A mask which covers the tissue considered to be cortical bone (NOT including medullary area), a lower (and upper) threshold set, and the background image.

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

- ObjectAndVoids
> Generates an image in the overall volume defined by a mask, separating what is the object and what is the void using a global threshold. Useful for visualizing a porus structure.

> Inputs - Mask, image stack, lower threshold, upper threshold

> Outputs - Plot of object (blue) and voids (red)

- TangIVDPMANotochord
> This analysis is a refinement of TangIVDPMA, intended to be used on PMA contrast enhanced murine discs that have been scanned at very high resolution, such as at 2um on a ZEISS XRM.

> Inputs - Mask representing the nucleus pulposis (when prompted), mask representing the full disk (when prompted), lower threshold representing cutoff for notochord remnant cells.

> Outputs - Volumes of whole disc, AP, NF, and notochord remnant cells, image of disk if required.

- NeedlePuncture
> Generates an image showing where a needle has punctured a bone/other structure.

> Inputs - mask representing bone (when prompted), mask representing puncture volume (when prompted).

> Outputs - image of bone with puncture.

- CalculateMaskVolume
> Calculates the volume of the current mask.

> Inputs - mask.

> Outputs - popup with mask volume displayed.

- RegisterVolumes
> This part of the software may be run as a separate program if needed, but is usually launched from ContouringGUI as part of a more complex workflow. It is intended to register a "moving" dataset to a "fixed" dataset, wherein the newly registered dataset can then be written out as a new DICOM stack. The user may also perform some basic movement operations to improve the initial conditions of the registration. The number of iterations required will increase as the disparity between original image sets increases.

> Inputs - Fixed DICOM stack, Moving DICOM stack.

> Outputs - Registered DICOM stack, set of overlayed images for quality check

- 2D-Analysis
> Performs a 2D analysis on each masked slice in the current image stack. Outcomes include 2D thickness at different positions, tissue mineral density, polar moment of inertia, and others.

> Inputs - masked set of images, typically of cortical bone

> Outputs - text file containing calculated parameters

- FractureCallusFullFracture
> Performs an analysis of a fracture callus according to the protocol used by the lab of Matt Silva for full fractures caused by 3-point bending. It expects that you have drawn a mask that represents the full callus, picked a lower threshold representing callus bone, and an upper threshold representing cortical bone.

> Inputs - cropped image stack, mask representing the callus, lower threshold representing callus bone, upper threshold representing cortical bone.

> Outputs - text file containing parameters relating to callus bone formation and the cortical bone contained therein.

- SkeltonizationAnalysis
> Not fully tested! This is a start of a method by which to analyze skeletonized structures, as may be used with trabecular networks, contrast enhanced vasculature, etc. The intended input mask should represent the network to be skeletonized and analyzed. That, and the image stack of course, are the only inputs. 

> Inputs - mask representing network structure, image stack

> Outputs - Figure showing skeletonized structure and thickness along that skeleton, text file containing nodes, node locations, link lengths, mean link radius, STD of link radius, and link points

- DistanceMap
> Transforms the current image stack with mask into a distance map

> Inputs - image stack, mask

> Outputs - distance transformation as new image stack

- WriteToDICOM
> Writes the current image stack to a new set of DICOM files in a sub-folder of the current data set's folder, taking its name from the text field below the Execute Analysis button

> Inputs - image stack

> Outputs - new DICOM stack on disk

- WriteToTiff
> Writes the current image stack to a new set of TIFF files in a sub-folder of the current data set's folder, taking its name from the text field below the Execute Analysis button. Recommended for use with external 3D Visualization programs.

> Inputs - image stack

> Outputs - new TIFF stack on disk

- YMaxForStrain
> Serves to identify the user selected Y max values required for strain gauge analysis. It runs on all slices, so crop down your data set first!

> Inputs - image stack, mask, user selected center and Ymax locations. 

> Outputs - popup box with Ymax distance

- ThicknessVisualization
> Generates an image of the spheres retained when calculating thickness in the volume of interest

> Inputs - image stack, mask

> Outputs - image of spheres retained in thickness calculations within object defined by mask

- HumanCoreTrabecularThickness
> Cancellous analysis variant for human femoral core samples generated by a collaborator to the MRC. Not for general use.

- StressFractureCallusAnalysis
> Performs an analysis of corical and cancellous bone according to the methods used by the Silva lab for fracture callus healing. Attempts to separate periosteal from endosteal healing, but this has not been rigorously tested. The callus volume is calculated through a data-driven mask generated by threshold detection of mineralization after corical bone removal.

> Inputs - image stack, mask representing cortical bone, lower threshold representing callus calcification

> Outputs - text file with standard callus outcome values, together and separated by surface.

- CTHistomorphometry
> Calculates differences between bone formation in 2 image stacks. Generally, the workflow is to register two stacks using RegisterVolumes, then load the fixed stack into the main GUI, then run CTHistomorphometry. When prompted, load the moving stack. Both stacks should be trimmed down to only the objects of interest prior to running.

> Inputs - fixed image stack containing only object of interest, lower threshold, upper threshold, moving stack with only object of interest when prompted.

> Text file containing the different volumes that can be calculated, images of overlayed volumes.
