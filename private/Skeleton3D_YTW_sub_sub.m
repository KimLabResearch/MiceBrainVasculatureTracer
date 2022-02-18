function noChange = Skeleton3D_YTW_sub_sub(currentBorder,ii,numberFiles,sizeSkel,dir_out)
%by Yuan-Ting Wu 5/2019
%



%%%%read bin file


    fileIndicator = [dir_out '/binarized' num2str(ii,'%04d') '.bin' ];
    fileID = fopen(fileIndicator,'r');
    skelSparse = fread(fileID, Inf, 'uint64');
    fclose(fileID);

    
    if ii ~= 1

        fileIndicator = [dir_out '/binarized_head' num2str(ii,'%04d') '.bin' ];
        fileID = fopen(fileIndicator,'r');
        skelHeadSparse = fread(fileID, Inf, 'uint64');
        fclose(fileID);
        skelSparse = skelSparse + sizeSkel(1).*sizeSkel(2);
        skelSparse = [skelHeadSparse; skelSparse];
        sizeSkel = sizeSkel + [0 0 1];
    end
    
    if ii ~= numberFiles

        fileIndicator = [dir_out '/binarized_foot' num2str(ii,'%04d') '.bin' ];
        fileID = fopen(fileIndicator,'r');
        skelFootSparse = fread(fileID, Inf, 'uint64');
        fclose(fileID);
        skelFootSparse = skelFootSparse + sizeSkel(1).*sizeSkel(2).*sizeSkel(3);
        skelSparse = [skelSparse; skelFootSparse];
        sizeSkel = sizeSkel + [0 0 1];

    end



        [skelSparseX, skelSparseY, skelSparseZ] = ind2sub([sizeSkel(1) sizeSkel(2) sizeSkel(3)],skelSparse);
        
        skelSparseX = skelSparseX + 1;
        skelSparseY = skelSparseY + 1;
        skelSparseZ = skelSparseZ + 1;
        
        sizeSkel = sizeSkel + [2 2 2];
        
        skelSparse = sub2ind([sizeSkel(1) sizeSkel(2) sizeSkel(3)],skelSparseX, skelSparseY,skelSparseZ);
        
        
spare = false(sizeSkel);
    if ii ~= 1
spare(:,:,2)=1;
    end
    if ii ~= numberFiles
spare(:,:,end-1)=1;
    end



skel = false(sizeSkel);
skel(skelSparse) = 1;
   




