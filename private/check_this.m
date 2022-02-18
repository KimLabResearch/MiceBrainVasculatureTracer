check_this_guy = 17119;



list = [wierdNode_in_name_par{check_this_guy};wierdNode_out_name_par{check_this_guy}];
name = find(list);
out_name = name(ismember(list,wierdNode_out_name_par{check_this_guy}));
temp1 = link_table_wierd_full_par{check_this_guy};
[~, temp1(:,1)] = ismember(temp1(:,1),list);
[~, temp1(:,2)] = ismember(temp1(:,2),list);
temp_graph = graph(temp1(:,1),temp1(:,2));

dist_list = distances(temp_graph,out_name);
dist_list = sum(dist_list);
[~, loc] = min(dist_list);

node_to_keep = [];
for ii = 1:length(out_name)
    node_to_keep = [node_to_keep, shortestpath(temp_graph,out_name(ii),loc)];
end
node_to_keep = list(node_to_keep');
node_to_remove_par = wierdNode_in_name_par{check_this_guy}(~ismember(wierdNode_in_name_par{check_this_guy}, node_to_keep));
plot(temp_graph);
