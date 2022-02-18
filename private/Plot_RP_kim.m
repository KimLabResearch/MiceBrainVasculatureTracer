function [] = Plot_RP_kim(CropPoint, CropMultiplier, CutSize, HalfCutSize, node,link)

% display result
SkipEvery = 1;

figure('position', [0, 0, 1200, 800]) 
hold on;

axis equal
%view(-17,46);


w = HalfCutSize;
l = HalfCutSize;
h = HalfCutSize;



for iz = 1:size(node,1)
   for ixy = 1:size(node,2) 
   %for ixy = 1:1

      for ip = 1:1:4
                   col= rand(1,3); % links are red
          
          if length(node{iz,ixy,ip})~=1
          [indc,indd] = ind2sub([2 2],ip);
          [inda,indb] = ind2sub([CropMultiplier(1) CropMultiplier(2)],ixy);

          offx = CropPoint(1)+CutSize.*(inda-1)+HalfCutSize.*(indc-1);
          offy = CropPoint(2)+CutSize.*(indb-1)+HalfCutSize.*(indd-1);
          offz = CropPoint(3)+HalfCutSize.*iz; 
          
          
    for j=1:length(link{iz,ixy,ip})    % draw all connections of each node


        
        x2 = node{iz,ixy,ip}(link{iz,ixy,ip}(j).n1).comx+offx;
        y2 = node{iz,ixy,ip}(link{iz,ixy,ip}(j).n1).comy+offy;
        z2 = node{iz,ixy,ip}(link{iz,ixy,ip}(j).n1).comz+offz;
        
        plot3(y2,x2,z2,'o','Markersize',4,...
        'MarkerFaceColor',col,...
        'Color','r');
        
        
        
            
        % draw edges as lines using voxel positions
        for k=1:SkipEvery:floor(length(link{iz,ixy,ip}(j).point)./SkipEvery)            
            [x3,y3,z3]=ind2sub([w,l,h],link{iz,ixy,ip}(j).point(k));
            x3 = x3+offx;
            y3 = y3+offy;
            z3 = z3+offz;
        plot3(y3,x3,z3,'o','Markersize',link{iz,ixy,ip}(j).rr(k),...
        'MarkerFaceColor',col,...
        'Color','k');        
        end
        x3 = node{iz,ixy,ip}(link{iz,ixy,ip}(j).n2).comx+offx;
        y3 = node{iz,ixy,ip}(link{iz,ixy,ip}(j).n2).comy+offy;
        z3 = node{iz,ixy,ip}(link{iz,ixy,ip}(j).n2).comz+offz;
        % draw all nodes as yellow circles
        plot3(y3,x3,z3,'o','Markersize',4,...
        'MarkerFaceColor',col,...
        'Color','r');

    end          
          
          drawnow;

          
          
          
          
          end
      end
   end
end

    

set(gcf,'Color','white');
drawnow;
