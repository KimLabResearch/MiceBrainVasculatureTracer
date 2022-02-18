

clear


%%% Parallel control
% This part is only for HPC to distribute the parallel profiles
% coreCount :: number of cores per node

coreCount =22;
aa = parcluster
temp_folder = ['./matlab_cluster_', datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF')];
mkdir(temp_folder);
aa.JobStorageLocation = temp_folder;

parpool(aa,coreCount ,'IdleTimeout',inf)

%% General setting
% dir_root :: data folder (also the output)
% dir_in :: input folder
% dir_tif :: referencing folder for image size (from tif files)
% dir_radii :: radii folder


dir_root = pwd;

dir_in = [dir_root '/skeletonized'];
dir_tif = [dir_root '/binarized'];
dir_radii = [dir_root '/radii'];


% Judging_length :: max length that will be pruned (in pixel)
% Judging_ratio :: max aspec ratio will be pruned (short and stubby one will bekilled)


Judging_length = 40;
Judging_ratio = 10;




fprintf('Reading image \n');
DirTif = dir([dir_tif '/*.tif']);


FileTif=[DirTif(1).folder '/' DirTif(1).name];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
lImage = length(InfoImage);
numberFiles = length(DirTif);

sizeImage = [nImage, mImage, lImage];



CropRange = [1, nImage; 1, mImage; 1, lImage.*numberFiles];

CropSize = CropRange(:,2);

% functions
% ReadKim_Radii(dir_sklelton, dir_radii, sizeImage,CropRange,CropSize)
%              :: read both skeleton and radii from binary files
% Skeketon_clean_up_1(S_skel, S_radii, CropSize,prunning_length)
%               :: prunning the hanging skeletons with length
% Skeketon_connect_close(S_skel, S_radii,CropSize)
%               :: conneting end node that is very close to each other (Currently hard coded as 10 pixels)
%
%                 sizeImage,CropSize = [x, y, z]
%                 CropRange = [x_lower, x_upper; y_lower, y_upper; z_lower, z_upper]
% Skeketon_clean_up_2(S_skel, S_radii,CropSize,Judging_length)
%               :: prunning the hanging skeletons with aspect ratio


[S_skel, S_radii] = ReadKim_Radii(dir_in, dir_radii, sizeImage,CropRange,CropSize);
S_skel = uint64(S_skel);
S_radii = sqrt(double(S_radii));
fprintf(['Removing Small Artifacts \n' ]);
jj =0;
length_node_to_remove_par =1;
while length_node_to_remove_par ~= 0
    jj=jj+1;
    fprintf(['Skeleton clean Up Round #' num2str(jj)  ' \n' ]);
    [S_skel,S_radii,length_node_to_remove_par] = Skeketon_clean_up_1(S_skel, S_radii,CropSize,2);
    
end

fprintf(['Connecting short gaps < 10 um\n' ]);

[S_skel,S_radii] = Skeketon_connect_close(S_skel, S_radii,CropSize);

length_node_to_remove_par =1;
while length_node_to_remove_par ~= 0
    jj=jj+1;
    fprintf(['Skeleton clean Up Round #' num2str(jj)  ' \n' ]);
    [S_skel,S_radii,length_node_to_remove_par] = Skeketon_clean_up_1(S_skel, S_radii,CropSize,5);
    
end

fprintf(['Removing Larger Artifacts \n' ]);


tic



length_node_to_remove_par =1;

while length_node_to_remove_par ~= 0

    jj=jj+1;
    fprintf(['Skeleton clean Up Round #' num2str(jj)  ' \n' ]);
    [S_skel,S_radii,length_node_to_remove_par] = Skeketon_clean_up_2(S_skel, S_radii,CropSize,Judging_length);
    [S_skel,S_radii,~] = Skeketon_clean_up_1(S_skel, S_radii,CropSize,10);
    
end


length_node_to_remove_par =1;
while length_node_to_remove_par ~= 0

    jj=jj+1;
    fprintf(['Skeleton clean Up Round #' num2str(jj)  ' \n' ]);
    [S_skel,S_radii,length_node_to_remove_par] = Skeketon_clean_up_3(S_skel, S_radii,CropSize,Judging_ratio);
    
end

toc


dir_clean_skel = [dir_root '/clean_skel'];
mkdir(dir_clean_skel);

fileIndicator = [dir_clean_skel '/clean_skel.bin' ];
fileID = fopen(fileIndicator,'w');
fwrite(fileID, uint64(S_skel),'uint64');
fclose(fileID);

fileIndicator = [dir_clean_skel '/clean_radii.bin' ];
fileID = fopen(fileIndicator,'w');
fwrite(fileID, double(S_radii),'double');
fclose(fileID);

