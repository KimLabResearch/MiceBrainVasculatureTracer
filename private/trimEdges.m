function [S_skel, S_radii] = trimEdges(S_skel, S_radii, CropSize, trimlevel)

jj = 0;
S_skelOld = 0;
S_radiiOld = 0;

while ~(isequal(S_skelOld, S_skel) && isequal(S_radiiOld, S_radii))

S_skelOld = S_skel;
S_radiiOld = S_radii;
jj=jj+1;
fprintf(['Cleaning Edges, trial #'  num2str(jj) '\n' ])

[goodLinkTable] = getAllLinks_save_memory(S_skel,CropSize);



C = unique(goodLinkTable(:,1:2));
S_skel = S_skel(C);
S_radii = S_radii(C);


[~,endPoint,~,nodes] = getAllLinks_save_memory(S_skel,CropSize);


flagS = false(length(S_skel),1);
flagS(nodes(:,1)) = 1;

S_noNodesPoint = S_skel(~flagS);
S_node = S_skel(flagS);
S_radii_noNodesPoint = S_radii(~flagS);
S_radii_node = S_radii(flagS);

[goodLinkTable_noNode] = getAllLinks_save_memory(S_noNodesPoint,CropSize);
group = grouping(S_noNodesPoint, goodLinkTable_noNode);

%[C,IA,IC] = unique(group);

flagS = false(length(S_noNodesPoint),1);

for ii = 1: size(endPoint,1)
    pointNumber = find(S_noNodesPoint == endPoint(ii,2));
    
    if sum(group == group(pointNumber)) <= trimlevel
        flagS(group == group(pointNumber)) = 1;
    end
end

S_noNodesPoint = S_noNodesPoint(~flagS);
S_radii_noNodesPoint = S_radii_noNodesPoint(~flagS);

S_skel = [S_noNodesPoint; S_node];
S_radii = [S_radii_noNodesPoint; S_radii_node];



S_skel2 = sortrows([S_skel S_radii]);

S_skel = S_skel2(:,1);
S_radii = S_skel2(:,2);




end


