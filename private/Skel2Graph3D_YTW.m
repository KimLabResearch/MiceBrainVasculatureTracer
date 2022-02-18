function [node,link] = Skel2Graph3D_YTW(S_skel,CropSize,THR)
tic
skel = false(CropSize);
skel(S_skel) = 1;


% pad volume with zeros
skel=padarray(skel,[1 1 1]);

% create label matrix for different skeletons
%cc_skel=bwconncomp(skel);
%lm=labelmatrix(cc_skel);

% image dimensions
w=size(skel,1);
l=size(skel,2);
h=size(skel,3);

% need this for labeling nodes etc.
skel2 = double(sparse(skel(:)));

% all foreground voxels
list_canal=find(skel);

% 26-nh of all canal voxels
%nh = logical(pk_get_nh(skel,list_canal));

[x,y,z]=ind2sub([w l h],list_canal);

nh = false(length(list_canal),27);
nhi = zeros(length(list_canal),27);
for xx=1:3
    for yy=1:3
        for zz=1:3
            ww=sub2ind([3 3 3],xx,yy,zz);
            nhi(:,ww) = sub2ind([w l h],x+xx-2,y+yy-2,z+zz-2);
            nh(:,ww)=skel(nhi(:,ww));
        end
    end
end



% 26-nh indices of all canal voxels
%nhi = pk_get_nh_idx(skel,list_canal);

% # of 26-nb of each skel voxel + 1
sum_nh = sum(logical(nh),2);

% all canal voxels with >2 nb are nodes
nodes = list_canal(sum_nh>3);

% all canal voxels with exactly one nb are end nodes
ep = list_canal(sum_nh==2);

% all canal voxels with exactly 2 nb
cans = list_canal(sum_nh==3);

% Nx3 matrix with the 2 nb of each canal voxel
%can_nh_idx = pk_get_nh_idx(skel,cans);
%can_nh = pk_get_nh(skel,cans);

[x,y,z]=ind2sub([w l h],cans);

can_nh = false(length(cans),27);
can_nh_idx = zeros(length(cans),27);

for xx=1:3
    for yy=1:3
        for zz=1:3
            ww=sub2ind([3 3 3],xx,yy,zz);
            can_nh_idx(:,ww) = sub2ind([w l h],x+xx-2,y+yy-2,z+zz-2);
            can_nh(:,ww)=skel(can_nh_idx(:,ww));
        end
    end
end



% remove center of 3x3 cube
can_nh_idx(:,14)=[];
can_nh(:,14)=[];

% keep only the two existing foreground voxels
can_nb = sort(logical(can_nh).*can_nh_idx,2);

% remove zeros
can_nb(:,1:end-2) = [];

% add neighbours to canalicular voxel list (this might include nodes)
cans = [cans can_nb];

% group clusters of node voxels to nodes
node=[];
link=[];

tmp=false(w,l,h);
tmp(nodes)=1;
cc2=bwconncomp(tmp); % number of unique nodes
num_realnodes = cc2.NumObjects;
toc

% create node structure
for i=1:cc2.NumObjects
    node(i).idx = cc2.PixelIdxList{i};
    node(i).links = [];
    node(i).conn = [];
    [x,y,z]=ind2sub([w l h],node(i).idx);
    node(i).comx = mean(x);
    node(i).comy = mean(y);
    node(i).comz = mean(z);
    node(i).ep = 0;
    %node(i).label = lm(node(i).idx(1));
   
    % assign index to node voxels
    skel2(node(i).idx) = i+1;
end;

tmp=false(w,l,h);
tmp(ep)=1;
cc3=bwconncomp(tmp); % number of unique nodes


