function im = imreadstack(fname)
%Modified by Yuan-Ting Wu 05/2019
%Add-in support for Logical (1-bit)




info = imfinfo(fname);
num_images = numel(info);

if (strcmp (info(1).ColorType, 'truecolor'))
    im = zeros ([info(1).Height info(1).Width 3 num_images]);
    for iImage = 1:num_images
        im(:,:,:,iImage) = imread(fname, 'Index', iImage);
    end
    im = cast (im, 'uint8');
else
    im = zeros ([info(1).Height info(1).Width num_images]);
    for iImage = 1:num_images
        im(:,:,iImage) = imread(fname, 'Index', iImage);
    end
    if info(1).BitDepth == 1
        dataType = 'logical';
    else
        dataType = strcat ('uint', num2str(info(1).BitDepth));
    end
    im = cast (im, dataType);

end