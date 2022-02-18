function [skelAll] = ReadKim_SK(dir_in,sizeImage,CropRange,CropSize)


iiStart = ceil(CropRange(3,1)./sizeImage(3));
iiEnd = ceil(CropRange(3,2)./sizeImage(3));

for ii = iiStart:iiEnd

    fileIndicator = [dir_in '/binarized' num2str(ii,'%04d') '.bin' ];
    fileID = fopen(fileIndicator,'r');
    skelSparse{ii-iiStart+1} = fread(fileID, Inf, 'uint64');
    fclose(fileID);
    
end

skelAll = [];
for ii = 1:iiEnd-iiStart+1

    skelSparse{ii} = skelSparse{ii}+sizeImage(1).*sizeImage(2).*sizeImage(3).*(ii-2+iiStart);
    skelAll = [skelAll ; skelSparse{ii}];
    
end


[subX, subY, subZ] = ind2sub([sizeImage(1) sizeImage(2) sizeImage(3).*iiEnd],skelAll);

skelAll = skelAll(subX >= CropRange(1,1) & ...
                  subX <= CropRange(1,2) & ...
                  subY >= CropRange(2,1) & ...
                  subY <= CropRange(2,2) & ...
                  subZ >= CropRange(3,1) & ...
                  subZ <= CropRange(3,2) );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%skelAll = skelAll + sizeImage(1).*sizeImage(2).*sizeImage(3);%%%%%%%  Only because I skipped 50 um when doing interpolation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  and this line make it back
[subX, subY, subZ] = ind2sub([sizeImage(1) sizeImage(2) sizeImage(3).*iiEnd],skelAll);


subX = subX - CropRange(1,1) +1;
subY = subY - CropRange(2,1) +1;
subZ = subZ - CropRange(3,1) +1;

skelAll = sub2ind(CropSize,subX,subY,subZ);