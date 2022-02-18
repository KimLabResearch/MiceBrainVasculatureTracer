function im = imreadstack_bw(fname)
%Modified by Yuan-Ting Wu 05/2019
%Add-in support for Logical (1-bit)
info = imfinfo(fname);
num_images = numel(info);
    im = false ([info(1).Height info(1).Width num_images]);
    for iImage = 1:num_images
        im(:,:,iImage) = imread(fname, 'Index', iImage);
    end
    
    