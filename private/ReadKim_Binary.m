function [B_bw] = ReadKim_Binary(dir_in, CropRange)

% load image
x_size = CropRange(1,2)-CropRange(1,1)+1;
y_size = CropRange(2,2)-CropRange(2,1)+1;
z_size = CropRange(3,2)-CropRange(3,1)+1;


zStackStart = ceil(CropRange(3,1)./50);
zStackEnd = ceil(CropRange(3,2)./50);
currentz = 0;


%h = waitbar(0,'Reading Binary files...');





B_bw = false(x_size,y_size,z_size);
for ii = zStackStart:zStackEnd
    
    %fprintf(['reading stack #' num2str(ii) '\n']);
    FileTif=[dir_in '/binary_Z' num2str(ii,'%d') '.tif'];
    InfoImage=imfinfo(FileTif);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);
    asdasd=false(nImage,mImage,NumberImages);
 
    TifLink = Tiff(FileTif, 'r');
    for i=1:NumberImages
        TifLink.setDirectory(i);
        asdasd(:,:,i)=TifLink.read();
    end

    TifLink.close();
    if ii == zStackStart
        stackStart = mod(CropRange(3,1),50);
        if stackStart == 0
            stackStart = 50;
        end
    else
        stackStart = 1;
    end
    if ii == zStackEnd
        stackEnd = mod(CropRange(3,2),50);
        if stackEnd == 0
            stackEnd = 50;
        end
    else
        stackEnd = NumberImages;
    end

    B_bw(:,:,currentz+1:currentz+stackEnd-stackStart+1) = ~asdasd(CropRange(1,1):CropRange(1,2),CropRange(2,1):CropRange(2,2), stackStart:stackEnd);
    currentz = currentz+stackEnd-stackStart+1;
    %waitbar((ii-zStackStart+1)/(zStackEnd-zStackStart+1),h)
end

%close(h);