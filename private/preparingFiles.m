function preparingFiles(dir_in, dir_out,coreCount)


DirTif = dir([dir_in '/*.tif']);
numberFiles = length(DirTif);
FileTif=[DirTif(1).folder '/' DirTif(1).name];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
lImage= length(InfoImage);

copyfile( [dir_in '/*.bin'], dir_out, 'f');



parfor (ii=1:numberFiles , coreCount)
    
    fileIndicator = [dir_out '/binarized' num2str(ii,'%04d') '.bin' ];
    fileID = fopen(fileIndicator,'r');
    skelSparse = fread(fileID, Inf, 'uint64');
    fclose(fileID);
   
    
    
    
    if ii ~= numberFiles
        skelSparse_end = skelSparse(skelSparse(:)>mImage.*nImage.*(lImage-1));
        skelSparse_end = skelSparse_end - mImage.*nImage.*(lImage-1);
        fileIndicator = [dir_out '/binarized_head' num2str(ii+1,'%04d') '.bin' ];
        fileID = fopen(fileIndicator,'w');
        fwrite(fileID, uint64(skelSparse_end),'uint64');
        fclose(fileID);
        
    end
    
    if ii ~= 1
        skelSparse_top = skelSparse(skelSparse(:)<=mImage.*nImage);
        fileIndicator = [dir_out '/binarized_foot' num2str(ii-1,'%04d') '.bin' ];
        fileID = fopen(fileIndicator,'w');
        fwrite(fileID, uint64(skelSparse_top),'uint64');
        fclose(fileID);
        
    end
    
    
end


