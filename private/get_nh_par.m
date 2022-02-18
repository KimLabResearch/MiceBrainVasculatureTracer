function [nhZZZ, nhiZZZ] = get_nh_par( ~, x, y ,z, zzz, S_skel_pad_zzz_3, CropSize2)

skel = false(CropSize2(1),CropSize2(2),3);
skel(S_skel_pad_zzz_3) = 1;

%nhZZZ = false(size(S_skel_pad,1),27);
%nhiZZZ = zeros(size(S_skel_pad,1),27);
[x_mod, y_mod, z_mod] = ind2sub([3 3 3], 1:1:27);

nhiZZZ = sub2ind(CropSize2,x+x_mod-2,y+y_mod-2,z+z_mod-2);
nhZZZ = skel(nhiZZZ-CropSize2(1).*CropSize2(2).*(zzz-2));