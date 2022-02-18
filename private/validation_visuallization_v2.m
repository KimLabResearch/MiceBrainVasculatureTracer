%Visp = 385 %SomatoSensory = 453 %PTLp = 22 
%SSp-n = 353  %91 = PIR %703 = CTXsp
% 698 = OLF  %909 = ENT
% 549 = Thalamus  %375 = Ammon's horn
%485 = Striatum dorsal region
%{
dir_raw = uigetdir('D:\', 'raw folder');
dir_raw = [dir_raw '\'];
dir_out = uigetdir('D:\', 'out folder');
%}


%old
dir_raw = 'Z:\STP_processed\2019_optical\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\20190221_run2\20190409_stitched\';
dir_out = 'D:\test\young150';





size_factor = [10 10 10];

z_cut = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





fprintf('Reading image \n');


Slice_CropRange_Z = [round(CropSize(3)./2)-z_cut./2, round(CropSize(3)./2)-z_cut./2+z_cut-1];



tic


Bin_CropRange = [CropRange(1,1), CropRange(1,2); CropRange(2,1), CropRange(2,2); CropRange(3,1)+Slice_CropRange_Z(1), CropRange(3,1)+Slice_CropRange_Z(2) ];
Bin_CropSize = [CropSize(1),CropSize(2),z_cut  ];
[S_binarized] = ReadKim_SK(dir_tif,sizeImage,Bin_CropRange,Bin_CropSize);


imLabelL = logical(imresize3(imLabel,size_factor(1), 'Method','nearest'));
imLabelL = imLabelL(:,:,Slice_CropRange_Z(1):Slice_CropRange_Z(2));
S_binarized =S_binarized(imLabelL(S_binarized));


RawCropRange = [CropRange(1,1), CropRange(1,2); CropRange(2,1), CropRange(2,2); round((CropRange(3,1)+Slice_CropRange_Z(1))./5)+10,  round((CropRange(3,1)+Slice_CropRange_Z(1))./5)+10+z_cut./5-1];
[B_16int_2] = ReadKimImage1(dir_raw, RawCropRange, 2);



temp_Z = 1:1:size(imLabelL,3);
imLabelL(:,:,mod(temp_Z,5)~=0) = [];

B_16int_2(~imLabelL) = 0;

clear imLabelL




tot_Stack = ceil(CropSize(3)./z_cut);

[~,~,zz_skel] = ind2sub(CropSize,S_new.skel);
%[~,~,zz_binarized] = ind2sub(CropSize,S_binarized);

skel_plot = S_new.skel(zz_skel> Slice_CropRange_Z(1) & zz_skel<=Slice_CropRange_Z(2))-Slice_CropRange_Z(1).*CropSize(1).*CropSize(2);  
%S_binarized = S_binarized(zz_skel> Slice_CropRange_Z(1) & zz_skel<=Slice_CropRange_Z(2))-Slice_CropRange_Z(1).*CropSize(1).*CropSize(2);  



im = false([CropSize(1) CropSize(2) z_cut]);
im(skel_plot) = 1;
    
fname = [dir_out  '/skeleton_validate' num2str(regionID) '_Z' num2str(RawCropRange(3,1)) '-' num2str(RawCropRange(3,2)) '.tif'];
imwritestack(im, fname);

im = false([CropSize(1) CropSize(2) z_cut]);
im(S_binarized) = 1;
fname = [dir_out  '/binarized_validate' num2str(regionID) '_Z' num2str(RawCropRange(3,1)) '-' num2str(RawCropRange(3,2))  '.tif'];
imwritestack(im, fname);
    



fname = [dir_out  '/raw_validate' num2str(regionID) '_Z' num2str(RawCropRange(3,1)) '-' num2str(RawCropRange(3,2))  '.tif'];
imwritestack(B_16int_2, fname);


















