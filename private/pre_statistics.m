function [S_link, S_link_group, wierdNode, wierdNode_group] = pre_statistics(S_skel, CropSize)


tic
[~,nh] = get_nh_save_memory(S_skel,CropSize);
toc
distance_table = zeros(3,3,3);

distance_table(:,:,1) = [1.732, 1.414, 1.732; 1.414, 1, 1.414; 1.732, 1.414, 1.732];
distance_table(:,:,2) = [1.414, 1, 1.414; 1, 0, 1; 1.414, 1, 1.414];
distance_table(:,:,3) = [1.732, 1.414, 1.732; 1.414, 1, 1.414; 1.732, 1.414, 1.732];

distance_table = distance_table(:);

S_link.length = nh.*distance_table';
S_link.length = sum(S_link.length,2);
sum_nh_full = sum(nh,2);


S_link.name = find(sum_nh_full==3);
tic
[S_link_link_table] = get_all_link_par(S_skel(S_link.name),CropSize);

S_link.group = grouping_remake(length(S_link.name), S_link_link_table);
toc
tic
clear S_link_link_table

S_link.group = S_link.name(S_link.group);
S_link_group.name = unique(S_link.group);
[~,loc] = ismember(S_link.group,S_link_group.name);

S_link_group.length = accumarray(loc,S_link.length(S_link.name));

badLinks = S_link_group.name(S_link_group.length<10);



removal = ismember( S_link.group,badLinks);

wierdNode.name = S_link.name(removal);
wierdNode.name = [find(sum_nh_full>3 | sum_nh_full <= 2 ); wierdNode.name ];
clear sum_nh_full

S_link.name = S_link.name(~removal);
S_link.group = S_link.group(~removal);
S_link.length = S_link.length(~removal);

removal = ismember( S_link_group.name,badLinks);

S_link_group.name = S_link_group.name(~removal);
S_link_group.length = S_link_group.length(~removal);

wierdNode.name = sort(wierdNode.name);


%fprintf('Group and map the connectivity of the problematic nodes \n');


%%% group and map the connectivity of the problematic nodes


[link_table_wierd] = get_all_link_par(S_skel(wierdNode.name),CropSize);
wierdNode.group = grouping_remake(length(wierdNode.name), link_table_wierd);
wierdNode.group = wierdNode.name(wierdNode.group);
clear link_table_wierd


[wierdNode_group.name] = unique(wierdNode.group);

[link_table_full] = get_all_link_par(S_skel,CropSize);

link_table_wierd_out = link_table_full(xor(ismember(link_table_full(:,1),wierdNode.name) , ismember(link_table_full(:,2),wierdNode.name)),:);
link_table_wierd_full = link_table_full(ismember(link_table_full(:,1),wierdNode.name) | ismember(link_table_full(:,2),wierdNode.name),:);
clear link_table_full



lia1 = ismember(link_table_wierd_out(:,1),wierdNode.name);
lia2 = ismember(link_table_wierd_out(:,2),wierdNode.name);


node_wierd_out_in = zeros(length(link_table_wierd_out),1);
node_wierd_out_out = zeros(length(link_table_wierd_out),1);
node_wierd_out_out(lia1) = link_table_wierd_out(lia1,2);
node_wierd_out_out(lia2) = link_table_wierd_out(lia2,1);
node_wierd_out_in(lia1) = link_table_wierd_out(lia1,1);
node_wierd_out_in(lia2) = link_table_wierd_out(lia2,2);

[~, loc] = ismember(node_wierd_out_in,wierdNode.name);

node_wierd_out_group = wierdNode.group(loc);

clear lia1 lia2 loc link_table_wierd_out node_wierd_out_in



temp_w = [node_wierd_out_out, node_wierd_out_group];
temp_w = sortrows(temp_w,2);
[~,loc] = ismember(temp_w(:,2), wierdNode_group.name);
binsize = histcounts(loc,[0; find(wierdNode_group.name)]+0.5);

wierdNode_out_name_par = mat2cell(temp_w(:,1),binsize);


wierdNode_group.connection_count = zeros(size(wierdNode_group.name));

for ii = 1:length(wierdNode_group.name)
    wierdNode_group.connection_count(ii) = length(wierdNode_out_name_par{ii});
end
fprintf(['Isolated short segments count: ' num2str(sum(wierdNode_group.connection_count(:) == 0))  ' \n' ]);
fprintf(['Single connected short segments count: ' num2str(sum(wierdNode_group.connection_count(:) == 1))  ' \n' ]);
fprintf(['2x connected short segments count: ' num2str(sum(wierdNode_group.connection_count(:) == 2))  ' \n' ]);
fprintf(['3x connected pile count: ' num2str(sum(wierdNode_group.connection_count(:) == 3))  ' \n' ]);
fprintf(['4x connected pile count: ' num2str(sum(wierdNode_group.connection_count(:) == 4))  ' \n' ]);
fprintf(['>=5x connected pile count: ' num2str(sum(wierdNode_group.connection_count(:) >=5 ))  ' \n' ]);



toc