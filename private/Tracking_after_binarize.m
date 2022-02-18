
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
core_count =8;



%dir_in = uigetdir('Z:\', 'input folder');
%dir_in = 'D:\20190314_UC_U329_C57J_P560_optical\old_stitched';
dir_in = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\Binarized';
%preplot = 1;

labelImageFile = 'half.tif';
regionID = 453; 
%Visp = 385 %SomatoSensory = 453 %PTLp = 22 
%SSp-n = 353  %91 = PIR %703 = CTXsp
% 698 = OLF
size_factor = [10 10 10];
trimThickness = 0;  %% 10 um per integer

dialation_level = 3;
eroding_level = 3;

PaddingRange = 20;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('making mask \n')

tic

imLabel = extractRegionFromLabel(labelImageFile, regionID, 1);
imLabel = logical(imLabel);
imLabel = imLabel(:,:,51:end);
toc

fprintf('making croped mask \n')

tic
[imLabel, CropPoint_downsize, CropRange_downsize] = makingCropMask (imLabel,size_factor,trimThickness);
CropPoint = CropPoint_downsize .* size_factor;

CropSize = size(imLabel).*size_factor;

CropRange = [CropPoint(1),CropPoint(1)+CropSize(1)-1 ;
             CropPoint(2),CropPoint(2)+CropSize(2)-1 ;
             CropPoint(3),CropPoint(3)+CropSize(3)-1 ];       

toc              

         

%dir_in = strcat(dir_in, '\');

%if preplot
    
%Pre_Plot(dir_in,CropRange)
%end

%%


fprintf('Reading image \n');
tic
[B_bw] = ReadKim_Binary(dir_in, CropRange );
toc
tic
imLabelL = logical(imresize3(imLabel,size_factor(1), 'Method','nearest'));
B_bw =B_bw & imLabelL;
clear imLabelL
toc
tic

se = strel('sphere',dialation_level);
B_bw = imdilate(B_bw,se);
B_bw = imdilate(B_bw,se);
toc
tic
se = strel('sphere',eroding_level);
B_bw = imerode(B_bw,se);
B_bw = imerode(B_bw,se);
toc
tic

B_bw = bwareaopen(B_bw,1000);



toc
%%

fprintf('skeletonize \n')
tic

porposedCut = floor(2000000000./size(B_bw,1)./size(B_bw,1));
totalCut = ceil(size(B_bw,3)./porposedCut);
B_skel = B_bw;
B_skel = padarray(B_skel, [0,0,1]);

for ii = 1:totalCut
    zStart = (ii-1).*porposedCut+1;
    zEnd = (ii).*porposedCut;
    if zEnd > size(B_bw,3)
        zEnd = size(B_bw,3);
    end
    paraSkelTemp = B_skel(:,:,zStart:zEnd+2);
    spare = false(size(paraSkelTemp));
    spare(:,:,1)=1;
    spare(:,:,end)=1;

    paraSkelTemp = Skeleton3D_YTW_para(paraSkelTemp,spare,core_count);
    B_skel(:,:,zStart+1:zEnd+1) = paraSkelTemp(:,:,2:end-1);
    
    
end
B_skel = B_skel(:,:,2:end-1);


%B_skel2 = images.internal.pruneEdges3(B_skel2, 50);
toc

fprintf('tracking radii \n')
tic

if sum(B_skel(:)) ~= 0
    
[A2,node,link] = Skel2Graph3D(B_skel,100);

size_skel = size(B_skel);
[link] = computeRdii(size_skel,link,PaddingRange,B_bw);



else
    
    A2 = 0;
    node = 0;
    link = 0;

end
toc
tic    
[line_node_list, end_node_list] = List_R_Serial_kim(  size(imLabel).*10, node,link);
[tot_length] = Compute_length_isotropic(size(imLabel).*10,node,link);
box_volume = sum(sum(sum(imLabel)));
length_density = tot_length./box_volume
%mid_radius = median(line_node_list(:,4))
ave_radius = mean(line_node_list(:,4))
vessel_volume = sum(sum(sum(B_bw)));
volume_ratio = vessel_volume./box_volume./1000

countSplit = zeros(10,1);
countZeros = 0;
for ii = 1:length(node)
   node(ii).numLink = length(node(ii).conn);
   if ~isempty(node(ii).conn)
   countSplit(length(node(ii).conn)) = countSplit(length(node(ii).conn)) +1;
   else
       countZeros = countZeros +1;
   end
end
toc

%volumeViewer(B_bw);

%Plot_RP_kim(CropPoint, CropMultiplier, CutSize, HalfCutSize, node,link);
%save

%imwritestack(B_bw, 'bineried.tif');
%imwritestack(B_skel, 'bineried2.tif');

