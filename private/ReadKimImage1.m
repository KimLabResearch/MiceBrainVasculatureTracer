function [B_16int] = ReadKimImage1(FilePath, CropRange, Channel)

% load image

x_size = CropRange(1,2)-CropRange(1,1)+1;
y_size = CropRange(2,2)-CropRange(2,1)+1;
z_size = CropRange(3,2)-CropRange(3,1)+1;


B_16int = uint16(zeros(x_size,y_size,z_size));

for k = 1:z_size
    
    fname = sprintf('ch%01i/Z%03i_ch%02i.tif', Channel,k+CropRange(3,1)-1, Channel);
    fullFname = strcat(FilePath, fname);
    B_16int(:,:,k) = imread(fullFname,'PixelRegion',{CropRange(1,:),CropRange(2,:)});
        
end


