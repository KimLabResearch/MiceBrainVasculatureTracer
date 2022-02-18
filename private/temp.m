
clear 
close all
dir_in = uigetdir('Z:\', 'input folder');


dir_out = uigetdir('Z:\', 'output folder');


DirTif = dir([dir_in '/ch1/*.tif']);
numberFiles = length(DirTif);
FileTif=[DirTif(1).folder '/' DirTif(1).name];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
lImage= length(InfoImage);
numImage = length(DirTif);
dir_in = strcat(dir_in, '\');



CropPoint = [1,1,10];
InterpolationLevel = 5.0;
CropSize = [nImage mImage lImage.*numImage-20];
if mod(CropSize(1),2) == 1
    CropSize(1) = CropSize(1) - 1;
end

if mod(CropSize(2),2) == 1
    CropSize(2) = CropSize(2) - 1;
end

% Cropsize(1) &(2) should be 2 x int
% Cropsize(3) should be 10 x int
looping_size = floor(CropSize(3)./10);



z = InterpolationLevel:InterpolationLevel:InterpolationLevel.*13;
zz = 10:1:59;
channel_1_ratio = 0.75;
background_size = 8;
percentile = 0.3;
cut_off_strength = 1200;
cut_off_strength_2 = 3000;
se = strel('disk',background_size);
domain = se.Neighborhood;


for jj =79:155
    tic
    loopCropPoint =  CropPoint + [0 0 10].*(jj-1) +[0 0 -1];
    loopCropSize = [CropSize(1) CropSize(2) 13];
    loopCropRange = [loopCropPoint(1),loopCropPoint(1)+loopCropSize(1)-1 ;
                     loopCropPoint(2),loopCropPoint(2)+loopCropSize(2)-1 ;
                     loopCropPoint(3),loopCropPoint(3)+loopCropSize(3)-1 ];
    tic
    [B_16int_1] = ReadKimImage1(dir_in, loopCropRange, 1);
    [B_16int_2] = ReadKimImage1(dir_in, loopCropRange, 2);
    
    B_intp_1 = single(zeros(length(zz),loopCropSize(1),loopCropSize(2)));
    B_intp_2 = single(zeros(length(zz),loopCropSize(1),loopCropSize(2)));
    B_16int_1 = permute(B_16int_1,[3 1 2]);
    B_16int_2 = permute(B_16int_2,[3 1 2]);
    hbar = parfor_progressbar(loopCropSize(1),'interpolation...');  %create the progress bar

    parfor ii=1:CropSize(2)
        B_intp_1(:,:,ii) = loopsplineGPU(single(B_16int_1(:,:,ii)),z,zz);
        B_intp_2(:,:,ii) = loopsplineGPU(single(B_16int_2(:,:,ii)),z,zz);
        hbar.iterate(1);
    end
    close(hbar);
    clear B_16int_1 B_16int_2
    B_intp_2 = B_intp_2 - B_intp_1.*channel_1_ratio;
    clear  B_intp_1
    B_intp_2 = permute(B_intp_2,[2 3 1]);
    
    
    J = imresize(B_intp_2,0.5);
    
    background = single(zeros(size(J)));
    hbar = parfor_progressbar(size(J,3),'making mask...');  %create the progress bar
    parfor ii=1:size(J,3)
        background(:,:,ii)  = ordfilt2(J(:,:,ii),round(percentile*numel(find(domain))),domain);
        hbar.iterate(1);
    end
    close(hbar);

    background2 = imresize(background,2);
    B_intp_3 = B_intp_2 - background2;
    BinM = false(size(background2));
    BinM(B_intp_3(:)>cut_off_strength)=1;
    BinM(B_intp_2(:)>cut_off_strength_2)=1;
    imwritestack(BinM,[dir_out '\binary_Z' num2str(jj) '.tif']);

    toc
end

%imwritestack(uint16(background2(:,:,1:25)), 'back.tif');
%imwritestack(uint16(B_intp_2(:,:,1:25)), 'ch2-ch1.tif');
%imwritestack(uint16(B_intp_3(:,:,1:25)), 'diff.tif');


