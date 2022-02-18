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
% dir_in :: input folder
% dir_out :: output folder

dir_in = [pwd '/binarized'];
dir_out = [pwd '/skeletonized'];


mkdir(dir_out);

% functions
% dialate_erode(dir_in, core_using)
%              :: remove small cavities by using dialation and errodsion (current hard codded setting 4 pixxels)
%                 The results will be store in the dir_in as bin files,
%                 each file contain 50 pixels slices in z
% preparingFiles(dir_in, dir_out,coreCount)
%              :: make copies of the first and last slice in z for each
%                 file and move it to dir_out. The extra slice is prepared
%                 for the later parallelization since skeletonization
%                 require +1 info for each step
% Skeleton3D_YTW_sub_sub :: parallel optimized skeletonization step that
%                           read from files and write to files

dialate_erode(dir_in,coreCount);
preparingFiles(dir_in, dir_out,coreCount);

DirTif = dir([dir_in '/*.tif']);
numberFiles = length(DirTif);
FileTif=[DirTif(1).folder '/' DirTif(1).name];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
lImage= length(InfoImage);
cropSize = [nImage, mImage, lImage];

mkdir([dir_out '/temp/']);
loopNumber = 1;
unchangedBorders = 0;
while unchangedBorders ~= 6
    unchangedBorders = 0;
    for currentBorder=1:6 % loop over all 6 directions
        fprintf(['loop #' num2str(loopNumber) ' boarder #' num2str(currentBorder) '\n' ]);
        noChange = false(1,numberFiles);
        tic
        parfor (ii = 1:numberFiles, coreCount)

        
            noChange(ii) = Skeleton3D_YTW_sub_sub(currentBorder,ii,numberFiles,cropSize,dir_out);
        

        end
        
        movefile([dir_out '/temp/*'], dir_out);
        toc
        fprintf(['stacks changing: ' num2str(sum(~noChange,'all')) '\n']);
        if( ~any(~noChange) )
            unchangedBorders = unchangedBorders + 1;
        end
    end
    loopNumber = loopNumber +1;

end


