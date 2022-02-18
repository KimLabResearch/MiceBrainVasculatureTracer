
# STPT Vasculature Tracer

This code here is designed to trace the vasculature in serial-two-photon-tomography (STPT).  The code take normalized stitched TIF files, binarize them with two (local and global) threshold, skeletonize them, remove artifacts from skeletonization, and finally group/document the data with a .mat file.  

## How to use
Copy this folder to the data folder and execute the the following four files with Matlab. If you are using a slurm HPC system, you can try the slurm batch file.
- 1. binarization
- 2. skeletonization
- 3. radii from skeleton
- 4. tracking

## Limitations
- The code is currently only support the 1x1x5 um (5 um optical sectioning) resolution
- The file structure is fixed. All background TIF files are in folder *ch1* and all foreground TIF files are in folder *ch2*. The TIF files need to neamed as Z###_ch##.tif. 

## Environment
Matlab 2019a

## Liscense
Free academic use.
