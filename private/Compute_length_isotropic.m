function [tot_length] = Compute_length_isotropic(Box_size,node2,link2)

% display result




tot_length = 0.0;


w = Box_size(1);
l = Box_size(2);
h = Box_size(3);




    for j=1:length(link2)    % draw all connections of each node
        %if(node2(node2(i).conn(j)).ep==1)
        %    col='k'; % branches are black
        %else
            col= rand(1,3); % links are red
        %end;
        %if(node2(i).ep==1)
        %    col='k';
        %end;
        x2 = node2(link2(j).n1).comx;
        y2 = node2(link2(j).n1).comy;
        z2 = node2(link2(j).n1).comz;
        [x3,y3,z3]=ind2sub([w,l,h],link2(j).point(1));
        %line([y3 y2],[x3 x2],[z3 z2],'Color',col,'LineWidth',2);
        if sqrt((y3-y2)^2+(x3-x2)^2+(z3-z2)^2) > 0
        tot_length = tot_length + sqrt((y3-y2)^2+(x3-x2)^2+(z3-z2)^2);
        end    
        % draw edges as lines using voxel positions
        for k=1:length(link2(j).point)-1            
            [x3,y3,z3]=ind2sub([w,l,h],link2(j).point(k));
            [x2,y2,z2]=ind2sub([w,l,h],link2(j).point(k+1));
        %    line([y3 y2],[x3 x2],[z3 z2],'Color',col,'LineWidth',2);
        if sqrt((y3-y2)^2+(x3-x2)^2+(z3-z2)^2) > 0
        tot_length = tot_length + sqrt((y3-y2)^2+(x3-x2)^2+(z3-z2)^2);
        end
        end
        [x2,y2,z2]=ind2sub([w,l,h],link2(j).point(k+1));
        x3 = node2(link2(j).n2).comx;
        y3 = node2(link2(j).n2).comy;
        z3 = node2(link2(j).n2).comz;
        %line([y3 y2],[x3 x2],[z3 z2],'Color',col,'LineWidth',2);
        if sqrt((y3-y2)^2+(x3-x2)^2+(z3-z2)^2) > 0
        tot_length = tot_length + sqrt((y3-y2)^2+(x3-x2)^2+(z3-z2)^2);
        end
        
        
    end
    
