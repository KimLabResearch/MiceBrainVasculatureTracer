function dialate_erode(dir_in,coreCount)

DirTif = dir([dir_in '/*.tif']);


FileTif=[DirTif(1).folder '/' DirTif(1).name];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
lImage= length(InfoImage);
numberFiles = length(DirTif);
PaddingRange = 4;



parfor (ii = 1:numberFiles , coreCount)
tic    
cropRange = [1, nImage; 1, mImage; (ii-1).*lImage+1,ii.*lImage];

if ii ~= 1
    cropRange = cropRange + [0 0; 0 0; -(PaddingRange+1) 0];
end

if ii ~= numberFiles
    cropRange = cropRange + [0 0; 0 0; 0 (PaddingRange+1)];
end

cropSize = [cropRange(1,2)-cropRange(1,1)+1, cropRange(2,2)-cropRange(2,1)+1, cropRange(3,2)-cropRange(3,1)+1 ];
B_bw = ReadKim_Binary(dir_in, cropRange);


dialation_level = PaddingRange;
eroding_level = PaddingRange;

se = strel('sphere',dialation_level);
B_bw = imdilate(B_bw,se);

se = strel('sphere',eroding_level);
B_bw = imerode(B_bw,se);

if ii ~= 1
    B_bw = B_bw(:,:,(PaddingRange+2):end);
end

if ii ~= numberFiles
    B_bw = B_bw(:,:,1:end-(PaddingRange+1));
end

B_skf = uint64(find(B_bw));

fileIndicator = [dir_in '/binarized' num2str(ii,'%04d') '.bin' ];
fileID = fopen(fileIndicator,'w');
fwrite(fileID, uint64(B_skf),'uint64');
fclose(fileID);    
    
toc    
end
