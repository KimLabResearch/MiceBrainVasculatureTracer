function [imLabel, CropPoint_downsize, CropRange_downsize] = makingCropMask (imLabel,size_factor,trimThickness)

if trimThickness > 0
    se = strel('sphere',trimThickness);
    imLabel = imerode(imLabel,se);              
end
if trimThickness < 0
    
    se = strel('sphere',-trimThickness);
    imLabel = imdilate(imLabel,se);        
end

for i = 1:size(imLabel,1)
imLabel_x_sum(i) = any(any(imLabel(i,:,:)));
end
imLabel_x_location = find(imLabel_x_sum);
for i = 1:size(imLabel,2)
imLabel_y_sum(i) = any(any(imLabel(:,i,:)));
end
imLabel_y_location = find(imLabel_y_sum);

for i = 1:size(imLabel,3)
imLabel_z_sum(i) = any(any(imLabel(:,:,i)));
end
imLabel_z_location = find(imLabel_z_sum);

CropPoint_downsize = [min(imLabel_x_location) min(imLabel_y_location) min(imLabel_z_location)];
CropRange_downsize = [CropPoint_downsize(1), max(imLabel_x_location) ;
                      CropPoint_downsize(2), max(imLabel_y_location) ;
                      CropPoint_downsize(3), max(imLabel_z_location) ];
         

%CropRange = CropRange_downsize .* size_factor';

imLabel = imLabel(CropRange_downsize(1,1):CropRange_downsize(1,2), ...
                  CropRange_downsize(2,1):CropRange_downsize(2,2), ...
                  CropRange_downsize(3,1):CropRange_downsize(3,2));

              

    
imLabel = uint8(imLabel);              

