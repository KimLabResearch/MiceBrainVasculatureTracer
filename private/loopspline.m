function [B_intp2] = loopspline(B,z,zz)
        B_intp2(:,:) = interp1(z,B,zz,'V5CUBIC');
        



