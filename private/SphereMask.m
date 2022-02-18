function [mask]=SphereMask(R)

xbase = linspace(1,2*R+1,2*R+1) ;

xc = R+1; yc = R+1; zc = R+1;
xr = R; yr = R; zr = R;

[xm,ym,zm] = ndgrid( xbase , xbase , xbase) ;

mask = ( ((xm-xc).^2/(xr.^2)) + ((ym-yc).^2/(yr.^2)) + ((zm-zc).^2/(zr.^2)) <= 1 ) ;

xr = R-1; yr = R-1; zr = R-1;

mask2 = ( ((xm-xc).^2/(xr.^2)) + ((ym-yc).^2/(yr.^2)) + ((zm-zc).^2/(zr.^2)) <= 1 ) ;

mask = mask & ~mask2;






