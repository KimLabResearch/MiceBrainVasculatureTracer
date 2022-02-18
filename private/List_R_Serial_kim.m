function [line_node_list, end_node_list] = List_R_Serial_kim(  CutSize, node,link)

% display result
SkipEvery = 1;


w = CutSize(1);
l = CutSize(2);
h = CutSize(3);




line_node_list = zeros(5000000,4);
end_node_list = zeros(100000,3);
ii = 1;
i = 1;          
    for j=1:length(link)    % draw all connections of each node


        
        x2 = node(link(j).n1).comx;
        y2 = node(link(j).n1).comy;
        z2 = node(link(j).n1).comz;
        
        end_node_list(i,:) = [x2, y2, z2];
                i = i+1;
        
        
        x4 = node(link(j).n2).comx;
        y4 = node(link(j).n2).comy;
        z4 = node(link(j).n2).comz;
        end_node_list(i,:) = [x4, y4, z4];
        i = i+1;
    end          

    
    for j=1:length(link)    % draw all connections of each node
            for k=1:SkipEvery:floor(length(link(j).point)./SkipEvery)            
            [x3,y3,z3]=ind2sub([w,l,h],link(j).point(k));
            r3 = link(j).rr(k);
            line_node_list(ii,:) = [x3, y3, z3, r3];
            ii = ii+1;
            end
    end
line_node_list = line_node_list(logical(line_node_list(:,4)),:);
%figure()
%color3 = [line_node_list(:,3)./h 1-line_node_list(:,3)./h zeros(size(line_node_list(:,1)))];
%scatter3(line_node_list(:,1),line_node_list(:,2),line_node_list(:,3),line_node_list(:,4).*0.5, color3);
%h.MarkerEdgeColor = [0 0 0];
%view(-30,10)
%axis equal	
figure()

color3 = [line_node_list(:,4)./5 1-line_node_list(:,4)./5 zeros(size(line_node_list(:,1)))];
scatter3(line_node_list(:,1),line_node_list(:,2),line_node_list(:,3),line_node_list(:,4).*0.5, color3);

view(-30,10)
axis equal	