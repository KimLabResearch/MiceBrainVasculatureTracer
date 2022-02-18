clear 
coreCount =8;
dir_in = uigetdir('D:\', 'tif folder');
%dir_in = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\Binarized';
dir_out = uigetdir('D:\', 'skeleton folder');
%dir_out = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\test';

%SaveBinary_all(dir_in);
%preparingFiles(dir_in, dir_out);


DirTif = dir([dir_in '/*.tif']);
numberFiles = length(DirTif);
FileTif=[DirTif(1).folder '/' DirTif(1).name];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
lImage= length(InfoImage);
cropSize = [nImage, mImage, lImage];
%preparingFiles(dir_in,dir_out);

mkdir([dir_out '/temp/']);
loopNumber = 1;
unchangedBorders = 0;
while unchangedBorders ~= 6
    unchangedBorders = 0;
    for currentBorder=1:6 % loop over all 6 directions
        fprintf(['loop #' num2str(loopNumber) ' boarder #' num2str(currentBorder) '\n' ]);
        noChange = false(1,numberFiles);
        tic
        parfor ii = 1:numberFiles

        
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


