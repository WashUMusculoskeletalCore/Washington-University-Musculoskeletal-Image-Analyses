# ContouringGUI
medical image processing software

**GENERAL USAGE**

> The general workflow of this software is intended to be:
  Load data;
  Minimize to relevant data;
  Identify region of interest;
  Run Analysis

**Loading data:** 
> Data can be loaded as DICOM format, TIF, or TXRM (from ZEISS XRM). When loading from TIF, an option to read metadata from a DICOM file is presented; if the user selects cancel, length units default to 1 and no density calibration is used.

**Minimizing to relevant data:**
> Everything in this software runs better the smaller the data set is. To minimize things, use the Zoom to Region button, then draw a square and double click it. Data can be further minimized by drawing a mask over the object you're interested in, pressing Crop to Mask, and then Isolate Object of Interest

**Identify region of interest:**
> To identify a region of interest, create a mask over the object you're interested in. This can be done using the Draw Contour button (and then edited with add and subtract), by using a global threshold method (Set Lower Threshold and then Set Mask to Current Threshold), or by creating primitive circles or rectangles.

**Run analysis:**
> Select the appropriate analysis from the dropdown menu and click Execute Analysis.


