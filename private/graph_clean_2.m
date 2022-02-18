function node_to_remove_par = graph_clean_2(wierdNode_in_name_par,wierdNode_out_name_par,link_table_wierd_full_par,S_radii_um_par)

connection_count = length(wierdNode_out_name_par);

murder_factor = 5.0;


switch connection_count
    case 0
        
        
        list = wierdNode_in_name_par;
        if length(list)>1
            [~, link_table_wierd_full_par(:,1)] = ismember(link_table_wierd_full_par(:,1),list);
            [~, link_table_wierd_full_par(:,2)] = ismember(link_table_wierd_full_par(:,2),list);
            temp_graph = graph(link_table_wierd_full_par(:,1),link_table_wierd_full_par(:,2));
            
            dist_list = distances(temp_graph);
            [temp1, temp2] = max(dist_list);
            [~, temp4] = max(temp1);
            
            node_to_keep = shortestpath(temp_graph,temp4,temp2(temp4));
            node_to_keep = list(node_to_keep');
            
            node_to_remove_par = wierdNode_in_name_par(~ismember(wierdNode_in_name_par, node_to_keep));
        else
            node_to_remove_par = list;
            
        end
    case 1
        
        if length(wierdNode_in_name_par) < murder_factor*max(S_radii_um_par)
            
            node_to_remove_par = sort([ wierdNode_in_name_par; wierdNode_out_name_par]);
            
        else
            node_to_remove_par = [];
        end
        
    case 2
        node_to_remove_par = [];
        
        
    otherwise
        
        node_to_remove_par = [];
        
        
end
