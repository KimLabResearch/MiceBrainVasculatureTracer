% region is the region structure from [regionIDList region] = readAllenRegionAnnotationFile();
% region ID is the label that has to be masked

function subregionIDList = getAllSubregions(region, regionID)

childrenIDList = region(regionID).children_id;
subregionIDList = [regionID];

for iChild = 1:length(childrenIDList)
    sprintf ('Parent = %d, child = %d\n', regionID, childrenIDList(iChild));
    subregionIDList = [subregionIDList childrenIDList(iChild)];
    grandchildrenIDList = getAllSubregions(region, childrenIDList(iChild));
    subregionIDList = [subregionIDList grandchildrenIDList];
end

subregionIDList = unique (subregionIDList);