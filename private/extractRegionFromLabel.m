
function imLabel = extractRegionFromLabel (labelImageFile, regionID, doAddSubRegions)
%labelImageFile = file name of the label image
%regionID - region to be extracted
%doAddSubRegions - add sub regions? 1 - to add, 0 not to add subregions

%addpath ('/Users/yongsookim/Documents/pipeline/local/netgpu/fluoMouseBrain/scripts/utils/')

[regionIDList region] = readAllenRegionAnnotationFile();
if (doAddSubRegions)
    subregionIDList = getAllSubregions(region, regionID);
else
    subregionIDList = regionID;
end

imLabel = imreadstack (labelImageFile);

imLabel (~ismember(uint32(imLabel), uint32(subregionIDList))) = 0;
%imageFileName = sprintf ('%s_RegionID_%06d.tif', labelImageFile(1:end-4), regionID);
%imwritestack (uint8(imLabel>0.5), imageFileName);
