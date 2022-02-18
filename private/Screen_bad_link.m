function [S_link, wierdNode] = Screen_bad_link(S_skel,CropSize)



%%% isolate segments (S_link) and nasty skeletons (wierdNode)
[sum_nh_full] = get_all_sum_nh_par(S_skel,CropSize);
S_link.name = find(sum_nh_full==3);

[S_link_link_table] = get_all_link_par(S_skel(S_link.name),CropSize);
S_link.group = grouping_remake(length(S_link.name), S_link_link_table);
S_link.group = S_link.name(S_link.group);
S_link_group.name = unique(S_link.group);
S_link_group.length = histc(S_link.group,S_link_group.name);

badLinks = S_link_group.name(S_link_group.length<5);

removal = ismember( S_link.group,badLinks);
wierdNode.name = S_link.name(removal);
wierdNode.name = [find(sum_nh_full>3 | sum_nh_full == 2); wierdNode.name ];

S_link = structfun(@(x) (removerows(x, 'ind', removal)), S_link, 'UniformOutput', false);

wierdNode.name = sort(wierdNode.name);
[wierdNode.group] = getAll_Groups(S_skel(wierdNode.name),CropSize);
wierdNode.group = wierdNode.name(wierdNode.group);
[wierdNode_group.name] = unique(wierdNode.group);





