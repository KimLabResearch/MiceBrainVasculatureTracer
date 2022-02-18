function node_to_remove_par = graph_clean_3(wierdNode_in_name_par,wierdNode_out_name_par,link_table_wierd_full_par)

connection_count = length(wierdNode_out_name_par);




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
        
        list = [wierdNode_in_name_par;wierdNode_out_name_par];
        name = find(list);
        out_name = name(ismember(list,wierdNode_out_name_par));
        [~, link_table_wierd_full_par(:,1)] = ismember(link_table_wierd_full_par(:,1),list);
        [~, link_table_wierd_full_par(:,2)] = ismember(link_table_wierd_full_par(:,2),list);
        temp_graph = graph(link_table_wierd_full_par(:,1),link_table_wierd_full_par(:,2));
        
        dist_list = distances(temp_graph,out_name);
        [~, loc] = max(dist_list);
        node_to_keep = shortestpath(temp_graph,out_name,loc);
        node_to_keep = list(node_to_keep');
        
        
        %node_to_keep = [link_table_wierd_full_par(ismember(link_table_wierd_full_par(:,1),wierdNode_out_name_par),2), link_table_wierd_full_par(ismember(link_table_wierd_full_par(:,2),wierdNode_out_name_par),1)];
        node_to_remove_par = wierdNode_in_name_par(~ismember(wierdNode_in_name_par, node_to_keep));
        
        
    case 2
        list = [wierdNode_in_name_par;wierdNode_out_name_par];
        name = find(list);
        out_name = name(ismember(list,wierdNode_out_name_par));
        [~, link_table_wierd_full_par(:,1)] = ismember(link_table_wierd_full_par(:,1),list);
        [~, link_table_wierd_full_par(:,2)] = ismember(link_table_wierd_full_par(:,2),list);
        temp_graph = graph(link_table_wierd_full_par(:,1),link_table_wierd_full_par(:,2));
        
        node_to_keep = shortestpath(temp_graph,out_name(1),out_name(2));
        node_to_keep = list(node_to_keep);
        
        node_to_remove_par = wierdNode_in_name_par(~ismember(wierdNode_in_name_par, node_to_keep));
        
    otherwise
        node_to_remove_par = [];

        
end