% create node structure
for i=1:cc3.NumObjects
    ni = num_realnodes+i;
    node(ni).idx = cc3.PixelIdxList{i};
    node(ni).links = [];
    node(ni).conn = [];
    [x,y,z]=ind2sub([w l h],node(ni).idx);
    node(ni).comx = mean(x);
    node(ni).comy = mean(y);
    node(ni).comz = mean(z);
    node(ni).ep = 1;
    %node(ni).label = lm(node(ni).idx(1));

    % assign index to node voxels
    skel2(node(ni).idx) = ni+1;
end;

l_idx = 1;

c2n=zeros(w*l*h,1);
c2n(cans(:,1))=1:size(cans,1);

s2n=zeros(w*l*h,1);
s2n(nhi(:,14))=1:size(nhi,1);

% visit all nodes
f = waitbar(0,'tracing...');







for i=1:length(node)

    % find all canal vox in nb of all node idx
    link_idx = s2n(node(i).idx);
    
    for j=1:length(link_idx)
        % visit all voxels of this node
        
        % all potential unvisited links emanating from this voxel
        link_cands = nhi(link_idx(j),nh(link_idx(j),:)==1);
        
	% short branches that only have an endpoint
        ep_cands = intersect(link_cands,ep);

        link_cands = link_cands(skel2(link_cands)==1);
	link_cands = intersect(link_cands,cans(:,1));
        
        for k=1:length(link_cands)
            [vox,n_idx,ept] = pk_follow_link(skel2,node,i,j,link_cands(k),cans,c2n);
            skel2(vox(2:end-1))=0;
            if((ept && length(vox)>THR) || (~ept && i~=n_idx))
                link(l_idx).n1 = i;
                link(l_idx).n2 = n_idx; % node number
                link(l_idx).point = vox;
                %link(l_idx).label = lm(vox(1));
		node(i).links = [node(i).links, l_idx];
                node(i).conn = [int16(node(i).conn), int16(n_idx)];
                node(n_idx).links = [node(n_idx).links, l_idx];
                node(n_idx).conn = [int16(node(n_idx).conn), int16(i)];
                l_idx = l_idx + 1;
            end;
        end;

        if (THR==0) % if short branches allowed
            for k=1:length(ep_cands)
                n_idx = skel2(ep_cands(k))-1;
                if(n_idx && n_idx~=i)
                    skel2(ep_cands(k))=0;
                    link(l_idx).n1 = i;
                    link(l_idx).n2 = n_idx; % node number
                    link(l_idx).point = ep_cands(k);
                    %link(l_idx).label = lm(ep_cands(k));
                    node(i).links = [node(i).links, l_idx];
                    node(i).conn = [int16(node(i).conn), int16(n_idx)];
                    node(n_idx).links = [node(n_idx).links, l_idx];
                    node(n_idx).conn = [int16(node(n_idx).conn), int16(i)];
                    l_idx = l_idx + 1;
                end;
            end;
        end;

    end;
    waitbar(i./length(node),f,'tracing...');
    
end;
close(f)






% mark all 1-nodes as end points
ep_idx = find(cellfun('length',{node.links})==1);
for i=1:length(ep_idx)
    node(ep_idx(i)).ep = 1;    
end;




% number of nodes
n_nodes = length(node);


% for all nodes, make according entries into matrix for all its links
for i=1:n_nodes
    idx1=find(node(i).conn>0);
    idx2=find(node(i).links>0);
    idx=intersect(idx1,idx2);

end;

% transform all voxel and position indices back to non-padded coordinates
for i=1:length(node)
    [x,y,z] = ind2sub([w,l,h],node(i).idx);
    node(i).idx = sub2ind([w-2,l-2,h-2],x-1,y-1,z-1);
    node(i).comx = node(i).comx - 1;
    node(i).comy = node(i).comy - 1;
    node(i).comz = node(i).comz - 1;
end;

% transform all link voxel indices back to non-padded coordinates
for i=1:length(link)
    [x,y,z] = ind2sub([w,l,h],link(i).point);
    link(i).point = sub2ind([w-2,l-2,h-2],x-1,y-1,z-1);
end;