width = sizeSkel(1);
height = sizeSkel(2);
depth = sizeSkel(3);


        
eulerLUT = FillEulerLUT;        

        skelSparseIndex = 1:1:length(skelSparse);

        %cands=false(width,height,depth);
        %skelSparse = find(skel);
                switch currentBorder
            case 4
                % identify border voxels as candidates
                shiftVector = [-1 0 0];
            case 3
                shiftVector = [1 0 0];
            case 1
                shiftVector = [0 -1 0];
            case 2
                shiftVector = [0 1 0];
            case 6
                shiftVector = [0 0 -1];
            case 5
                shiftVector = [0 0 1];
                end
        skelSparseX = skelSparseX + shiftVector(1);
        skelSparseY = skelSparseY + shiftVector(2);
        skelSparseZ = skelSparseZ + shiftVector(3);
        keeper = ~skel(sub2ind([width height depth],skelSparseX, skelSparseY,skelSparseZ));
        cands = skelSparse(keeper);
        skelSparseIndex = skelSparseIndex(keeper);
        
        % if excluded voxels were passed, remove them from candidates
            skelSparseIndex = skelSparseIndex(~spare(cands));
            cands = cands(~spare(cands));
        
        
        % make sure all candidates are indeed foreground voxels

       
        noChange = true;
        
        
        
        
        if any(cands(:))

            
            % get subscript indices of candidates
            %[x,y,z]=ind2sub([width height depth],cands);
            
            
            
            % get 26-neighbourhood of candidates in volume
            %nhood = pk_get_nh_sp(skel,cands);
            
            [xnhood,ynhood,znhood]=ind2sub([width height depth],cands);

            nhood = false(length(cands),27);
            for xx=1:3
                for yy=1:3
                    for zz=1:3
                        w=sub2ind([3 3 3],xx,yy,zz);
                        idx = sub2ind([width height depth],xnhood+xx-2,ynhood+yy-2,znhood+zz-2);
                        nhood(:,w)=skel(idx);
                    end
                end
            end
            clear xnhood ynhood znhood idx

            
            
            % remove all endpoints (exactly one nb) from list
            
            di1 = sum(nhood,2)==2;
            nhood(di1,:)=[];
            cands(di1)=[];
            skelSparseIndex(di1)=[];
            
            % remove all non-Euler-invariant points from list
            di2 = ~p_EulerInv(nhood, eulerLUT);
            nhood(di2,:)=[];
            cands(di2)=[];
            skelSparseIndex(di2)=[];
            % remove all non-simple points from list
            di3 = ~p_is_simple(nhood);
            %             nhood(di3,:)=[];
            cands(di3)=[];
            skelSparseIndex(di3)=[];
             [x,y,z]=ind2sub([width height depth],cands);

             
            
            
            
            
            % if any candidates left: divide into 8 independent subvolumes
            if (~isempty(x))
               
                x1 = logical(mod(x,2));
                x2 = ~x1;
                y1 = logical(mod(y,2));
                y2 = ~y1;
                z1 = logical(mod(z,2));
                z2 = ~z1;
                
                
                OctaParaList(1).l = x1 & y1 & z1;
                OctaParaList(2).l = x2 & y1 & z1;
                OctaParaList(3).l = x1 & y2 & z1;
                OctaParaList(4).l = x2 & y2 & z1;
                OctaParaList(5).l = x1 & y1 & z2;
                OctaParaList(6).l = x2 & y1 & z2;
                OctaParaList(7).l = x1 & y2 & z2;
                OctaParaList(8).l = x2 & y2 & z2;
                
                removal = false(length(skelSparse),1);
                % do parallel re-checking for all points in each subvolume
                for i = 1:8                    
                    if any(OctaParaList(i).l)
                        idx = OctaParaList(i).l;
                        li = sub2ind([width height depth],x(idx),y(idx),z(idx));
                        liSparse = skelSparseIndex(idx);
                        skel(li) = 0; % remove points
                        removal(liSparse) = 1;
                        %nh = pk_get_nh_sp(skel,li);
                        
                        [xnhood,ynhood,znhood]=ind2sub([width height depth],li);
                        nh = false(length(li),27);
                        for xx=1:3
                            for yy=1:3
                                for zz=1:3
                                    w=sub2ind([3 3 3],xx,yy,zz);
                                    idx = sub2ind([width height depth],xnhood+xx-2,ynhood+yy-2,znhood+zz-2);
                                    nh(:,w)=skel(idx);
                                end
                            end
                        end
                        clear xnhood ynhood znhood idx

                        
                        
                        
                        di_rc = ~p_is_simple(nh);
                        rcSparse = liSparse(di_rc);
                        if any(di_rc) % if topology changed: revert
                            skel(li(di_rc)) = true;
                            removal(rcSparse) = 0;
                            if length(find(di_rc))~=length(li)
                                noChange = false; % at least one voxel removed
                            end
                        else
                            noChange = false; % at least one voxel removed
                        end
                    end
                end
                if any(removal)
                skelSparse(removal) = [];
                end
                
            end
        end
        
    
    

        [skelSparseX, skelSparseY, skelSparseZ] = ind2sub([sizeSkel(1) sizeSkel(2) sizeSkel(3)],skelSparse);
        
        skelSparseX = skelSparseX - 1;
        skelSparseY = skelSparseY - 1;
        skelSparseZ = skelSparseZ - 1;
        
        sizeSkel = sizeSkel + [-2 -2 -2];
        
        skelSparse = sub2ind([sizeSkel(1) sizeSkel(2) sizeSkel(3)],skelSparseX, skelSparseY,skelSparseZ);
        
        
        
        
%%%%% save bin
    if ii ~= numberFiles
        skelSparse = skelSparse(skelSparse(:)<=sizeSkel(1).*sizeSkel(2).*(sizeSkel(3)-1));
        sizeSkel = sizeSkel + [0 0 -1];
    end
    if ii ~= 1
        skelSparse = skelSparse(skelSparse(:)>sizeSkel(1).*sizeSkel(2));
        skelSparse = skelSparse - sizeSkel(1).*sizeSkel(2);
        sizeSkel = sizeSkel + [0 0 -1];
        
    end


    fileIndicator = [dir_out '/temp/binarized' num2str(ii,'%04d') '.bin' ];
    fileID = fopen(fileIndicator,'w');
    fwrite(fileID, uint64(skelSparse),'uint64');
    fclose(fileID);

    if ii ~= numberFiles
        skelSparse_end = skelSparse(skelSparse(:)>sizeSkel(1).*sizeSkel(2).*(sizeSkel(3)-1));
        skelSparse_end = skelSparse_end - sizeSkel(1).*sizeSkel(2).*(sizeSkel(3)-1);
        fileIndicator = [dir_out '/temp/binarized_head' num2str(ii+1,'%04d') '.bin' ];
        fileID = fopen(fileIndicator,'w');
        fwrite(fileID, uint64(skelSparse_end),'uint64');
        fclose(fileID);
        
    end
    
    if ii ~= 1
        skelSparse_top = skelSparse(skelSparse(:)<=sizeSkel(1).*sizeSkel(2));
        fileIndicator = [dir_out '/temp/binarized_foot' num2str(ii-1,'%04d') '.bin' ];
        fileID = fopen(fileIndicator,'w');
        fwrite(fileID, uint64(skelSparse_top),'uint64');
        fclose(fileID);
        
    end
    
