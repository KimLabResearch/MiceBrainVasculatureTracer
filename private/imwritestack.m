function imwritestack(im, fname)
%--------------------------------------------------------------------------
% imwritestack.m function is used to writing TIF image stacks in greyscale and RGB
%
% Developed and maintained by Kannan Umadevi Venkataraju <kannanuv@cshl.edu>
% do not distribute without permission.
%
% Usage 
% imwritestack(im, fname)
% 
% History
% Author   | Date         |Change
%==========|==============|=================================================
% kannanuv | 2011 Nov 09  |Initial Creation
% kannanuv | 2013 Aug 08  |Fixed issues for writing 2D images
%--------------------------------------------------------------------------
delete(fname);
dimensions = numel(size(im));

if (dimensions == 4)
    num_images = size (im, 4);
else 
    if (dimensions == 3)
        num_images = size (im, 3);
    end
    if (dimensions == 2)
        num_images = 1;
    end
end

if (exist(fname))
    delete fname
end

for iImage = 1:num_images
    if ((dimensions == 3) || (dimensions == 2))
        imwrite (im (:,:, iImage), fname, 'WriteMode', 'append', 'Compression', 'none');
    else if (dimensions == 4)
            imwrite (im (:,:,:,iImage), fname, 'WriteMode', 'append', 'Compression', 'none');
        end
    end
end