function nhood = pk_get_nh1(img,x,y,z,l)

width = size(img,1);
height = size(img,2);
depth = size(img,3);

%[x,y,z]=ind2sub([width height depth],i);

nhood = false(l,27, 'like', img);

for xx=1:3
    for yy=1:3
        for zz=1:3
            w=sub2ind([3 3 3],xx,yy,zz);
            idx = sub2ind([width height depth],x+xx-2,y+yy-2,z+zz-2);
            nhood(:,w)=img(idx);
        end
    end
end
end
