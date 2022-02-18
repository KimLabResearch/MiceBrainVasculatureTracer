function [S_skel, S_radii] = ReadKim_Radii(dir_in, dir_radii, sizeImage,CropRange,CropSize)


iiStart = ceil(CropRange(3,1)./sizeImage(3));
iiEnd = ceil(CropRange(3,2)./sizeImage(3));

for ii = iiStart:iiEnd

    fileIndicator = [dir_in '/binarized' num2str(ii,'%04d') '.bin' ];
    fileID = fopen(fileIndicator,'r');
    skelSparse{ii-iiStart+1} = fread(fileID, Inf, 'uint64');
    fclose(fileID);
    
    fileIndicator = [dir_radii '/radii' num2str(ii,'%04d') '.bin' ];
    fileID = fopen(fileIndicator,'r');
    radiiSparse{ii-iiStart+1} = fread(fileID, Inf, 'uint64');
    fclose(fileID);
    
    
    
    
    
    
end

S_skel = [];
S_radii = [];
for ii = 1:iiEnd-iiStart+1

    skelSparse{ii} = skelSparse{ii}+sizeImage(1).*sizeImage(2).*sizeImage(3).*(ii-2+iiStart);
    S_skel = [S_skel ; skelSparse{ii}];
    radiiSparse{ii} = radiiSparse{ii};
    S_radii = [S_radii ; radiiSparse{ii}];
    
end


[subX, subY, subZ] = ind2sub([sizeImage(1) sizeImage(2) sizeImage(3).*iiEnd],S_skel);

region =         (subX >= CropRange(1,1) & ...
                  subX <= CropRange(1,2) & ...
                  subY >= CropRange(2,1) & ...
                  subY <= CropRange(2,2) & ...
                  subZ >= CropRange(3,1) & ...
                  subZ <= CropRange(3,2) );

S_skel = S_skel(region);
S_radii = S_radii(region);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%skelAll = skelAll + sizeImage(1).*sizeImage(2).*sizeImage(3);%%%%%%%  Only because I skipped 50 um when doing interpolation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  and this line make it back
[subX, subY, subZ] = ind2sub([sizeImage(1) sizeImage(2) sizeImage(3).*iiEnd],S_skel);


subX = subX - CropRange(1,1) +1;
subY = subY - CropRange(2,1) +1;
subZ = subZ - CropRange(3,1) +1;

S_skel = sub2ind(CropSize,subX,subY,subZ);