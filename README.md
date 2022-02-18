
# STPT Vasculature Tracer

This code here is designed to trace the vasculature in serial-two-photon-tomography (STPT).  The code take normalized stitched TIF files, binarize them with two (local and global) threshold, skeletonize them, remove artifacts from skeletonization, and finally group/document the data with a .mat file.  

## How to use
Copy this folder to the data folder and execute the *RUN_THIS_FILE_slurm_batch* with  slurm or shell. Or execute each individual operation in the batch file (The batch file can be open as a text file) with Matlab. 

## Limitations
- The code is currently only support the 1x1x5 um (5 um optical sectioning) resolution
- The file structure is fixed. All background TIF files are in folder *ch1* and all foreground TIF files are in folder *ch2*. The TIF files need to neamed as Z###_ch##.tif. 

## Environment
Matlab 2019a

## Liscense
Free academic use.
